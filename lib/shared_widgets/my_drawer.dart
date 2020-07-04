// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/documents/all_documents.dart';
import 'package:image_scanner/screens/gallery_view.dart';
// import 'package:image_scanner/screens/take_picture.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';

class MyDrawer extends StatefulWidget {
  static String className = 'MyDrawer';

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  capureImage() async {
    AnalyticsService().sendEvent(
      name: 'capture_image_click',
    );
    ForegroundService.start();
    // Obtain a list of the available cameras on the device.
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
        builder: (context) => GalleryView(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  allDocuments() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllDocuments(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      width: 282.0,
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            // DrawerHeader(
            //   child: Text('Drawer Header'),
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            // ),
            SizedBox(
              height: 24,
            ),
            listItem(
              context,
              Icon(
                Icons.folder,
                color: Colors.deepOrange,
              ),
              "All Documents",
              () => allDocuments(),
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 16,
                top: 32,
              ),
              child: Text(
                'Extract Text',
                softWrap: true,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Colors.lightBlue,
                      // fontFamily: 'Rounded Mplus 1c',
                      fontSize: 16.0,
                      // fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            listItem(
              context,
              Icon(
                Icons.camera_alt,
                color: Colors.deepOrange,
              ),
              "Capture Image",
              () => capureImage(),
            ),
            listItem(
              context,
              Icon(
                Icons.image,
                color: Colors.deepOrange,
              ),
              "Pick From Gallery",
              () => uploadImage(),
            ),
          ],
        ),
      ),
    ));
  }
}

InkWell listItem(BuildContext context, icon, String text, Function onTap) {
  List<Widget> children = <Widget>[];
  children.add(
    Padding(
      padding: const EdgeInsets.only(left: 20, right: 16),
      child: icon,
    ),
  );
  children.add(
    Expanded(
      child: Text(
        text,
        softWrap: true,
        style: Theme.of(context).textTheme.h4.copyWith(
            color: Colors.deepOrange,
            fontFamily: 'Rounded Mplus 1c',
            fontSize: 16.0,
            fontWeight: FontWeight.bold),
      ),
    ),
  );

  return InkWell(
    onTap: onTap,
    child: Container(
      height: 42.0,
      margin: EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: children,
      ),
    ),
  );
}
