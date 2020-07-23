import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/business_app/screens/add2_queue_page.dart';
import 'package:business_app/business_app/screens/create_queue_page.dart';
import 'package:business_app/business_app/screens/dashboard_page.dart';
import 'package:business_app/business_app/screens/home_page.dart';
import 'package:business_app/business_app/screens/initial_loading_page.dart';
import 'package:business_app/business_app/screens/queue_page.dart';
import 'package:business_app/business_app/screens/queue_person_edit.dart';
import 'package:business_app/business_app/screens/user_creation_pages/setup_user_account_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum RoutePageType { initialLoadingPage, home, dashboard, queue, accountInfo }

class BAppRouteGenerator {
  static _getPageRoute(RoutePageType type, dynamic args) {
    switch (type) {
      case RoutePageType.initialLoadingPage:
        return InitialLoadingPage();

      case RoutePageType.home:
        return HomePage();

      case RoutePageType.dashboard:
        return DashboardPage();

      case RoutePageType.queue:
        Queue queue = args as Queue;
        return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: queue),
              ChangeNotifierProvider.value(value: queue.people)
            ],
            child: QueuePage(
              queue: queue,
            ));

      case RoutePageType.accountInfo:
        return SetupAccountPage();
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) {
          return _getPageRoute(RoutePageType.initialLoadingPage, args);
        });

      case '/home':
        return MaterialPageRoute(builder: (context) {
          return _getPageRoute(RoutePageType.home, args);
        });

      case '/accountInfo':
        return MaterialPageRoute(builder: (context) {
          return _getPageRoute(RoutePageType.accountInfo, args);
        });

      case '/dashboard':
        return MaterialPageRoute(builder: (context) {
          return _getPageRoute(RoutePageType.dashboard, args);
        });

      case '/personDetails':
        return MaterialPageRoute(builder: (context) {
          return QueuePersonDescription(person: args as QueuePerson);
        });

      case '/queue':
        // Validation of correct data type
        return MaterialPageRoute(builder: (context) {
          final user = Provider.of<User>(context, listen: false);
          assert(user.isLoggedIn);
          return _getPageRoute(RoutePageType.queue, args);
        });
      // return _errorRoute();
      case '/createQueue':
        return MaterialPageRoute(builder: (context) {
          AllQueuesInfo QueuesInfo = args as AllQueuesInfo;
          return CreateQueue(QueuesInfo);
        });

      case '/add2Queue':
        return MaterialPageRoute(builder: (context) {
          Queue queue = args as Queue;
          return Add2Queue(queue);
        });
      default:
        assert(false);
    }
  }
}
