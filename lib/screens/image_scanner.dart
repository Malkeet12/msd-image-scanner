import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_scanner/screens/document_details.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/util/storage_manager.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageScanner extends StatefulWidget {
  final CameraDescription camera;

  const ImageScanner({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  ImageScannerState createState() => ImageScannerState();
}

class ImageScannerState extends State<ImageScanner> {
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

  writeOnPdf(pdf, file) {
    final image = PdfImage.file(
      pdf.document,
      bytes: file.readAsBytesSync(),
    );
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Image(image),
      ); // Center
    }));
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Image(image),
      ); // Center
    }));
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }

  saveDoc(path) async {
    var userDocs = await StorageManager.getItem('userDocs') ?? "[]";
    userDocs = jsonDecode(userDocs);
    List images = [];
    images.add(path);
    // images.add(path);
    var rng = new Random();
    var uid = rng.nextInt(pow(10, 6));
    var obj = {
      "name": "Document${DateTime.now()}",
      "documentId": uid,
      "images": images,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    userDocs.add(obj);
    await StorageManager.setItem("userDocs", userDocs);
    return obj;
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
            Directory documentDirectory =
                await getApplicationDocumentsDirectory();

            String documentPath = documentDirectory.path;
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);
            File croppedFile = await ImageCropper.cropImage(
                sourcePath: path,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
                androidUiSettings: AndroidUiSettings(
                    toolbarTitle: 'Edit image',
                    toolbarColor: Colors.deepOrange,
                    toolbarWidgetColor: Colors.white,
                    initAspectRatio: CropAspectRatioPreset.original,
                    lockAspectRatio: false),
                iosUiSettings: IOSUiSettings(
                  minimumAspectRatio: 1.0,
                ));
            // final pdf = pw.Document();
            // writeOnPdf(pdf, croppedFile);
            // var rng = new Random();
            // var uid = rng.nextInt(pow(10, 6));
            // String fullPath = "$documentPath/msd12$uid.pdf";
            // File file = File(fullPath);
            // file.writeAsBytesSync(pdf.save());
            var doc = await saveDoc(
              croppedFile.path,
            );

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => DocumentDetails(
                          doc: doc,
                        )));
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
