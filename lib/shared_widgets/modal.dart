import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/edit_name_dialog.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:image_scanner/util/constants.dart';

class Modal {
  TextEditingController _controller = new TextEditingController();
  mainBottomSheet(BuildContext context, name) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, name, Icons.folder, null),
              SizedBox(
                height: 12,
              ),
              Divider(
                color: ColorShades.textSecGray3,
                height: 5,
              ),
              _createTile(
                  context, 'Rename', Icons.edit, () => _rename(context, name)),
              _createTile(context, 'Delete', Icons.delete_forever,
                  () => _deleteFolder(context, name)),
              SizedBox(
                height: 12,
              ),
            ],
          );
        });
  }

  ListTile _createTile(
      BuildContext context, String name, IconData icon, Function action) {
    var colors = Constants.MY_COLORS;
    var uid = CommonUtil.getRandomNumber(5);
    return ListTile(
      leading: Icon(
        icon,
        color: colors[uid],
      ),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        if (action != null) action();
      },
    );
  }

  _rename(context, name) {
    _controller.text = name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditNameDialog(controller: _controller);
      },
    );
  }

  _deleteFolder(context, name) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text.rich(
              TextSpan(
                text: '', // default text style
                children: <TextSpan>[
                  TextSpan(
                    text: 'Are you sure you want to delete this document -> ',
                    style: Theme.of(context)
                        .textTheme
                        .h4
                        .copyWith(color: ColorShades.textSecGray3),
                  ),
                  TextSpan(
                      text: name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorShades.textSecGray3)),
                ],
              ),
            ),
            //  new Text(
            //   "Are you sure you want to delete this document ($name)",
            //   style: Theme.of(context)
            //       .textTheme
            //       .h4
            //       .copyWith(color: ColorShades.textSecGray3),
            // ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("CLOSE"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  "DELETE",
                ),
                onPressed: () async {
                  ForegroundService.start("deleteFolder", name);
                  Navigator.pop(context);
                  BlocProvider.of<GlobalBloc>(context).add(FetchAllDocuments());
                },
              ),
            ],
          );
        });
  }
}
