import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/edit_document/edit_document.dart';
import 'package:image_scanner/screens/pdf_viewer.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/theme/style.dart';

class DocumentDetails extends StatefulWidget {
  @override
  _DocumentDetailsState createState() => _DocumentDetailsState();
}

class _DocumentDetailsState extends State<DocumentDetails> {
  TextEditingController _controller = new TextEditingController();
  var inputValue;
  void _showDialog(context, name) {
    _controller.text = name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Rename",
            style: Theme.of(context)
                .textTheme
                .h3
                .copyWith(color: ColorShades.textSecGray3),
          ),
          content: TextField(
            autofocus: true,
            controller: _controller,
            onChanged: (value) {
              setState(() {
                inputValue = value;
              });
            },
            maxLength: 30,
            style: Theme.of(context).textTheme.body1Medium,
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "Close",
                style: Theme.of(context)
                    .textTheme
                    .h4
                    .copyWith(color: ColorShades.textSecGray3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "OK",
                style: Theme.of(context)
                    .textTheme
                    .h3
                    .copyWith(color: Colors.blueAccent),
              ),
              onPressed: () {
                BlocProvider.of<GlobalBloc>(context)
                    .add(RenameDocument(name: inputValue));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
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
            name,
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
                                  .copyWith(
                                      color: ColorShades.textColorOffWhite),
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              child: Icon(
                Icons.camera_alt,
              ),
              // Provide an onPressed callback.
              onPressed: () async {
                // var documentPath = docs[0].split("/");
                // var groupId = documentPath[documentPath.length - 2];
                // ForegroundService.start('gallery', name);

                BlocProvider.of<GlobalBloc>(context)
                    .add(AddToCurrentDocument(name: name));
              }),
        ),
      );
    });
  }
}
