import 'package:flutter/material.dart';

abstract class GlobalEvent {}

class CreateRoom extends GlobalEvent {
  final matchId;
  final igName;
  CreateRoom({this.matchId, this.igName});
}

class AddDocument extends GlobalEvent {
  AddDocument();
}

class FetchAllDocuments extends GlobalEvent {
  FetchAllDocuments();
}

class GetCurrentDocument extends GlobalEvent {
  var id;
  GetCurrentDocument({this.id});
}

class AddToCurrentDocument extends GlobalEvent {
  var name;
  AddToCurrentDocument({@required this.name});
}

class RenameDocument extends GlobalEvent {
  var name;
  var oldName;
  RenameDocument({@required this.name, @required this.oldName});
}

class DeleteFile extends GlobalEvent {
  var file;
  DeleteFile({@required this.file});
}

class AddImageFromGallery extends GlobalEvent {
  AddImageFromGallery();
}

class AddImageFromCamera extends GlobalEvent {
  AddImageFromCamera();
}
