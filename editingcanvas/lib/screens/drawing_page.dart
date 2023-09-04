import 'package:flutter/material.dart';
import 'package:editingcanvas/model/drawing_point.dart';
import 'package:editingcanvas/widgets/drawing_painter.dart';
import 'dart:math';

import 'package:editingcanvas/router.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});
  static const String routeName = '/drawing';
  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  var availableColour = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.orange,
    Colors.purple,
  ];
  bool isDrawing = false;
  // Method to draw a circle
  void drawCircle() {
    setState(() {
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
    });
  }

  // Method to draw a rectangle
  void drawRectangle() {
    setState(() {
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
    });
  }

  // Method to draw a triangle
  void drawTriangle() {
    setState(() {
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
    });
  }

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];
  DrawingPoint? currentDrawingPoint;

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EditingCanvas",
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Stack(
        children: [
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Colours",
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                isDrawing = true;
                currentDrawingPoint = DrawingPoint(
                  id: DateTime.now().microsecondsSinceEpoch,
                  offsets: [
                    details.localPosition,
                  ],
                  color: selectedColor,
                  width: selectedWidth,
                );

                if (currentDrawingPoint == null) return;
                drawingPoints.add(currentDrawingPoint!);
                historyDrawingPoints = List.of(drawingPoints);
              });
            },
            onPanUpdate: (details) {
              if (isDrawing) {
                setState(() {
                  if (currentDrawingPoint == null) return;

                  currentDrawingPoint = currentDrawingPoint?.copyWith(
                    offsets: currentDrawingPoint!.offsets
                      ..add(details.localPosition),
                  );
                  drawingPoints.last = currentDrawingPoint!;
                  historyDrawingPoints = List.of(drawingPoints);
                });
              }
            },
            onPanEnd: (_) {
              isDrawing = false;
              currentDrawingPoint = null;
            },
            child: CustomPaint(
              painter: DrawingPainter(
                drawingPoints: drawingPoints,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableColour.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = availableColour[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: availableColour[index],
                        shape: BoxShape.circle,
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: selectedColor == availableColour[index]
                            ? Border.all(color: Colors.black, width: 4)
                            : null,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            right: 0,
            bottom: 200,
            child: RotatedBox(
              quarterTurns: 3, // 270 degree
              child: Slider(
                value: selectedWidth,
                min: 1,
                max: 25,
                onChanged: (value) {
                  setState(
                    () {
                      selectedWidth = value;
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: "Undo",
            onPressed: () {
              if (drawingPoints.isNotEmpty && historyDrawingPoints.isNotEmpty) {
                setState(() {
                  drawingPoints.removeLast();
                });
              }
            },
            child: const Icon(Icons.undo),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: "Redo",
            onPressed: () {
              setState(() {
                if (drawingPoints.length < historyDrawingPoints.length) {
                  final index = drawingPoints.length;
                  drawingPoints.add(historyDrawingPoints[index]);
                }
              });
            },
            child: const Icon(Icons.redo),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: "Clear",
            onPressed: () {
              setState(() {
                drawingPoints.clear();
                historyDrawingPoints.clear();
              });
            },
            child: const Icon(Icons.clear),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: "Circle",
            onPressed: drawCircle,
            child: const Icon(Icons.circle_outlined),
          ),
          const SizedBox(width: 8),
          // Button to draw a rectangle
          FloatingActionButton(
            heroTag: "Rectangle",
            onPressed: drawRectangle,
            child: const Icon(Icons.crop_square),
          ),
          const SizedBox(width: 8),
          // Button to draw a triangle
          FloatingActionButton(
            heroTag: "Triangle",
            onPressed: drawTriangle,
            child: const Icon(Icons.change_history),
          ),

          // Button to draw an oval
          /* FloatingActionButton(
            heroTag: "Oval",
            onPressed: drawOval,
            child: const Icon(Icons.ellipse),
          ), */
        ],
      ),
    );
  }
}
