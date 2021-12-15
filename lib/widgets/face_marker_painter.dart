import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FacePainter extends CustomPainter {
  FacePainter({required this.imageSize, required this.face});
  final Size imageSize;
  double scaleX = 0.0;
  double scaleY = 0.0;
  final Face face;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint;
    double? _headEulerAngleY = face.headEulerAngleY;
    if (_headEulerAngleY != null) {
      if (_headEulerAngleY > 10 || _headEulerAngleY < -10) {
        paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..color = Colors.red;
      } else {
        paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.green;
      }

      scaleX = size.width / imageSize.width;
      scaleY = size.height/ imageSize.height;
      canvas.drawRRect(
          _scaleRect(
              rect: face.boundingBox,
              imageSize: imageSize,
              widgetSize: size,
              scaleX: scaleX,
              scaleY: scaleY),
          paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
  }
}

RRect _scaleRect(
    {required Rect rect,
    required Size imageSize,
    required Size widgetSize,
    required double scaleX,
    required double scaleY}) {
  return RRect.fromLTRBR(
    (widgetSize.width - rect.left.toDouble() * scaleX),
    rect.top.toDouble() * scaleY,
    widgetSize.width - rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
    const Radius.circular(10),

  );
}
