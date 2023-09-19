import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:serien/models/series.dart';
import 'package:serien/views/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:serien/views/modify.dart';
import 'package:flutter/services.dart';
import 'package:serien/services/API.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final API service = GetIt.I<API>();

  List<Series>? apiResponse;
  bool _isLoading = true;
  RefreshController _refreshController = RefreshController();
  List<Series>? filteredApiResponse;

  @override
  void initState() {
    super.initState();
    fetchSeries();
  }

  Future<void> fetchSeries() async {
    try {
      apiResponse = await service.getSeriesList();
      filteredApiResponse = apiResponse;
    } catch (e) {
      print('Cant reach server');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
              'Cant reach server. Is the server running? Did you specify the server address?'),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  fetchSeries();
                },
                child: Text('Retry')),
            ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Settings(fetchSeries)));
                  _refreshController.refreshCompleted();
                },
                child: Text('Settings'))
          ],
        ),
      );
      return;
    }
    setState(() {
      _isLoading = false;
    });
    _refreshController.refreshCompleted();
    setState(() {});
  }

  void search(String query) {
    filteredApiResponse = [];
    for (int i = 0; i < apiResponse!.length; i++) {
      if (apiResponse![i].name.toUpperCase().contains(query.toUpperCase())) {
        filteredApiResponse!.add(apiResponse![i]);
      }
    }
    for (int i = 0; i < apiResponse!.length; i++) {
      if (apiResponse![i].comment.toUpperCase().contains(query.toUpperCase())) {
        filteredApiResponse!.add(apiResponse![i]);
      }
    }
    Set<Series> filteredApiResponseSet = filteredApiResponse!.toSet();
    setState(() {
      filteredApiResponse = filteredApiResponseSet.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final padding = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
    final searchbar = 104;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Settings(fetchSeries),
                    )),
                icon: Icon(Icons.settings),
                label: Text('Settings'))
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                textAlign: TextAlign.center,
                onChanged: (query) => search(query),
              ),
            ),
            (_isLoading)
                ? Center(child: CircularProgressIndicator())
                : Container(
                    height: MediaQuery.of(context).size.height -
                        padding -
                        searchbar,
                    width: MediaQuery.of(context).size.width,
                    child: SmartRefresher(
                        controller: _refreshController,
                        onRefresh: fetchSeries,
                        child: StaggeredGrid.count(
                            crossAxisCount: 4,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            children: List.generate(
                              filteredApiResponse!.length,
                              (index) {
                                final item =
                                    filteredApiResponse![index].id.toString();
                                return StaggeredGridTile.count(
                                    crossAxisCellCount:
                                        (orientation == Orientation.portrait)
                                            ? 2
                                            : 1,
                                    mainAxisCellCount:
                                        (orientation == Orientation.portrait)
                                            ? 2
                                            : 1,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      constraints: BoxConstraints(
                                          minWidth: 100, maxWidth: 500),
                                      child: Dismissible(
                                        key: Key(item),
                                        onDismissed: (direction) async {
                                          await service.deleteData(
                                              filteredApiResponse![index].id);
                                          fetchSeries();
                                        },
                                        child: Card(
                                          child: InkWell(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                            onTap: () async {
                                              if (filteredApiResponse![index]
                                                  .tor) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    content: Text(
                                                        'You added the TOR option. Do you want to copy the link?'),
                                                    actions: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: filteredApiResponse![
                                                                            index]
                                                                        .link));
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Copy'))
                                                    ],
                                                  ),
                                                );
                                              } else if (filteredApiResponse![
                                                          index]
                                                      .link ==
                                                  '') {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              content: Text(
                                                                  'You did not add a link. Do you want to edit the entry?'),
                                                              actions: [
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (_) => SeriesModify(
                                                                            filteredApiResponse![index].id,
                                                                            filteredApiResponse![index].changed),
                                                                      );
                                                                      fetchSeries();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        'Edit'))
                                                              ],
                                                            ));
                                              } else {
                                                try {
                                                  await launchUrl(Uri.parse(
                                                      filteredApiResponse![
                                                              index]
                                                          .link));
                                                } catch (e) {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) =>
                                                              AlertDialog(
                                                                content: Text(
                                                                    'Could not open link. Do you want to edit the entry?'),
                                                                actions: [
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        await showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (_) => SeriesModify(
                                                                              filteredApiResponse![index].id,
                                                                              filteredApiResponse![index].changed),
                                                                        );
                                                                        fetchSeries();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                          'Edit'))
                                                                ],
                                                              ));
                                                }
                                              }
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                ListTile(
                                                  leading: Icon((() {
                                                    if (filteredApiResponse![
                                                            index]
                                                        .paused) {
                                                      return Icons.pause;
                                                    }
                                                    return Icons.play_arrow;
                                                  })()),
                                                  title: Text(
                                                      filteredApiResponse![
                                                              index]
                                                          .name),
                                                  subtitle: Text(
                                                      'Season ${filteredApiResponse![index].season} Episode ${filteredApiResponse![index].episode}'),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      8, 0, 8, 0),
                                                  child: Text(
                                                      filteredApiResponse![
                                                              index]
                                                          .comment),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextButton(
                                                        child:
                                                            const Text('Edit'),
                                                        onPressed: () async {
                                                          await showDialog(
                                                            context: context,
                                                            builder: (_) => SeriesModify(
                                                                filteredApiResponse![
                                                                        index]
                                                                    .id,
                                                                filteredApiResponse![
                                                                        index]
                                                                    .changed),
                                                          );
                                                          fetchSeries();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ));
                              },
                            ))),
                  )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
                context: context,
                builder: (_) => SeriesModify(0, DateTime.now()));
            fetchSeries();
          },
          tooltip: 'Add Series',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
