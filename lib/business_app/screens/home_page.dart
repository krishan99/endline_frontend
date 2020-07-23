import 'package:auto_size_text/auto_size_text.dart';
import 'package:business_app/business_app/screens/user_creation_pages/sign_up_page.dart';
import 'package:business_app/components/buttons.dart';
import 'package:business_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/business_app/screens/user_creation_pages/login_page.dart';

enum EntranceScreenType { signUp, logIn }

abstract class EntranceScreen extends Widget {
  final height;

  factory EntranceScreen(EntranceScreenType type, height) {
    switch (type) {
      case EntranceScreenType.logIn:
        return LoginPage.height(height: height);
      case EntranceScreenType.signUp:
        return SignUpPage.height(height: height);
    }

    assert(false);
  }

  EntranceScreen.height({this.height});
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _showEntranceScreenModally(EntranceScreenType type) {
      final height = MediaQuery.of(context).size.height * 0.9;

      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return Container(
                height: height,
                //TODO: Supposed be rounding off page but doesn't
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                    ),
                ),
                child: EntranceScreen(type, height)
              );
          });
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: MyStyles.of(context).colors.background1,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        child: Text(
                      "EndLine for Businesses",
                      textAlign: TextAlign.center,
                      style: MyStyles.of(context).textThemes.h1,
                    )),
                    SizedBox(height: 14),
                    Container(
                      child: AutoSizeText(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do",
                        textAlign: TextAlign.center,
                        style: MyStyles.of(context).textThemes.h4,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  alignment: Alignment.bottomCenter,
                                  image: NetworkImage(
                                      "https://image.shutterstock.com/image-vector/people-waiting-long-queue-counter-260nw-1065200126.jpg"
                                  ),
                                  fit: BoxFit.fitHeight
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      child: AccentedActionButton(
                          text: "Sign Up",
                          onSuccess: () => {
                            _showEntranceScreenModally(EntranceScreenType.signUp)
                          }
                        ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      child: ActionButton(
                          child: Text(
                            "Log In",
                            style: MyStyles.of(context).textThemes.buttonActionText1,
                          ),
                          color: MyStyles.of(context).colors.secondary,
                          onSuccess: () => {
                            _showEntranceScreenModally(EntranceScreenType.logIn)
                          }
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


