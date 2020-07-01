import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';

class DetectObject extends StatefulWidget {
  final camera;
  const DetectObject({Key key, this.camera}) : super(key: key);

  @override
  _DetectObjectState createState() => _DetectObjectState();
}

class _DetectObjectState extends State<DetectObject> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();

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

  onCaptureImage() async {
    final picker = ImagePicker();
    var pickedFile = await picker.getImage(source: ImageSource.gallery);

    ForegroundService.start(pickedFile.path);
    // try {
    //   // Ensure that the camera is initialized.
    //   await _initializeControllerFuture;

    //   // Construct the path where the image should be saved using the
    //   // pattern package.
    //   final path = join(
    //     // Store the picture in the temp directory.
    //     // Find the temp directory using the `path_provider` plugin.
    //     (await getTemporaryDirectory()).path,
    //     '${DateTime.now()}.png',
    //   );
    //   await _controller.takePicture(path);
    //   var labels = [];
    //   var completeDoc;
    //   try {
    //     var image = FirebaseVisionImage.fromFilePath(
    //         "/data/user/0/msd.image_scanner/cache/image_picker6231090678418393932.jpg");
    //     final List<ImageLabel> cloudLabels =
    //         await cloudLabeler.processImage(image);
    //     print(cloudLabels);
    //     for (ImageLabel label in labels) {
    //       final String text = label.text;
    //       final String entityId = label.entityId;
    //       final double confidence = label.confidence;
    //     }
    //     // Attempt to take a picture and log where it's been saved.
    //   } catch (e) {
    //     print(e.toString());
    //   }
    // } catch (e) {
    //   print(e.toString());
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: MyAppBar(text: 'Detect object'),
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
        onPressed: onCaptureImage,
      ),
    ));
  }
}
