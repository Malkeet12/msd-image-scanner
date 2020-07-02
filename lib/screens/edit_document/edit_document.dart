import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/date_formater.dart';

class EditDoc extends StatefulWidget {
  final doc;
  const EditDoc({Key key, this.doc}) : super(key: key);

  @override
  _EditDocState createState() => _EditDocState();
}

class _EditDocState extends State<EditDoc> {
  int _current = 0;
  Choice _selectedChoice = choices[0]; // The app's "state".
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are you sure you want to delete this document"),
          // content: new Text("Are you sure you want to delete this document"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Delete",
              ),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  void _select(Choice choice) {
    if (choice.title == 'Delete') {
      _showDialog();
    } else if (choice.title == 'Rename') {}
    // Causes the app to rebuild with the new _selectedChoice.
  }

  Future<void> _shareImage(name, path) async {
    try {
      var splitedPath = path.split(".");
      var docType = splitedPath[splitedPath.length - 1];
      final ByteData bytes = await rootBundle.load(path);
      await Share.file('Pdf genegerated by image scanner', '$name.$docType',
          bytes.buffer.asUint8List(), '*/*',
          text: 'Pdf genegerated by image scanner');
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var timestamp = widget.doc['timestamp'];
    String delta = DateFormatter.readableDelta(timestamp);
    var name = widget.doc['name'];
    var path = widget.doc["images"][0];
    var file = File(
      path,
    );
    var images = widget.doc["images"];
    return Scaffold(
      backgroundColor: ColorShades.backgroundColorPrimary,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareImage(name, file.path),
          ),
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          // color: Colors.deepOrange,
          child: CarouselSlider(
              options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                  scrollDirection: Axis.horizontal),
              items: images
                  .map<Widget>((item) => Container(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              child: Stack(
                                children: <Widget>[
                                  Image.file(
                                    File(
                                      path,
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromARGB(200, 0, 0, 0),
                                            Color.fromARGB(0, 0, 0, 0)
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Text(
                                        "${images.indexOf(item)}/${images.length}"
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ))
                  .toList()
              //           child: Image.file(
              //             File(
              //               path,
              //             ),
              //             fit: BoxFit.fill,
              //             // width: double.maxFinite,
              //           ),
              //         ),
              //       ),
              //       color: Colors.green,
              //     ))
              // .toList(),
              ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Rename', icon: Icons.edit),
  const Choice(title: 'Delete', icon: Icons.delete),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  new FlatButton(onPressed: null, child: Text('Close'))
                ],
              );
            });
      },
      child: Card(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(choice.icon, size: 128.0, color: textStyle.color),
              Text(choice.title, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
