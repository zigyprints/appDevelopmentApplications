import 'package:editingcanvas/screens/drawing_page.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case DrawingPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const DrawingPage(),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page doesnt exist')),
        ),
      );
  }
}
