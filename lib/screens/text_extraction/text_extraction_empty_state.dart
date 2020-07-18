import 'package:flutter/material.dart';
import 'package:image_scanner/theme/style.dart';

class TextExtractionEmptyState extends StatelessWidget {
  const TextExtractionEmptyState({
    Key key,
    this.onCameraClick,
  }) : super(key: key);
  final onCameraClick;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Image(
          image: AssetImage('assets/images/empty_state.png'),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => onCameraClick(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
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
                      width: 8,
                    ),
                    Icon(
                      Icons.camera_alt,
                      color: Color(0xff4364A1),
                      size: 32,
                    ),
                  ],
                ),
                Text(
                  "to extract text from image",
                  style: Theme.of(context).textTheme.h4.copyWith(
                        color: ColorShades.textPrimaryDark,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
