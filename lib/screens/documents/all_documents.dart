import 'dart:convert';

// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/documents/documents.dart';
import 'package:image_scanner/screens/image_scanner.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/my_drawer.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/storage_manager.dart';
import 'package:path_provider/path_provider.dart';

class AllDocuments extends StatefulWidget {
  const AllDocuments({
    Key key,
  }) : super(key: key);

  @override
  _AllDocumentsState createState() => _AllDocumentsState();
}

class _AllDocumentsState extends State<AllDocuments> {
  var userImages;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getUserImages() async {
    var res = await ForegroundService.start('getImages', '');
    return jsonDecode(res);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.deepOrange,
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        drawer: MyDrawer(),
        // backgroundColor: Colors.blueGrey,
        backgroundColor: ColorShades.textColorOffWhite,
        // backgroundColor: ColorShades.backgroundColorPrimary,
        appBar: AppBar(
          title: Text("All docs"),
          backgroundColor: Colors.deepOrange,
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Refresh',
                style: Theme.of(context).textTheme.body1Medium.copyWith(
                      color: Colors.white,
                    ),
              ),
              onPressed: () {
                setState(() {});
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 20,
                color: ColorShades.textColorOffWhite,
              ),
              FutureBuilder(
                  future: getUserImages(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    return Documents(
                      docs: snapshot.data,
                    );
                  }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            child: Icon(
              Icons.camera_alt,
            ),
            // Provide an onPressed callback.
            onPressed: () async {
              ForegroundService.start('camera', '');
              // ForegroundService.registerCallBack("saveImage", handleImageBitMap);
//               final cameras = await availableCameras();

// // Get a specific camera from the list of available cameras.
//               final firstCamera = cameras.first;
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ImageScanner(camera: firstCamera),
              //   ),
              // );
            }),
      ),
    );
  }
}
