import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<Offset?> points; // Use nullable Offset here
  final Color color;
  final double strokeWidth;
  final ImageProvider<Object>? backgroundImage;

  DrawingPainter(this.points, this.color, this.strokeWidth, {this.backgroundImage});

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      final Rect rect = Offset.zero & size;
      final Paint paint = Paint();
      paint.color = Colors.white; // You can set a background color here if needed
      canvas.drawRect(rect, paint);

      // Load the background image and draw it
      final image = backgroundImage!.resolve(ImageConfiguration.empty);
      image.addListener(ImageStreamListener((ImageInfo info, bool _) {
        canvas.drawImageRect(
          info.image,
          Rect.fromLTRB(0, 0, info.image.width.toDouble(), info.image.height.toDouble()),
          rect,
          Paint(),
        );
      }));
    }

    final Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Check if the points are not null before drawing
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
