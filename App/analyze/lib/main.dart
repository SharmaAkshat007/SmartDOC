import 'package:flutter/material.dart';
import 'package:analyze/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predict',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Screen Layout Classifier'),
    );
  }
}
