// import 'package:camera/camera.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_scanner/screens/documents/all_documents.dart';
import 'package:image_scanner/screens/gallery_view.dart';
// import 'package:image_scanner/screens/take_picture.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:image_scanner/util/constants.dart';

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
    ForegroundService.start('camera', '');
    ForegroundService.registerCallBack("saveImage", handleImageBitMap);
    Navigator.pop(context);
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

  handleImageBitMap(data) {
    print('back to future');
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
    var colors = Constants.MY_COLORS;
    var uid = CommonUtil.getRandomNumber(5);
    return SafeArea(
        child: Container(
      width: 282.0,
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Container(
          // color: Colors.white60,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 100,
                child: DrawerHeader(
                  padding: EdgeInsets.only(left: 20, top: 30),
                  child: Text(
                    'Image Scanner',
                    style: Theme.of(context)
                        .textTheme
                        .h2
                        .copyWith(color: ColorShades.textPrimaryDark),
                  ),
                  decoration: BoxDecoration(
                      // color: Colors.white60,
                      ),
                ),
              ),
              // SizedBox(
              //   height: 24,
              // ),
              listItem(
                context,
                false,
                Icon(
                  Icons.folder,
                  color: colors[uid],
                ),
                "All Documents",
                () => allDocuments(),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //     left: 20,
              //     right: 16,
              //     top: 24,
              //   ),
              //   child: Text(
              //     'Extract text from image',
              //     softWrap: true,
              //     style: Theme.of(context).textTheme.body2Medium.copyWith(
              //           color: Colors.blueAccent,
              //           // fontFamily: 'Rounded Mplus 1c',
              //           fontSize: 16.0,
              //           fontWeight: FontWeight.bold,
              //         ),
              //   ),
              // ),
              // SizedBox(
              //   height: 8,
              // ),
              // listItem(
              //   context,
              //   false,
              //   Icon(
              //     Icons.camera_alt,
              //     color: colors[uid + 1],
              //   ),
              //   "Capture Image",
              //   () => capureImage(),
              // ),
              // listItem(
              //   context,
              //   false,
              //   Icon(
              //     Icons.image,
              //     color: colors[uid + 2],
              //   ),
              //   "Pick From Gallery",
              //   () => uploadImage(),
              // ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 16,
                  top: 24,
                ),
                child: Text(
                  'Coming Soon',
                  softWrap: true,
                  style: Theme.of(context).textTheme.body2Medium.copyWith(
                        color: Colors.green,
                        // fontFamily: 'Rounded Mplus 1c',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              listItem(
                context,
                true,
                Icon(
                  Icons.cloud,
                  color: colors[uid + 2],
                ),
                "Save files to cloud",
                () => uploadImage(),
              ),
              listItem(
                context,
                true,
                Icon(
                  Icons.find_in_page,
                  color: colors[uid + 2],
                ),
                "Copy text from image",
                () => uploadImage(),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

InkWell listItem(
    BuildContext context, disabled, icon, String text, Function onTap) {
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
            color: disabled == true
                ? ColorShades.textSecGray2
                : ColorShades.textSecGray3,
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
