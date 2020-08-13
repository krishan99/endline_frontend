import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final mD = ModelData();

/*
  mD.queues.add(
    Queue(
        name: "Outdoor Queue",
        state: QueueState.active,
        code: "54-24"
    )
  );*/

  runApp(
    MultiProvider(
      providers: [
            ChangeNotifierProvider.value(value: mD.user),
            ChangeNotifierProvider.value(value: mD.qinfo)
      ],
      child: MyApp()
    )
  );

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);

    return MaterialApp(
        title: 'EndLine',
        onGenerateRoute: BAppRouteGenerator.generateRoute,
        initialRoute: "/",
    );
  }
}
