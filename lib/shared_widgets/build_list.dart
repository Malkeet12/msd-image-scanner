import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/primary_button.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:share/share.dart';

class BuildList extends StatelessWidget {
  final texts;
  const BuildList({Key key, this.texts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          return _buildRow(texts[i].text, context);
        });
  }

  Widget _buildRow(String text, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              "${text}",
              style: TextStyle(
                fontSize: 16.0,
                color: ColorShades.textPrimaryDark,
              ),
            ),
          ),
          SizedBox(
            width: 4.0,
          ),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  AnalyticsService().sendEvent(
                    name: 'copy_text_click',
                  );
                  Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Color(0xff4364A1),
                    content: Text(
                      'Text copied to clipboard ',
                      style: Theme.of(context).textTheme.body2Medium.copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                  Clipboard.setData(ClipboardData(text: text));
                },
                child: Icon(
                  Icons.content_copy,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(
                width: 12.0,
              ),
              GestureDetector(
                onTap: () {
                  AnalyticsService().sendEvent(
                    name: 'share_text_click',
                  );
                  Share.share(text,
                      sharePositionOrigin: Rect.fromLTWH(0, 0, 0, 0));
                },
                child: Image(
                  width: 30.0,
                  image: AssetImage(
                    'assets/images/share.png',
                  ),
                ),
                // child: Icon(
                //   Icons.share,
                //   color: ColorShades.textColorOffWhite,
                // ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
