import 'package:flutter/material.dart';
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

  

  @override
  Widget build(BuildContext context) {
    final drawingModel = Provider.of<DrawingScreenModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing Screen'),
        actions: [
         IconButton(
          icon: Icon(Icons.undo),
          onPressed: () {
            drawingModel.undo(); // Call the undo method from your model
          },
        ),
        IconButton(
          icon: Icon(Icons.redo),
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
                final localPosition =
                    renderBox.globalToLocal(details.globalPosition);
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
                undonePoints.clear(); // Clear undone points when new drawing action is performed
              },
              child: CustomPaint(
                painter: DrawingPainter(points, currentColor, strokeWidth),
                size: Size.infinite,
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
                    title: Text('Pick a color'),
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
                        showLabel: true,
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else if (index == 3) {
              // Gallery icon selected (You can navigate to the gallery screen here)
              // Implement gallery functionality or navigation as needed.
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.create,
              color: Colors.black,
              size: 28,
            ), // Pencil icon
            label: '', // Set label to an empty string
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check_box_outline_blank_outlined,
              color: Colors.black,
              size: 28,
            ), // Eraser icon
            label: '', // Set label to an empty string
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.color_lens,
              color: Colors.black,
              size: 28,
            ), // Color picker icon
            label: '', // Set label to an empty string
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_library,
              color: Colors.black,
              size: 28,
            ), // Gallery icon
            label: '', // Set label to an empty string
          ),
        ],
      ),
    );
  }
}
