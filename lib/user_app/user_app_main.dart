import 'package:business_app/services/services.dart';
import 'package:business_app/user_app/models/models.dart';
import 'package:business_app/user_app/route_generator.dart';
import 'package:business_app/user_app/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final mD = ModelData();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: mD.server),
        ChangeNotifierProvider.value(value: mD.user),
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
        onGenerateRoute: UAppRouteGenerator.generateRoute,
        home: HomePage()
    );
  }
}