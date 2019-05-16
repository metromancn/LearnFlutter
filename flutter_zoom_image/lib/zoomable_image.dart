import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ZoomableImage extends StatefulWidget {
  final ImageProvider image;
  final double maxScale;
  final double minScale;
  final GestureTapCallback onTap;
  final Color backgroundColor;
  final Widget placeholder;

  ZoomableImage(
      this.image, {
        Key key,
        this.maxScale = 2.0,
        this.minScale = 0.25,
        this.onTap,
        this.backgroundColor = Colors.black,
        this.placeholder,
      }) : super(key: key);

  @override
  _ZoomableImageState createState() => new _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  ImageStream _imageStream;
  ui.Image _image;
  Size _imageSize;
  Size _canvasSize;
  Orientation _previousOrientation;
  Offset _startingFocalPoint;
  Offset _previousOffset;
  Offset _offset;
  double _previousScale;
  double _scale;

  //Gesture
  Function() _handleDoubleTap(BuildContext ctx) {
    return () {
      var newScale = _scale * 2.0;
      if (newScale > widget.maxScale) {
        _centerAndScaleImage();
        setState(() {});
        return;
      }
      var center = ctx.size.center(Offset.zero);
      var newOffset = _offset - (center - _offset);
      setState(() {
        _scale = newScale;
        _offset = newOffset;
      });
    };
  }

  void _handleScaleStart(ScaleStartDetails d) {
    print("starting scale at ${d.focalPoint} from $_offset $_scale");
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _previousScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    var newScale = _previousScale * d.scale;
    if (newScale > widget.maxScale || newScale < widget.minScale) {
      return;
    }
    final normalizedOffset = (_startingFocalPoint - _previousOffset) / _previousScale;
    final newOffset = d.focalPoint - normalizedOffset * newScale;
    setState(() {
      _scale = newScale;
      _offset = newOffset;
    });
  }

  //Event
  @override
  Widget build(BuildContext ctx) {
    Widget paintWidget() {
      return new CustomPaint(
        child: new Container(color: widget.backgroundColor),
        foregroundPainter: new _ZoomableImagePainter(
          image: _image,
          offset: _offset,
          scale: _scale,
        ),
      );
    }
    if (_image == null) {
      return widget.placeholder ?? Center(child: CircularProgressIndicator());
    }
    return new LayoutBuilder(builder: (ctx, constraints) {
      Orientation orientation = MediaQuery.of(ctx).orientation;
      if (orientation != _previousOrientation) {
        _previousOrientation = orientation;
        _canvasSize = constraints.biggest;
        _centerAndScaleImage();
      }
      return new GestureDetector(
        child: paintWidget(),
        onTap: widget.onTap,
        onDoubleTap: _handleDoubleTap(ctx),
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
      );
    });
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _resolveImage();
    super.reassemble();
  }

  @override
  void dispose() {
    _imageStream.removeListener(_handleImageLoaded);
    super.dispose();
  }

  //Refresh
  void _resolveImage() {
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    _imageStream.addListener(_handleImageLoaded);
  }

  void _handleImageLoaded(ImageInfo info, bool synchronousCall) {
    print("image loaded: $info");
    setState(() {
      _image = info.image;
    });
  }

  //Other
  void _centerAndScaleImage() {
    _imageSize = new Size(_image.width.toDouble(), _image.height.toDouble());
    _scale = math.max(_canvasSize.width / _imageSize.width, _canvasSize.height / _imageSize.height);
    _scale = math.max(_scale, widget.minScale);
    _scale = math.min(_scale, 1.0);
    _offset = new Offset((_canvasSize.width - _imageSize.width * _scale) / 2.0, (_canvasSize.height - _imageSize.height * _scale) / 2.0);
    print(_scale);
  }
}

class _ZoomableImagePainter extends CustomPainter {
  final ui.Image image;
  final Offset offset;
  final double scale;

  const _ZoomableImagePainter({this.image, this.offset, this.scale});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    var imageSize = new Size(image.width.toDouble(), image.height.toDouble());
    var targetSize = imageSize * scale;
    paintImage(
      canvas: canvas,
      rect: offset & targetSize,
      image: image,
      fit: BoxFit.fill,
    );
  }

  @override
  bool shouldRepaint(_ZoomableImagePainter old) {
    return old.image != image || old.offset != offset || old.scale != scale;
  }
}