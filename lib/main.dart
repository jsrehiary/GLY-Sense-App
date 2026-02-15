import 'package:flutter/material.dart';
import 'package:glysense_prototipe/connect/connect_page.dart';
// import 'home/pages/home_page.dart';

void main() {
  runApp(const GlySenseApp());
}

class GlySenseApp extends StatelessWidget {
  const GlySenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gly-Sense',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ConnectPage(),
    );
  }
}
