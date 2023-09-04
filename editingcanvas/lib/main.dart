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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 84, 128, 224),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(backgroundColor: Colors.black),
      themeMode: ThemeMode.dark,
      home: DrawingPage(),
    );
  }
}
