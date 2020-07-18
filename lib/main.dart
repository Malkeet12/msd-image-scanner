import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/state.dart';
import 'package:image_scanner/screens/documents/all_documents.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<GlobalBloc>(
          create: (BuildContext context) => GlobalBloc(GlobalState.appState),
        ),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'digipaper',
        // Start the app with the "/" named route. In our case, the app will start
        // on the FirstScreen Widget
        initialRoute: '/',
        routes: {
          '/': (context) => AllDocuments(),
        },
      ),
    );
  }
}
