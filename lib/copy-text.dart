import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/primary_button.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:mlkit/mlkit.dart';
import 'package:share/share.dart';

class CopyTextWidget extends StatefulWidget {
  @override
  _CopyTextWidgetState createState() => _CopyTextWidgetState();
}

class _CopyTextWidgetState extends State<CopyTextWidget> {
  File _file;
  List<VisionText> _currentLabels = <VisionText>[];

  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;

  @override
  initState() {
    super.initState();
  }

  uploadImage() async {
    try {
      //var file = await ImagePicker.pickImage(source: ImageSource.camera);
      final picker = ImagePicker();
      var pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _file = File(pickedFile.path);
        });
        try {
          var currentLabels = await detector.detectFromPath(_file?.path);

          setState(() {
            _currentLabels = currentLabels;
          });
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: ColorShades.backgroundColorPrimary,
        appBar: MyAppBar(
            text: 'Image scanner',
            onBackTap: () {
              Navigator.pop(context);
            }),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Center(
        child: _file == null
            ? FloatingActionButton(
                onPressed: uploadImage,
                tooltip: 'Pick Image',
                child: Icon(Icons.add_a_photo),
              )
            : FutureBuilder<Size>(
                future: _getImageSize(Image.file(
                  _file,
                )),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            TextDetectDecoration(_currentLabels, snapshot.data),
                        child: Image.file(_file, fit: BoxFit.fitWidth));
                  } else {
                    return Text('Detecting...');
                  }
                },
              ),
      ),
    );
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()))));
    return completer.future;
  }

  Widget _buildBody() {
    var _fullString = '';
    for (var i = 0; i < _currentLabels.length; i++) {
      _fullString += _currentLabels[i].text + ' ';
    }
    return SingleChildScrollView(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (_file != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PrimaryButton(
                    onPressed: uploadImage,
                    text: 'Upload another',
                  ),
                ),
              _buildImage(),
              if (_file != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: BlueButton(
                    text: 'Share consolidated document',
                    onPressed: () {
                      final RenderBox box = context.findRenderObject();
                      Share.share(_fullString,
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size);
                    },
                  ),
                ),
              _buildList(_currentLabels),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<VisionText> texts) {
    if (texts.length == 0) {
      return SizedBox();
    }
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(1.0),
        itemCount: texts.length,
        itemBuilder: (context, i) {
          return _buildRow(texts[i].text);
        });
  }

  Widget _buildRow(String text) {
    return ListTile(
      title: Text(
        "${text}",
        style: TextStyle(
          fontSize: 16.0,
          color: ColorShades.textColorOffWhite,
        ),
      ),
      dense: true,
      trailing: BlueButton(
        text: 'Share',
        onPressed: () {
          final RenderBox box = context.findRenderObject();
          Share.share(text,
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        },
      ),
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionText> _texts;
  TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _TextDetectPainter(_texts, _originalImageSize);
  }
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionText> _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    print("original Image Size : ${_originalImageSize}");

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      print("text : ${text.text}, rect : ${text.rect}");
      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);
      //final _rect = Rect.fromLTRB(24.0, 115.0, 75.0, 131.2);
      print("_rect : ${_rect}");
      canvas.drawRect(_rect, paint);
    }

    print("offset : ${offset}");
    print("configuration : ${configuration}");

    final rect = offset & configuration.size;

    print("rect container : ${rect}");

    //canvas.drawRect(rect, paint);
    canvas.restore();
  }
}
