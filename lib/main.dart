import 'package:flutter/material.dart';
import 'connect/connect_page.dart';

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
      home: const ConnectPage(),
    );
  }
}
