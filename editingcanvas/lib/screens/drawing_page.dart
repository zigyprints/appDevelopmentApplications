import 'package:flutter/material.dart';
import 'package:editingcanvas/model/drawing_point.dart';
import 'package:editingcanvas/router.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});
  static const String routeName = '/drawing';

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

var drawingPoints = <DrawingPoint>[];
DrawingPoint? currentDrawingPoint;

class _DrawingPageState extends State<DrawingPage> {
  var availableColour = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

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
            child: Text(
              "Colours",
              style: TextStyle(fontSize: 20),
            ),
          ),
          GestureDetector(
            onPanStart: (details) {
              setState(() {
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
              setState(() {
                if (currentDrawingPoint == null) return;

                currentDrawingPoint = currentDrawingPoint?.copyWith(
                  offsets: currentDrawingPoint!.offsets
                    ..add(details.localPosition),
                );
                drawingPoints.last = currentDrawingPoint!;
                historyDrawingPoints = List.of(drawingPoints);
              });
            },
            onPanEnd: (_) {
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
            top: 80,
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
            top: MediaQuery.of(context).padding.top + 80,
            right: 0,
            bottom: 150,
            child: RotatedBox(
              quarterTurns: 3, // 270 degree
              child: Slider(
                value: selectedWidth,
                min: 1,
                max: 20,
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
          const SizedBox(width: 16),
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
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = drawingPoint.color
        ..isAntiAlias = true
        ..strokeWidth = drawingPoint.width
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        var notLastOffset = i != drawingPoint.offsets.length - 1;

        if (notLastOffset) {
          final current = drawingPoint.offsets[i];
          final next = drawingPoint.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        } else {
          /// we do nothing
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
