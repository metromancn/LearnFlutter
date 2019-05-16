import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ZoomableImage extends StatefulWidget {
  final ImageProvider image;
  final double minScale;
  final double maxScale;
  final Color backgroundColor;

  ZoomableImage(this.image, { Key key, this.minScale = 0.25, this.maxScale = 2.0, this.backgroundColor = Colors.white }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  ui.Image _image;
  Offset _offset;
  double _scale;

  @override
  Widget build(BuildContext context) {
    var painter = new _ZoomableImagePainter(
        image: _image,
        offset: _offset,
        scale: _scale
    );
    var paint = new CustomPaint(
      child: new Container(color: widget.backgroundColor),
      foregroundPainter: painter,
    );
    return new GestureDetector(
      child: paint,
    );
  }
}

class _ZoomableImagePainter extends CustomPainter {
  final ui.Image image;
  final Offset offset;
  final double scale;

  const _ZoomableImagePainter({this.image, this.offset, this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    var imageSize = new Size(image.width.toDouble(), image.height.toDouble());
    var targetSize = imageSize * scale;
    var targetRect = offset & targetSize;
    paintImage(canvas: canvas, rect: targetRect, image: image, fit: BoxFit.fill);
  }

  @override
  bool shouldRepaint(_ZoomableImagePainter old) {
    return old.image != image || old.offset != offset || old.scale != scale;
  }
}