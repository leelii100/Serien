import 'dart:convert';
import 'package:http/http.dart';
import 'package:serien/models/series.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  Future<Uri> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final Uri url = Uri.parse(prefs.getString('url')! + '/series');
    return url;
  }

  Future getSeriesList() async {
    return get(await getUrl()).then((data) {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final notes = <Series>[];
        for (var item in jsonData) {
          notes.add(Series.fromJSON(item));
        }
        final finalnotes = <Series>[];
        for (Series i in notes) {
          if (i.paused) {
            finalnotes.insert(0, i);
            continue;
          }
          finalnotes.add(i);
        }
        return (finalnotes);
      }
      print('API error code: ${data.statusCode}');
    });
  }

  Future<Object>? getSeries(int id) {
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
      return Null;
    });
  }

  sendData(String json) async {
    Map<String, String> headers = {"content-type": "application/json"};
    await post(await getUrl(), headers: headers, body: json);
  }

  deleteData(int id) async {
    Uri uri = await getUrl();
    String url = uri.toString();
    Uri deleteUrl = Uri.parse(url + '/$id');
    await delete(deleteUrl);
  }

  updateData(int id, String json) async {
    Uri uri = await getUrl();
    String url = uri.toString();
    Uri updateUrl = Uri.parse(url + '/$id');
    Map<String, String> headers = {"content-type": "application/json"};
    await put(updateUrl, headers: headers, body: json);
  }
}
