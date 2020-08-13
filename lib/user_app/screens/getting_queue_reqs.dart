import 'package:business_app/user_app/services/services.dart';
import 'package:business_app/utils.dart';
import 'package:flutter/material.dart';

import 'package:business_app/user_app/components/components.dart';
import 'package:business_app/user_app/models/models.dart';

class GettingQueueReqs extends StatelessWidget {

  final String code;

  const GettingQueueReqs({
    Key key,
    this.code,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QueueReqs>(
      future: UAppServer.getQueueReqs(code: code),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Utils.getBasicTextPage("Loading...");
          default:
            if (snapshot.hasData) {
              return Utils.of(context).getLoadingScreenAndNavigate(route: "/join_queue", arguments: snapshot.data);
            } else if (snapshot.hasError) {
              return Utils.getBasicTextPage(snapshot.error.toString());
            } else {
              return Utils.getServerErrorPage();
            }
        }
      }
    );
  }
}
