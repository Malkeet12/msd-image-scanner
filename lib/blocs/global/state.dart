import 'package:flutter/material.dart';

abstract class GlobalState {
  static Map appState = {
    'allDocsList': [],
    'doc': Map(),
  };
}

class InitialState extends GlobalState {}

class AllDocumentsFetechedState extends GlobalState {
  var list;
  AllDocumentsFetechedState({@required this.list});
}
