import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/documents/documents.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/empty_state.dart';
import 'package:image_scanner/shared_widgets/my_drawer.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/permission.dart';
import 'package:permission_handler/permission_handler.dart';

class AllDocuments extends StatefulWidget {
  const AllDocuments({
    Key key,
  }) : super(key: key);

  @override
  _AllDocumentsState createState() => _AllDocumentsState();
}

class _AllDocumentsState extends State<AllDocuments> {
  var userImages;
  @override
  void initState() {
    super.initState();
    ForegroundService.registerCallBack("refreshUI", getUserImages);
    getUserImages();
  }

  Future<bool> handlePermissions() async {
    var permission1 = await Permission.request(PermissionGroup.camera);
    var permission2 = await Permission.request(PermissionGroup.storage);
    // var permission3 = await Permission.request(PermissionGroup.mediaLibrary);
    // var permission4 = await Permission.request(PermissionGroup.photos);
    return permission1 && permission2;
  }

  getUserImages() async {
    BlocProvider.of<GlobalBloc>(context).add(FetchAllDocuments());
  }

  onCameraClick() async {
    var isPermissionGranted = await handlePermissions();
    if (isPermissionGranted == false) {
      return;
    }
    ForegroundService.start('camera', '');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.deepOrange,
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        drawer: MyDrawer(),
        backgroundColor: ColorShades.textColorOffWhite,
        appBar: AppBar(
          title: Text("Documents"),
          backgroundColor: Colors.deepOrange,
          centerTitle: true,
        ),
        body: BlocBuilder<GlobalBloc, Map>(
          builder: (context, currentState) {
            var docs = currentState['allDocsList'];
            if (docs.length == 0)
              return EmptyState(onCameraClick: onCameraClick);
            else
              return SingleChildScrollView(
                child: Documents(
                  docs: currentState['allDocsList'],
                ),
              );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              child: Icon(
                Icons.camera_alt,
              ),
              onPressed: () => onCameraClick()),
        ),
      ),
    );
  }
}
