import 'package:business_app/components/buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/screens/user_creation_pages/create_user_page/user_creation_components.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';
import 'package:toast/toast.dart';

class CreateUserPage extends StatefulWidget {
  final double height;
  final String title;
  final String subtext;
  final String buttonText;
  final String googleSignInText;
  final Future<void> Function() onContinue;
  final Function onSuccess;
  final Future<void> Function() signInWithGoogle;
  Widget customUserForm;

  CreateUserPage({
    Key key,
    this.height,
    @required this.title,
    this.subtext = "Happy customers are the best advertising money can buy.",
    this.buttonText = "Continue",
    this.googleSignInText = "Sign In With Google",
     @required this.onContinue,
    this.onSuccess,
    @required this.signInWithGoogle,
    this.customUserForm,
  }) : super(key: key);

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  //little hacky but should be fine as CreateUser Page should always be presented modally in production.
  bool get isModallyPresented {
    return widget.height != null;
  }

  static double spacing = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            constraints: BoxConstraints(
                maxHeight: widget.height ?? MediaQuery.of(context).size.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,),
                    Container(
                        child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: MyStyles.of(context).textThemes.h2,
                    )),
                    SizedBox(
                      height: spacing,
                    ),
                    Container(
                      child: Text(
                        widget.subtext,
                        textAlign: TextAlign.center,
                        style: MyStyles.of(context).textThemes.h4,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: GoogleSignInButton(
                        text: widget.googleSignInText,
                        onPressed: () async {
                          final apiResponse = await ApiResponse.fromFunction(() async {
                            await widget.signInWithGoogle();
                          });
                          
                          if (apiResponse.isError) {
                            Toast.show(
                              apiResponse.message,
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM
                            );
                          } else if (apiResponse.isSuccess) {
                            if (widget.onSuccess != null) {
                              widget.onSuccess();
                            }
                          }
                        },
                      ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 330),
                  padding: EdgeInsets.all(20),
                  // width: 269,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: Text(
                          "Or Use Email",
                          style: MyStyles.of(context).textThemes.bodyText2,
                        ),
                      ),
                      SizedBox(
                        height: spacing,
                      ),
                      Container(
                          // color: Colors.yellow,
                          child: widget.customUserForm),
                      SizedBox(
                        height: spacing,
                      ),
                      Container(
                        child: AccentedActionButton(
                          text: widget.buttonText,
                          onPressed: widget.onContinue,
                          onSuccess: widget.onSuccess,
                        ),
                      ),
                      SizedBox(
                        height: spacing*2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
