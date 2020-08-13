import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/screens/home_page.dart';
import 'package:business_app/user_app/models/models.dart';
import 'package:business_app/user_app/screens/getting_queue_reqs.dart';
import 'package:business_app/user_app/screens/join_queue_page.dart';
import 'package:business_app/user_app/screens/thankyou_page.dart';
import 'package:flutter/material.dart';

class UAppRouteGenerator {

  static MaterialPageRoute getHomePageRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return HomePage();
      }
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    final name = settings.name;
    
    //Check if in path format
    assert(name[0] == '/');

    //Check if code is at end of url
    if (name.length > 1) {
      final codeAsString = name.substring(1, name.length);
      try {
        final code = double.parse(codeAsString);
        return MaterialPageRoute(
          builder: (context) {
            return GettingQueueReqs(code: codeAsString);
          }
        );
      } catch (error) {}
    }

    switch (settings.name) {
      case '/':
        return getHomePageRoute();
      
      case '/join_queue':
        QueueReqs reqs = args as QueueReqs;

        return MaterialPageRoute(
          builder: (context) {
            return JoinQueuePage(reqs: reqs,);
          }
        );

      case '/thankyou':
        return MaterialPageRoute(
          builder: (context) {
            return ThankYouPage();
          }
        );
      default:
        assert(false);
    }
  }
}