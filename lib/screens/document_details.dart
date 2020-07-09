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
import 'package:image_scanner/util/analytics_service.dart';

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
    AnalyticsService().sendEvent(
      name: 'rename_from_details_screen',
    );
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
            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 4.0),
              child: IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  size: 32,
                ),
                onPressed: () async {
                  AnalyticsService().sendEvent(
                    name: 'view_pdf',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewer(doc: docs, name: name),
                    ),
                  );
                },
              ),
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
                    docs.length + 1,
                    (index) {
                      if (index == docs.length)
                        return TapToAddContainer(name: name);
                      else
                        return SinglePage(
                          docs: docs,
                          index: index,
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
                AnalyticsService().sendEvent(
                  name: 'add_pages_by_camera_click',
                );
                BlocProvider.of<GlobalBloc>(context)
                    .add(AddToCurrentDocument(name: name));
              }),
        ),
      );
    });
  }
}

class SinglePage extends StatelessWidget {
  const SinglePage({
    Key key,
    @required this.docs,
    this.index,
  }) : super(key: key);

  final docs;
  final index;

  @override
  Widget build(BuildContext context) {
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
                  .copyWith(color: ColorShades.textColorOffWhite),
            ),
          ),
          bottom: 14,
          left: 14,
        )
      ],
    );
  }
}

class TapToAddContainer extends StatelessWidget {
  const TapToAddContainer({
    Key key,
    @required this.name,
  }) : super(key: key);

  final name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        AnalyticsService().sendEvent(
          name: 'tap_to_add_pages',
        );
        BlocProvider.of<GlobalBloc>(context)
            .add(AddToCurrentDocument(name: name));
      },
      child: Container(
        width: double.infinity,
        height: 170.0,
        decoration: BoxDecoration(
          color: ColorShades.lightBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Tap",
                  style: Theme.of(context).textTheme.h4.copyWith(
                        color: ColorShades.textPrimaryDark,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.camera_alt,
                  color: Colors.deepOrange,
                ),
                SizedBox(
                  width: 4,
                ),
              ],
            ),
            Text(
              "to add new pages",
              style: Theme.of(context).textTheme.h4.copyWith(
                    color: ColorShades.textPrimaryDark,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
