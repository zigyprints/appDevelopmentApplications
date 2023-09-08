import 'package:flutter/material.dart';

class DrawingScreenModel extends ChangeNotifier {
  Color selectedColor = Colors.black;
  Color currentColor = Colors.black;
  final List<Offset?> points = [];
  final List<Offset?> undonePoints = [];

  void changeColor(Color color) {
    selectedColor = color;
    currentColor = color;
    notifyListeners();
  }
  void undo() {
    if (points.isNotEmpty) {
      undonePoints.add(points.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (undonePoints.isNotEmpty) {
      points.add(undonePoints.removeLast());
      notifyListeners();
    }
  }
}
