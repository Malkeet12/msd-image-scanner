import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_scanner/screens/take_picture.dart';
import 'package:image_scanner/screens/gallery_view.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Image Scanner',
    // Start the app with the "/" named route. In our case, the app will start
    // on the FirstScreen Widget
    initialRoute: '/',
    routes: {
      '/': (context) => MyApp(),
    },
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  capureImage() async {
    AnalyticsService().sendEvent(
      name: 'capture_image_click',
    );
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePicture(camera: firstCamera),
      ),
    );
  }

  detectObject() async {
    final picker = ImagePicker();
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      ForegroundService.start(pickedFile.path);
    }
  }

  uploadImage() async {
    AnalyticsService().sendEvent(
      name: 'upload_image_click',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryView(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorShades.backgroundColorPrimary,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorShades.backgroundColorPrimary,
        centerTitle: true,
        title: Text(
          'Image scanner',
          style: TextStyle(
            color: ColorShades.textColorOffWhite,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlueButton(
              onPressed: capureImage,
              text: 'Capture image',
            ),
            SizedBox(
              height: 20.0,
            ),
            BlueButton(
              onPressed: uploadImage,
              text: 'Pick from gallery',
            ),
            SizedBox(
              height: 20.0,
            ),
            BlueButton(
              onPressed: detectObject,
              text: 'Detect object',
            ),
            // BlueButton(
            //   onPressed: () async {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CopyTextWidget(),
            //       ),
            //     );
            //   },
            //   text: 'Copy text from image',
            // ),
          ],
        ),
      ),
    );
  }
}
