import 'package:flutter/material.dart';

class MyInheritedData extends InheritedWidget {
  final activeDoc;
  final ValueChanged<String> onMyFieldChange;

  MyInheritedData({
    Key key,
    this.activeDoc,
    this.onMyFieldChange,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(MyInheritedData oldWidget) {
    return true;
    // oldWidget.myField != myField ||
    //     oldWidget.onMyFieldChange != onMyFieldChange;
  }

  static of(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType();
  }
}
