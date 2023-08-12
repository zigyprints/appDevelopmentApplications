import 'dart:io';

import 'package:drawing_app/created_classes/drawing_point_class.dart';
import 'package:drawing_app/created_classes/options.dart';

import '../model.dart';
import 'package:flutter/material.dart';

class ShapeDrawerMixin {
  File _imageFile;

  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  //int nth = 1;

  void onPanDown(details, MyModel model, RenderBox renderBox) {
    model.changeGuides(true);

    if (model.optionSelected == Option.path) {
      addPointToPathContainer(model, renderBox, details);
    } else if (model.optionSelected == Option.line) {
      //RenderBox renderBox = context.findRenderObject();
      addFistPointToLineContainer(model, renderBox, details);
    } else if (model.optionSelected == Option.triangle) {
      //RenderBox renderBox = context.findRenderObject();
      addFirstPointToTraingleContainer(model, renderBox, details);
    }
  }

  void addFirstPointToTraingleContainer(
      MyModel model, RenderBox renderBox, details) {
    final point = DrawingPoint(
        nth: model.nth,
        drawingOption: model.optionSelected,
        points: renderBox.globalToLocal(details.globalPosition),
        paint: Paint()
          ..strokeCap = strokeCap
          ..isAntiAlias = true
          ..color = model.selectedColor.withOpacity(opacity)
          ..strokeWidth = model.strokeWidth);
    model.addToMap('triangleList', point);
    model.controlNth();
    if (point.nth == 2)
      model.changeMessage('Tap Point 3');
    else if (point.nth == 3)
      model.changeMessage('Tap Point 1');
    else
      model.changeMessage('Tap Point 2');
  }

  void addFistPointToLineContainer(
      MyModel model, RenderBox renderBox, details) {
    final point = DrawingPoint(
        nth: model.nth,
        drawingOption: model.optionSelected,
        points: renderBox.globalToLocal(details.globalPosition),
        paint: Paint()
          ..strokeCap = strokeCap
          ..isAntiAlias = true
          ..color = model.selectedColor.withOpacity(opacity)
          ..strokeWidth = model.strokeWidth);
    model.addToMap('lineList', point);
    model.controlNth();
    if (point.nth < 2)
      model.changeMessage('Tap Point 2');
    else
      model.changeMessage('Tap Point 1');
  }

  void addPointToPathContainer(MyModel model, RenderBox renderBox, details) {
    final point = DrawingPoint(
        nth: model.nth,
        drawingOption: model.optionSelected,
        points: renderBox.globalToLocal(details.globalPosition),
        paint: Paint()
          ..strokeCap = strokeCap
          ..isAntiAlias = true
          ..color = model.selectedColor.withOpacity(opacity)
          ..strokeWidth = model.strokeWidth);
    model.addToMap('pathList', point);
    model.controlNth();
    if (point.nth == 2)
      model.changeMessage('Tap Point 3');
    else if (point.nth == 3)
      model.changeMessage('Tap Point 1');
    else
      model.changeMessage('Tap Point 2');
  }

  void addStartPointToPointsContainer(
      BuildContext context,
      Option selectedOption,
      DragStartDetails details,
      Color selectedColor,
      MyModel model) {
    RenderBox renderBox = context.findRenderObject();
    final point = DrawingPoint(
        //nth: model.nth,
        type: PointType.Start,
        drawingOption: selectedOption,
        points: renderBox.globalToLocal(details.globalPosition),
        paint: Paint()
          ..strokeCap = strokeCap
          ..isAntiAlias = true
          ..color = selectedColor.withOpacity(opacity)
          ..strokeWidth = model.strokeWidth);
    model.addToMap('pointList', point);
    if (point.drawingOption == Option.hand) model.changeMessage('Shade');
  }

  void addTheNextPoints(BuildContext context, DragUpdateDetails details,
      Option selectedOption, Color selectedColor, MyModel model) {
    RenderBox renderBox = context.findRenderObject();
    var drawingPoints = renderBox.globalToLocal(details.globalPosition);

    final point = DrawingPoint(
        // nth: model.nth,
        drawingOption: selectedOption,
        points: drawingPoints,
        paint: Paint()
          ..strokeCap = strokeCap
          ..isAntiAlias = true
          ..color = selectedColor.withOpacity(opacity)
          ..strokeWidth = model.strokeWidth);
    model.addToMap('pointList', point);
  }
}
