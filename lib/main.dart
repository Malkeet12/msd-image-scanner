// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/state.dart';
import 'package:image_scanner/screens/documents/all_documents.dart';
// import 'package:image_scanner/screens/take_picture.dart';
import 'package:image_scanner/screens/gallery_view.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/my_drawer.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<GlobalBloc>(
          create: (BuildContext context) => GlobalBloc(GlobalState.appState),
        ),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'Image Scanner',
        // Start the app with the "/" named route. In our case, the app will start
        // on the FirstScreen Widget
        initialRoute: '/',
        routes: {
          '/': (context) => AllDocuments(),
        },
      ),
    );
  }
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
//     // Obtain a list of the available cameras on the device.
//     final cameras = await availableCameras();

// // Get a specific camera from the list of available cameras.
//     final firstCamera = cameras.first;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TakePicture(camera: firstCamera),
//       ),
//     );
  }

  uploadImage() async {
    AnalyticsService().sendEvent(
      name: 'upload_image_click',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryView(),
      ),
    );
  }

  scanImage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllDocuments(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
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
              onPressed: scanImage,
              text: 'Scan image',
            ),
            SizedBox(
              height: 20.0,
            ),
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
