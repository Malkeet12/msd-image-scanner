import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(
        "Rename",
        style: Theme.of(context)
            .textTheme
            .h3
            .copyWith(color: ColorShades.textSecGray3),
      ),
      content: TextField(
        autofocus: true,
        controller: widget._controller,
        onChanged: (value) {
          setState(() {
            inputValue = value;
          });
        },
        maxLength: 30,
        style: Theme.of(context).textTheme.body1Medium,
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
          onPressed: () {
            BlocProvider.of<GlobalBloc>(context)
                .add(RenameDocument(name: inputValue));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
