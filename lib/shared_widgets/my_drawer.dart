// import 'package:camera/camera.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/documents/all_documents.dart';
import 'package:image_scanner/screens/gallery_view.dart';
import 'package:image_scanner/screens/take_picture.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:image_scanner/util/share_app.dart';

class MyDrawer extends StatefulWidget {
  static String className = 'MyDrawer';

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  capureImage() async {
    // AnalyticsService().sendEvent(
    //   name: 'capture_image_click',
    // );
    // ForegroundService.start('camera', '');
    // ForegroundService.registerCallBack("saveImage", handleImageBitMap);
    // Navigator.pop(context);
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePicture(camera: firstCamera),
      ),
    );
  }

  handleImageBitMap(data) {
    print('back to future');
  }

  launchURL() async {
    const url = 'https://malkeet.tech';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  // uploadImage() async {
  //   AnalyticsService().sendEvent(
  //     name: 'upload_image_click',
  //   );
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => GalleryView(),
  //     ),
  //   );
  // }

  allDocuments() async {
    AnalyticsService().sendEvent(
      name: 'drawer_documents',
    );
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllDocuments(),
      ),
    );
  }

  shareWithFirends() {
    AnalyticsService().sendEvent(
      name: 'share_with_friends',
    );
    var myText = ShareApp.message();

    var data = {"str": myText, "type": "text/plain"};
    ForegroundService.start("shareFile", data);
    Navigator.pop(context);
  }

  contactDeveloper() {
    AnalyticsService().sendEvent(
      name: 'contact_developer',
    );
    ForegroundService.start('sendEmail', '');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      width: 282.0,
      child: Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 100,
                child: DrawerHeader(
                  padding: EdgeInsets.only(left: 20, top: 30),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'digi',
                        style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                height: 24.0 / 24.0)
                            .copyWith(
                          color: Colors.deepOrange,
                        ),
                      ),
                      Text(
                        'paper',
                        style: TextStyle(
                                fontSize: 16.0,
                                // fontWeight: FontWeight.bold,
                                height: 24.0 / 16.0)
                            .copyWith(color: ColorShades.textSecGray3),
                      ),
                    ],
                  ),
                ),
              ),
              listItem(
                context,
                false,
                Icon(
                  Icons.folder_open,
                  color: Colors.grey,
                ),
                "Documents",
                () => allDocuments(),
              ),
              listItem(
                context,
                false,
                Icon(
                  Icons.content_copy,
                  color: Colors.grey,
                ),
                "Copy text from image",
                () => capureImage(),
              ),

              listItem(
                context,
                false,
                Icon(
                  Icons.alternate_email,
                  color: Colors.grey,
                ),
                "Contact us",
                () => contactDeveloper(),
              ),
              listItem(
                context,
                false,
                Icon(
                  Icons.mobile_screen_share,
                  color: Colors.grey,
                ),
                "Share with your friends",
                () => shareWithFirends(),
              ),
              listItem(
                context,
                false,
                Icon(
                  Icons.verified_user,
                  color: Colors.grey,
                ),
                "Privacy policy",
                () => launchURL(),
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
              //     color: Colors.grey,
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
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              listItem(
                context,
                true,
                Icon(
                  Icons.cloud_queue,
                  color: ColorShades.textSecGray2,
                ),
                "Save files to cloud",
                () => () {},
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // softWrap: true,
        style: Theme.of(context).textTheme.h4.copyWith(
              color: disabled == true
                  ? ColorShades.textSecGray2
                  : ColorShades.textSecGray3,
              fontSize: 16.0,
              // fontWeight: FontWeight.bold,
            ),
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
