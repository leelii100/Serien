import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:serien/models/series.dart';
import 'package:serien/services/API.dart';
import 'package:serien/widgets/CounterField.dart';
import 'package:serien/widgets/LabeledCheckbox.dart';

class SeriesModify extends StatefulWidget {
  final int id;
  final changed;
  SeriesModify(this.id, this.changed);

  @override
  _SeriesModifyState createState() => _SeriesModifyState(this.id, this.changed);
}

class _SeriesModifyState extends State<SeriesModify> {
  final int id;
  var changed;
  _SeriesModifyState(this.id, this.changed);
  API get service => GetIt.I<API>();

  final nameController = TextEditingController();
  int _episode = 1;
  int _season = 1;
  final linkController = TextEditingController();
  final commentController = TextEditingController();
  bool _isPaused = false;
  bool _isTor = false;
  bool loaded = false;

  @override
  initState() {
    super.initState();
  }

  setData(snapshot) async {
    if (id == 0) {
      nameController.text = '';
      linkController.text = '';
      commentController.text = '';
      return;
    }
    Series data = snapshot.data;
    changed = snapshot.data.changed;
    setState(() {
      try {
        nameController.text = data.name;
        _episode = data.episode;
        _season = data.season;
        linkController.text = data.link;
        commentController.text = data.comment;
        _isPaused = data.paused;
        _isTor = data.tor;
        loaded = true;
      } catch (e) {
        print(e);
      }
    });
  }

  String buildJson() {
    return '{"Changed" : "${changed.toIso8601String()}", ' +
        '"Comment" : "${commentController.text}", ' +
        '"Episode" : $_episode, ' +
        '"Link" : "${linkController.text}", ' +
        '"Name" : "${nameController.text}", ' +
        '"Paused" : $_isPaused, ' +
        '"Season" : $_season, ' +
        '"Tor" : $_isTor }';
  }

  sendData() {
    String json = buildJson();
    service.sendData(json);
  }

  updateData(id) {
    String json = buildJson();
    service.updateData(id, json);
  }

  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
      future: (service.getSeries(id)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (!loaded) {
            setData(snapshot);
          }
          return AlertDialog(
            title: Text((() {
              if (id == 0) {
                return 'New';
              }
              return 'Edit';
            })()),
            content: Container(
              width: 400.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(helperText: 'Name'),
                  ),
                  CounterField(
                    value: _season,
                    label: 'Season',
                    onClicked: (value) => _season = value,
                  ),
                  CounterField(
                    value: _episode,
                    label: 'Episode',
                    onClicked: (value) => _episode = value,
                  ),
                  TextFormField(
                    controller: linkController,
                    decoration: InputDecoration(helperText: 'Link'),
                  ),
                  TextFormField(
                    controller: commentController,
                    decoration: InputDecoration(helperText: 'Comment'),
                  ),
                  LabeledCheckbox(
                    label: 'Paused',
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    value: _isPaused,
                    onChanged: (bool newValue) {
                      setState(() {
                        _isPaused = newValue;
                      });
                    },
                  ),
                  LabeledCheckbox(
                    label: 'Tor',
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    value: _isTor,
                    onChanged: (bool newValue) {
                      setState(() {
                        _isTor = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('OK'),
                ),
                onPressed: () {
                  loaded = false;
                  if (id == 0) {
                    sendData();
                  } else {
                    updateData(id);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return AlertDialog(
            content: Text(snapshot.error.toString()),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
