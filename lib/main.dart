import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:serien/models/series.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';

import 'package:serien/views/modify.dart';
import 'package:serien/services/API.dart';

void setupLocator() {
  GetIt.I.registerLazySingleton(() => API());
}

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.green,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Serien'),
    );
  }
}

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

  @override
  void initState() {
    fetchSeries();
    super.initState();
  }

  Future<void> fetchSeries() async {
    apiResponse = await service.getSeriesList();

    setState(() {
      _isLoading = false;
    });
    _refreshController.refreshCompleted();
    setState(() {});
  }

  void search(query) {
    print(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: fetchSeries,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                textAlign: TextAlign.center,
                onChanged: (query) => search(query),
              ),
            ),
            Builder(
              builder: (_) {
                if (_isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                return Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: apiResponse.length,
                    itemBuilder: (context, index) {
                      final item = apiResponse[index].id.toString();
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            constraints:
                                BoxConstraints(minWidth: 100, maxWidth: 500),
                            child: Dismissible(
                              key: Key(item),
                              onDismissed: (direction) =>
                                  service.deleteData(apiResponse[index].id),
                              child: Card(
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0)),
                                  onTap: () async =>
                                      await launch(apiResponse[index].link),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon((() {
                                          if (apiResponse[index].paused) {
                                            return Icons.pause;
                                          }
                                          return Icons.play_arrow;
                                        })()),
                                        title: Text(apiResponse[index].name),
                                        subtitle: Text(
                                            'Season ${apiResponse[index].season} Episode ${apiResponse[index].episode}'),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 0, 8, 0),
                                        child: Text(apiResponse[index].comment),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              child: const Text('Edit'),
                                              onPressed: () {
                                                fetchSeries();
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => SeriesModify(
                                                      apiResponse[index].id,
                                                      apiResponse[index]
                                                          .changed),
                                                );
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
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          fetchSeries();
          await showDialog(
              context: context,
              builder: (_) => SeriesModify(0, DateTime.now()));
        },
        tooltip: 'Add Series',
        child: Icon(Icons.add),
      ),
    );
  }
}
