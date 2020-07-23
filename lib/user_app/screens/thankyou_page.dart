import 'package:business_app/theme/themes.dart';
import 'package:business_app/user_app/components/components.dart';
import 'package:flutter/material.dart';

class ThankYouPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TappableGradientScaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text("EndLine", style: MyStyles.of(context).textThemes.h1.copyWith(color: Colors.white),),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Text("Thanks for joining the queue.", style: MyStyles.of(context).textThemes.h3.copyWith(color: Colors.white),)
                  ),
                  Text("You should recieve a SMS notification on your phone shortly.", style: MyStyles.of(context).textThemes.h3.copyWith(color: Colors.white),),
                ],
              ),
            ),
        ],
      )
      );
  }
}