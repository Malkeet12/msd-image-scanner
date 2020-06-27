import 'package:flutter/material.dart';
import 'package:image_scanner/copy-text.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/theme/style.dart';

void main() {
  runApp(MaterialApp(
    title: 'Image Scanner',
    // Start the app with the "/" named route. In our case, the app will start
    // on the FirstScreen Widget
    initialRoute: '/',
    routes: {
      '/': (context) => MyApp(),
    },
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorShades.backgroundColorPrimary,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorShades.backgroundColorPrimary,
        centerTitle: true,
        title: Text(
          'Image scanner',
          style: TextStyle(
            color: ColorShades.textColorOffWhite,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            BlueButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CopyTextWidget(),
                  ),
                );
              },
              text: 'Copy text from image',
            ),
          ],
        ),
      ),
    );
  }
}
