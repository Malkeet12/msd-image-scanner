import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/theme/style.dart';

class EditNameDialog extends StatefulWidget {
  const EditNameDialog({
    Key key,
    @required TextEditingController controller,
  })  : _controller = controller,
        super(key: key);

  final TextEditingController _controller;

  @override
  _EditNameDialogState createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  var inputValue;
  var oldName;
  var error = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    oldName = widget._controller.text;
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      title: new Text(
        "Rename file",
        style: Theme.of(context)
            .textTheme
            .h3
            .copyWith(color: ColorShades.textSecGray3),
      ),
      content: Container(
        height: error ? 110 : 90,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
                controller: widget._controller,
                onChanged: (value) {
                  setState(() {
                    inputValue = value;
                    error = false;
                  });
                },
                maxLength: 30,
                style: Theme.of(context).textTheme.body1Medium,
              ),
              if (error)
                Text(
                  'A file with the same name already exists.',
                  style: textTheme.body1Medium.copyWith(
                    color: colorScheme.error,
                  ),
                )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text(
            "Close",
            style: Theme.of(context)
                .textTheme
                .h4
                .copyWith(color: ColorShades.textSecGray3),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text(
            "OK",
            style: Theme.of(context)
                .textTheme
                .h3
                .copyWith(color: Colors.blueAccent),
          ),
          onPressed: () async {
            if (inputValue == null || inputValue.length == 0) {
              Navigator.of(context).pop();
              return;
            }
            var data = {
              "currentName": oldName,
              "futureName": inputValue,
            };
            var res = await ForegroundService.start('renameDocument', data);
            if (res) {
              BlocProvider.of<GlobalBloc>(context)
                  .add(GetCurrentDocument(id: inputValue));
              Navigator.of(context).pop();
            } else {
              setState(() {
                error = true;
              });
            }
          },
        ),
      ],
    );
  }
}
