import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/documents/documents.dart';
import 'package:image_scanner/screens/image_scanner.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/storage_manager.dart';

class UserDocumentsView extends StatelessWidget {
  const UserDocumentsView({
    Key key,
  }) : super(key: key);

  getUserDocuments() async {
    var userDocuments = await StorageManager.getItem("userDocs") ?? "[]";
    return jsonDecode(userDocuments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        text: "All docs",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: getUserDocuments(),
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
            final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
            final firstCamera = cameras.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageScanner(camera: firstCamera),
              ),
            );
          }),
    );
  }
}
