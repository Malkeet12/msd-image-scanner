import 'package:flutter/material.dart';
import 'package:image_scanner/theme/style.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    Key key,
    this.onCameraClick,
  }) : super(key: key);
  final onCameraClick;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        // padding: EdgeInsets.only(right: 16, left: 16),
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
                child: Row(
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
                    Flexible(
                      child: Text(
                        "to start your journey ",
                        style: Theme.of(context).textTheme.h4.copyWith(
                              color: ColorShades.textPrimaryDark,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
