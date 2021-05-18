import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  final Function callback;

  Settings(this.callback);

  @override
  _SettingsState createState() => _SettingsState(this.callback);
}

class _SettingsState extends State<Settings> {
  final Function callback;

  final settingsKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  String url;
  TextEditingController ipController = TextEditingController();

  _SettingsState(this.callback);

  @override
  void initState() {
    getIP();
    super.initState();
  }

  getIP() async {
    prefs = await SharedPreferences.getInstance();
    url = prefs.getString('url') ?? '';
    ipController.text = url.replaceAll('http://', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
              key: settingsKey,
              child: TextFormField(
                controller: ipController,
                initialValue: url,
                decoration: InputDecoration(
                    helperText: 'IP-Adresse',
                    hintText: 'e.g. 192.168.178.22:5000'),
                validator: (value) {
                  RegExp regEx =
                      RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,5}');
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  } else if (!regEx.hasMatch(value)) {
                    return 'Not a valid IP Adress. Make sure you specify the address and the port.';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (settingsKey.currentState.validate()) {
                  Navigator.of(context).pop();
                  prefs.setString('url', 'http://' + ipController.text);
                  callback();
                }
              },
              icon: Icon(Icons.check),
              label: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
