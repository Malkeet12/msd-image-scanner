import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/image_preview.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class TakePicture extends StatefulWidget {
  final CameraDescription camera;

  const TakePicture({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();

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
      enableAudio: false,
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
            var labels = [];
            var completeDoc;
            try {
              File file = File(path);
              var image = FirebaseVisionImage.fromFile(file);
              final VisionText visionText =
                  await textRecognizer.processImage(image);
              completeDoc = visionText.text;
              for (TextBlock block in visionText.blocks) {
                final Rect boundingBox = block.boundingBox;
                final List<Offset> cornerPoints = block.cornerPoints;
                final String text = block.text;
                final List<RecognizedLanguage> languages =
                    block.recognizedLanguages;
                for (TextLine line in block.lines) {
                  labels.add(line);
                  for (TextElement element in line.elements) {
                    // Same getters as TextBlock
                  }
                }
              }
            } catch (e) {
              print(e.toString());
            }
            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImagePreview(
                  imagePath: path,
                  currentLabels: labels,
                  completeDoc: completeDoc,
                ),
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
