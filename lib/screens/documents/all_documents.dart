import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/documents/documents.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/my_drawer.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/permission.dart';
import 'package:image_scanner/util/storage_manager.dart';
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
          title: Text("All docs"),
          backgroundColor: Colors.deepOrange,
          centerTitle: true,
        ),
        body: BlocBuilder<GlobalBloc, Map>(
          builder: (context, currentState) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Container(
                  //   height: 20,
                  //   color: ColorShades.textColorOffWhite,
                  // ),
                  Documents(
                    docs: currentState['allDocsList'],
                  )
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            child: Icon(
              Icons.camera_alt,
            ),
            onPressed: () async {
              var isPermissionGranted = await handlePermissions();
              if (isPermissionGranted == false) return;
              ForegroundService.start('camera', '');
            }),
      ),
    );
  }
}
