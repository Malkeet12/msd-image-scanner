import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/build_list.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/text_decoration.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:mlkit/mlkit.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<VisionText> _currentLabels = <VisionText>[];

  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(text: 'Capture image'),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);
            var currentLabels;
            try {
              currentLabels = await detector.detectFromPath(path);

              setState(() {
                _currentLabels = currentLabels;
              });
            } catch (e) {
              print(e.toString());
            }
            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                    imagePath: path, currentLabels: currentLabels),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final currentLabels;

  const DisplayPictureScreen({Key key, this.imagePath, this.currentLabels})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _fullString = '';
    for (var i = 0; i < currentLabels.length; i++) {
      _fullString += currentLabels[i].text + ' ';
    }
    var _currentLabels = currentLabels;
    return Scaffold(
      backgroundColor: ColorShades.backgroundColorPrimary,
      appBar: MyAppBar(text: 'Display the Picture'),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: FutureBuilder<Size>(
                future: CommonUtil.getImageSize(Image.file(
                  File(imagePath),
                )),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            TextDetectDecoration(_currentLabels, snapshot.data),
                        child:
                            Image.file(File(imagePath), fit: BoxFit.fitWidth));
                  } else {
                    return Text('Detecting...');
                  }
                },
              ),
            ),

            // Image.file(File(imagePath)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: BlueButton(
                text: 'Share consolidated document',
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  Share.share(_fullString,
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size);
                },
              ),
            ),
            BuildList(texts: currentLabels),
          ],
        ),
      ),
    );
  }
}
