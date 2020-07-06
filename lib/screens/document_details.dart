import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/edit_document/edit_document.dart';
import 'package:image_scanner/screens/pdf_viewer.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/edit_name_dialog.dart';
import 'package:image_scanner/shared_widgets/img_preview.dart';
import 'package:image_scanner/theme/style.dart';

class DocumentDetails extends StatefulWidget {
  @override
  _DocumentDetailsState createState() => _DocumentDetailsState();
}

class _DocumentDetailsState extends State<DocumentDetails> {
  TextEditingController _controller = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ForegroundService.registerCallBack("refreshCurrentDoc", refreshCurrentDoc);
  }

  refreshCurrentDoc() async {
    BlocProvider.of<GlobalBloc>(context).add(GetCurrentDocument());
  }

  void _showDialog(context, name) {
    _controller.text = name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditNameDialog(controller: _controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, Map>(builder: (context, currentState) {
      var docs = currentState['doc']['data'];
      var name = currentState['doc']['name'];
      return Scaffold(
        backgroundColor: ColorShades.textColorOffWhite,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.deepOrange,
          centerTitle: true,
          title: Text(
            name.toString(),
            style: TextStyle(
              color: ColorShades.textColorOffWhite,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                _showDialog(context, name);
              },
            ),
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewer(doc: docs, name: name),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 90.0),
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
                  crossAxisSpacing: 20,
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
                                    carouselInitialPage: index,
                                  ),
                                ),
                              );
                            },
                            child: ImgPreview(
                              path: docs[index]["path"],
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              height: 170.0,
                            ),
                          ),
                          Positioned(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: new BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                (index + 1).toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        color: ColorShades.textColorOffWhite),
                              ),
                            ),
                            bottom: 14,
                            left: 14,
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              child: Icon(
                Icons.camera_alt,
              ),
              onPressed: () async {
                BlocProvider.of<GlobalBloc>(context)
                    .add(AddToCurrentDocument(name: name));
              }),
        ),
      );
    });
  }
}
