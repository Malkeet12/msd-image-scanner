import 'dart:io';

// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/edit_document/edit_document.dart';
import 'package:image_scanner/screens/image_scanner.dart';
import 'package:image_scanner/screens/pdf_viewer.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/storage_manager.dart';

class DocumentDetails extends StatelessWidget {
  final docs;

  DocumentDetails({this.docs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorShades.textColorOffWhite,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: Text(
          'name',
          style: TextStyle(
            color: ColorShades.textColorOffWhite,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewer(
                    doc: docs,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewer(
                    doc: docs,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              GridView.count(
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                // childAspectRatio: 0.8,
                children: List.generate(
                  docs.length,
                  (index) {
                    return Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDoc(
                                  doc: docs,
                                  carouselInitialPage: index,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            child: Image.file(
                              File(
                                docs[index],
                              ),
                              fit: BoxFit.fill,
                              // width: double.maxFinite,
                            ),
                          ),
                        ),
                        Positioned(
                          child: Text(
                            (index + 1).toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: ColorShades.textColorOffWhite),
                          ),
                          bottom: 4,
                          left: 4,
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          child: Icon(
            Icons.camera_alt,
          ),
          // Provide an onPressed callback.
          onPressed: () async {
            // final cameras = await availableCameras();
            // final firstCamera = cameras.first;
            // await StorageManager.setItem(
            //     "currentDocumentId", doc["documentId"]);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ImageScanner(camera: firstCamera),
            //   ),
            // );
          }),
    );
  }
}
