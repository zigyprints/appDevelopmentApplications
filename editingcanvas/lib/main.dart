import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:editingcanvas/screens/drawing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colours',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black, // Icon color
        ),
      ),
      darkTheme: ThemeData(backgroundColor: Colors.black),
      themeMode: ThemeMode.dark,
      home: const DrawingPage(),
    );
  }
}
