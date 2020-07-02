import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_scanner/screens/edit_document/edit_document.dart';
import 'package:image_scanner/screens/pdf_viewer.dart';
import 'package:image_scanner/theme/style.dart';

class DocumentDetails extends StatelessWidget {
  final doc;

  DocumentDetails({this.doc});

  @override
  Widget build(BuildContext context) {
    var name = doc["name"];
    var images = doc["images"];
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: Text(
          name,
          style: TextStyle(
            color: ColorShades.textColorOffWhite,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewer(
                    doc: doc,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
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
                images.length,
                (index) {
                  return Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDoc(
                                doc: doc,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          child: Image.file(
                            File(
                              images[index],
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
    );
  }
}
