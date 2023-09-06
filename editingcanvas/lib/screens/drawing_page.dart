// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:editingcanvas/model/drawing_point.dart';
import 'package:editingcanvas/widgets/drawing_painter.dart';
import 'package:editingcanvas/providers/drawing_provider.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:editingcanvas/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});
  static const String routeName = '/drawing';

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  File? backgroundImage;
  Color selectedColor = Colors.black;

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
  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColor', selectedColor.value);
    await prefs.setDouble('selectedWidth', selectedWidth);
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('selectedColor');
    double? widthValue = prefs.getDouble('selectedWidth');

    if (colorValue != null) {
      setState(() {
        selectedColor = Color(colorValue);
      });
    }

    if (widthValue != null) {
      setState(() {
        selectedWidth = widthValue;
      });
      saveUserData();
    }
  }

  Future<void> fetchImageFromServer() async {
    const imageUrl =
        'https://fastly.picsum.photos/id/12/2500/1667.jpg?hmac=Pe3284luVre9ZqNzv1jMFpLihFI6lwq7TPgMSsNXw2w';
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/background_image.png');

      await tempFile.writeAsBytes(bytes);

      setState(() {
        backgroundImage = tempFile;
      });
    } else {
      // Handle error
      print('Failed to fetch image: ${response.statusCode}');
    }
  }

  Future<void> _pickImage() async {
    await fetchImageFromServer();

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        backgroundImage = File(pickedFile.path);
      });
    }
  }

  // Method to draw a circle
  void drawCircle() {
    setState(() {
      final center = Offset(200, 200);
      const radius = 50.0;
      const numSegments = 360;
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

  void clearBackgroundImage() {
    setState(() {
      backgroundImage = null;
    });
  }

  // Method to draw a rectangle
  void drawRectangle() {
    setState(() {
      final topLeft = Offset(100, 100);
      const width = 100.0;
      const height = 80.0;
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

  var selectedWidth = 2.0;
  @override
  void initState() {
    super.initState();
    loadUserData(); // Call the function to load user data here
  }

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
          if (backgroundImage != null)
            Positioned.fill(
              child: Image.file(
                backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(8.0),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onScaleStart: (details) {
              setState(() {
                isDrawing = true;
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final points = <Offset>[
                  renderBox.globalToLocal(details.focalPoint)
                ];

                currentDrawingPoint = DrawingPoint(
                  id: DateTime.now().microsecondsSinceEpoch,
                  offsets: points,
                  color: selectedColor,
                  width: selectedWidth,
                );

                if (currentDrawingPoint == null) return;
                drawingPoints.add(currentDrawingPoint!);
                historyDrawingPoints = List.of(drawingPoints);
              });
            },
            onScaleUpdate: (details) {
              if (isDrawing) {
                setState(() {
                  if (currentDrawingPoint == null) return;

                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final Offset localPosition =
                      renderBox.globalToLocal(details.focalPoint);

                  currentDrawingPoint = currentDrawingPoint?.copyWith(
                    offsets: [...currentDrawingPoint!.offsets, localPosition],
                  );
                  drawingPoints.last = currentDrawingPoint!;
                  historyDrawingPoints = List.of(drawingPoints);
                });
              }
            },
            onScaleEnd: (details) {
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
            top: 20,
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
              quarterTurns: 3,
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
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Row(
              children: [],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _pickImage,
                child: const Icon(Icons.image),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (Color color) {
                              setState(() {
                                selectedColor = color;
                              });
                              saveUserData();
                            },
                            showLabel: true,
                            pickerAreaHeightPercent: 0.8,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.palette),
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                onPressed: clearBackgroundImage,
                child: const Icon(Icons.clear),
              ),
              SizedBox(height: 8),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: "Undo",
                onPressed: () {
                  if (drawingPoints.isNotEmpty &&
                      historyDrawingPoints.isNotEmpty) {
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
            ],
          ),
        ],
      ),
    );
  }
}
