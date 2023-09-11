import 'package:flutter/material.dart';
import 'package:blue_beacon/test.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '\one',
      routes: {
        '\one': (context) => TestApp(),
      },
    );
  }
}
