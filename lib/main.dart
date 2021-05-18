import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:serien/services/API.dart';
import 'package:serien/views/cards.dart';

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
