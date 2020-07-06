// import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/blocs/global/state.dart';
import 'package:image_scanner/services/foreground_service.dart';

class GlobalBloc extends Bloc<GlobalEvent, Map> {
  GlobalBloc(Map initialState) : super(initialState);
  @override
  Stream<Map> mapEventToState(GlobalEvent event) async* {
    switch (event.runtimeType) {
      case FetchAllDocuments:
        yield* _mapFetchDocumentsToState(state, event);
        break;
      case AddImageFromGallery:
        yield* _mapAddDocumentsToState(state, event);
        break;
      case AddImageFromCamera:
        yield* _mapAddDocumentsToState(state, event);
        break;
      case GetCurrentDocument:
        yield* _mapGetCurrentDocumentToState(state, event);
        break;
      case AddToCurrentDocument:
        yield* _mapAddToCurrentDocumentToState(state, event);
        break;
      case DeleteFile:
        yield* _mapDeleteFileToState(state, event);
        break;
      case RenameDocument:
        yield* _mapRenameDocumentToState(state, event);
        break;
    }
  }

  Stream<Map> _mapRenameDocumentToState(state, event) async* {
    var data = {
      "currentName": event.oldName,
      "futureName": event.name,
    };
    await ForegroundService.start('renameDocument', data);
    // add(GetCurrentDocument(id: event.name));
    // add(FetchAllDocuments());
    yield {...state};
  }

  Stream<Map> _mapAddToCurrentDocumentToState(state, event) async* {
    ForegroundService.start('camera', state['doc']['name']);
    yield {...state};
  }

  Stream<Map> _mapDeleteFileToState(state, event) async* {
    var data = {"documentName": state['doc']['name'], "fileName": event.file};
    await ForegroundService.start('deleteFile', data);
    add(GetCurrentDocument(id: state['doc']['name']));
    add(FetchAllDocuments());
    // yield {...state};
  }

  Stream<Map> _mapGetCurrentDocumentToState(state, event) async* {
    var currentDocId = event.id ?? state['doc']['name'];
    var res = await ForegroundService.start('getGroupImages', currentDocId);
    var list = jsonDecode(res);
    list.sort((a, b) =>
        a["lastUpdated"].toString().compareTo(b["lastUpdated"].toString()));
    state['doc']['name'] = event.id ?? state['doc']['name'];
    state['doc']['data'] = list;
    yield {...state};
  }

  Stream<Map> _mapAddDocumentsToState(state, event) async* {
    var res = await ForegroundService.start('getImages', '');
    var list = jsonDecode(res);

    state['allDocsList'] = list;
    yield {...state};
  }

  Stream<Map> _mapFetchDocumentsToState(state, event) async* {
    var res = await ForegroundService.start('getImages', '');
    var list = jsonDecode(res);
    list.sort((a, b) =>
        a["lastUpdated"].toString().compareTo(b["lastUpdated"].toString()));
    state['allDocsList'] = list;
    // if (event.refreshDoc) {
    //   add(GetCurrentDocument(id: state['doc']['name']));
    // }
    yield {...state};
  }

  // Stream<GlobalState> _mapPlayersJoinedToState(event) async* {
  //   yield PlayersState(matchId: event.matchId, users: event.users);
  // }

}
