import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class ZoomableWidget extends StatefulWidget {
  final Widget child;

  const ZoomableWidget({Key key, this.child}) : super(key: key);
  @override
  _ZoomableWidgetState createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  Matrix4 matrix = Matrix4.identity();
  Matrix4 orginal = Matrix4.identity();
  bool zoomedIn = false;
  // Matrix4 myMatrix = Matrix4.identity()..getMaxScaleOnAxis();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          matrix = orginal;
          zoomedIn = !zoomedIn;
        });
      },
      child: MatrixGestureDetector(
        shouldRotate: false,
        // shouldScale: true,
        // shouldTranslate: false,
        onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
          setState(() {
            matrix = m;
          });
        },
        child: Transform(
          transform: matrix,
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
