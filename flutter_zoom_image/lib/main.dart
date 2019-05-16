import 'package:flutter/material.dart';
import 'package:flutter_zoom_image/zoomable_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        body: new ZoomableImage(new AssetImage('images/routemap_sh_cn.png')),
      ),
    );
  }
}

