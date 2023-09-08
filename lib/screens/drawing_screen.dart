import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package for gallery access
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:app/model/drawing_screen_model.dart';

import '../model/drawing_painter.dart';

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final List<Offset?> points = [];
  final List<Offset?> undonePoints = []; // Store undone points
  Color selectedColor = Colors.black;
  Color currentColor = Colors.black;
  double strokeWidth = 5.0;
  bool isEraserMode = false;
  int _selectedIndex = 0; // Index for the selected bottom navigation item
  String? imagePath; // Store the path of the selected image

  @override
Widget build(BuildContext context) {
  final drawingModel = Provider.of<DrawingScreenModel>(context);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Drawing Screen'),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () {
            drawingModel.undo(); // Call the undo method from your model
          },
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: () {
            drawingModel.redo(); // Call the redo method from your model
          },
        ),
      ],
    ),
    body: Column(
  children: [
    Expanded(
      child: GestureDetector(
        onPanUpdate: (details) {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          if (_selectedIndex == 0) {
            // Check if Pencil icon is selected
            if (!isEraserMode) {
              points.add(localPosition);
            } else {
              // In eraser mode, remove points that are close to the touch point.
              points.removeWhere((point) =>
                  point != null &&
                  (point - localPosition).distance < strokeWidth);
            }
            drawingModel.notifyListeners();
          }
        },
        onPanEnd: (details) {
          // When the user lifts their finger, add a null point to separate strokes.
          points.add(null);
          undonePoints.clear(); // Clear undone points when a new drawing action is performed
        },
        child: Stack(
          children: [
            if (imagePath != null)
              Positioned.fill(
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            CustomPaint(
              painter: DrawingPainter(points, currentColor, strokeWidth),
              size: Size.infinite,
            ),
          ],
        ),
      ),
    ),
  ],
),

    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          // Handle bottom navigation item selection here
          if (index == 1) {
            // Eraser icon selected
            setState(() {
              isEraserMode = true;
              _selectedIndex = 0; // Set the navbar index to Pencil
              points.clear(); // Clear all drawing points
              undonePoints.clear(); // Clear undone points
              //remove the image
              imagePath = null;
            });
          } else if (index == 0) {
            // Pencil icon selected
            setState(() {
              isEraserMode = false;
              currentColor = selectedColor; // Set current color to selected color
            });
          } else if (index == 2) {
            // Color picker icon selected
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pick a color'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: currentColor,
                      onColorChanged: (color) {
                        setState(() {
                          selectedColor = color;
                          isEraserMode =
                              false; // Exit eraser mode when picking a color.
                          _selectedIndex = 0; // Set the navbar index to Pencil
                          points.clear(); // Clear all drawing points
                          undonePoints.clear(); // Clear undone points
                        });
                      },
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else if (index == 3) {
            // Gallery icon selected
            _pickImageFromGallery(); // Function to pick an image from the gallery
          }
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.create,
            color: Colors.black,
            size: 28,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.check_box_outline_blank_outlined,
            color: Colors.black,
            size: 28,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.color_lens,
            color: Colors.black,
            size: 28,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.photo_library,
            color: Colors.black,
            size: 28,
          ),
          label: '',
        ),
      ],
    ),
  );
}

// Function to pick an image from the gallery
_pickImageFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      imagePath = pickedFile.path;
      points.clear();
      undonePoints.clear();
    });
  }
}
}

