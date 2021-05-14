import 'dart:convert';
import 'package:http/http.dart';
import 'package:serien/models/series.dart';

class API {
  final Uri url = Uri.http('192.168.178.22:5000', 'series');

  Future getSeriesList() {
    return get(url).then((data) {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final notes = <Series>[];
        for (var item in jsonData) {
          notes.add(Series.fromJSON(item));
        }
        final finalnotes = <Series>[];
        for (Series i in notes) {
          if (!i.paused) {
            finalnotes.insert(0, i);
            continue;
          }
          finalnotes.add(i);
        }
        return (finalnotes);
      }
      print('API Error');
    });
  }

  getSeries(int id) {
    return getSeriesList().then((data) {
      if (id == 0) {
        return Series(
            changed: DateTime.now(),
            comment: '',
            episode: 1,
            id: 0,
            link: '',
            name: '',
            paused: false,
            season: 1,
            time: DateTime.now(),
            tor: false);
      }
      for (var i in data) {
        if (i.id == id) {
          return i;
        }
      }
    });
  }

  sendData(String json) {
    Map<String, String> headers = {"content-type": "application/json"};
    post(url, headers: headers, body: json);
  }

  void deleteData(int id) {
    Uri deleteUrl = Uri.parse(url.toString() + '/$id');
    delete(deleteUrl);
  }

  updateData(int id, String json) {
    Uri updateUrl = Uri.parse(url.toString() + '/$id');
    Map<String, String> headers = {"content-type": "application/json"};
    put(updateUrl, headers: headers, body: json);
  }
}
