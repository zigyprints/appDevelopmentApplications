import 'package:flutter/material.dart';
import 'package:editingcanvas/model/drawing_point.dart';
import 'package:editingcanvas/widgets/drawing_painter.dart';
import 'dart:math';
import 'dart:io';

class NumberListProvider extends ChangeNotifier {
  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];
  DrawingPoint? currentDrawingPoint;
  File? backgroundImage;

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;
  void drawshapes() {
    notifyListeners(); //when theres change in list it will notify consumer widgets
  }

  void drawCircle() {
    final center = Offset(200, 200);
    final radius = 50.0;
    final numSegments = 360;
    final angleIncrement = (2 * 3.14159265359) / numSegments;
    final points = <Offset>[];

    for (var i = 0; i < numSegments; i++) {
      final x = center.dx + radius * cos(angleIncrement * i);
      final y = center.dy + radius * sin(angleIncrement * i);
      points.add(Offset(x, y));
    }

    final circleDrawingPoint = DrawingPoint(
      id: DateTime.now().microsecondsSinceEpoch,
      offsets: points,
      color: selectedColor,
      width: selectedWidth,
    );

    drawingPoints.add(circleDrawingPoint);
    historyDrawingPoints = List.of(drawingPoints);
  }

  void clearBackgroundImage() {
    backgroundImage = null;
  }

  // Method to draw a rectangle
  void drawRectangle() {
    final topLeft = Offset(100, 100);
    final width = 100.0;
    final height = 80.0;
    final points = <Offset>[
      topLeft,
      Offset(topLeft.dx + width, topLeft.dy),
      Offset(topLeft.dx + width, topLeft.dy + height),
      Offset(topLeft.dx, topLeft.dy + height),
      topLeft,
    ];

    final rectangleDrawingPoint = DrawingPoint(
      id: DateTime.now().microsecondsSinceEpoch,
      offsets: points,
      color: selectedColor,
      width: selectedWidth,
    );

    drawingPoints.add(rectangleDrawingPoint);
    historyDrawingPoints = List.of(drawingPoints);
  }

  // Method to draw a triangle
  void drawTriangle() {
    final point1 = Offset(150, 150);
    final point2 = Offset(200, 250);
    final point3 = Offset(100, 250);
    final points = <Offset>[point1, point2, point3, point1];

    final triangleDrawingPoint = DrawingPoint(
      id: DateTime.now().microsecondsSinceEpoch,
      offsets: points,
      color: selectedColor,
      width: selectedWidth,
    );

    drawingPoints.add(triangleDrawingPoint);
    historyDrawingPoints = List.of(drawingPoints);
  }
}
