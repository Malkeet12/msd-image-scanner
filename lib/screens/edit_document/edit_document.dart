import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:image_scanner/util/date_formater.dart';

class EditDoc extends StatefulWidget {
  final doc;
  const EditDoc({Key key, this.doc}) : super(key: key);

  @override
  _EditDocState createState() => _EditDocState();
}

class _EditDocState extends State<EditDoc> {
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
      final ByteData bytes = await rootBundle.load(path);
      await Share.file('Pdf genegerated by image scanner', '$name.pdf',
          bytes.buffer.asUint8List(), 'text/csv',
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
    var path = widget.doc["path"];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareImage(name, path),
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
      body: Container(
        color: Colors.red,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(20),
                //   color: Colors.white,
                //   boxShadow: [
                //     BoxShadow(color: Colors.orange, spreadRadius: 3),
                //   ],
                // ),
                child: MyPdfView(
                  path: path,
                ),
              ),
            ),
          ],
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
