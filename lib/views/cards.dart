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
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  API get service => GetIt.I<API>();

  List<Series> apiResponse;
  bool _isLoading = true;
  RefreshController _refreshController = RefreshController();
  List filteredApiResponse;

  @override
  void initState() {
    fetchSeries();
    super.initState();
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
      // while (apiResponse == null) {
      //   // _isLoading = true;
      // }
      _isLoading = false;
    });
    _refreshController.refreshCompleted();
    setState(() {});
  }

  void search(query) {
    filteredApiResponse = [];
    for (int i = 0; i < apiResponse.length; i++) {
      if (apiResponse[i]
          .name
          .toUpperCase()
          .contains(query.toString().toUpperCase())) {
        filteredApiResponse.add(apiResponse[i]);
      }
    }
    for (int i = 0; i < apiResponse.length; i++) {
      if (apiResponse[i]
          .comment
          .toUpperCase()
          .contains(query.toString().toUpperCase())) {
        filteredApiResponse.add(apiResponse[i]);
      }
    }
    Set filteredApiResponseSet = filteredApiResponse.toSet();
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
                        child: StaggeredGridView.countBuilder(
                          itemCount: filteredApiResponse.length,
                          crossAxisCount:
                              (orientation == Orientation.portrait) ? 2 : 3,
                          staggeredTileBuilder: (index) {
                            return orientation == Orientation.portrait
                                ? const StaggeredTile.fit(2)
                                : const StaggeredTile.fit(1);
                          },
                          itemBuilder: (context, index) {
                            final item =
                                filteredApiResponse[index].id.toString();
                            return Container(
                              padding: EdgeInsets.all(8),
                              constraints:
                                  BoxConstraints(minWidth: 100, maxWidth: 500),
                              child: Dismissible(
                                key: Key(item),
                                onDismissed: (direction) async {
                                  await service.deleteData(
                                      filteredApiResponse[index].id);
                                  fetchSeries();
                                },
                                child: Card(
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                    onTap: () async {
                                      if (filteredApiResponse[index].tor) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: Text(
                                                'You added the TOR option. Do you want to copy the link?'),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(
                                                        text:
                                                            filteredApiResponse[
                                                                    index]
                                                                .link));
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Copy'))
                                            ],
                                          ),
                                        );
                                      } else {
                                        await launch(
                                            filteredApiResponse[index].link);
                                      }
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon((() {
                                            if (filteredApiResponse[index]
                                                .paused) {
                                              return Icons.pause;
                                            }
                                            return Icons.play_arrow;
                                          })()),
                                          title: Text(
                                              filteredApiResponse[index].name),
                                          subtitle: Text(
                                              'Season ${filteredApiResponse[index].season} Episode ${filteredApiResponse[index].episode}'),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(filteredApiResponse[index]
                                              .comment),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextButton(
                                                child: const Text('Edit'),
                                                onPressed: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        SeriesModify(
                                                            filteredApiResponse[
                                                                    index]
                                                                .id,
                                                            filteredApiResponse[
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
                            );
                          },
                        ))),
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
