import 'package:business_app/business_app/screens/home_page.dart';
import 'package:business_app/components/textfields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/screens/user_creation_pages/create_user_page/create_user_page.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/services/services.dart';

class LoginPage extends StatefulWidget implements EntranceScreen {
  final double height;
  
  LoginPage({
    Key key,
    this.height,
  }) : super(key: key);

  LoginPage.height({this.height});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, _) {
        return CreateUserPage(
          height: widget.height,
          title: "Welcome Back!",
          onContinue: () async {
            await user.signIn(
              email: this.emailController.text,
              password: this.passwordController.text
            );
          },
          onSuccess: () => Navigator.of(context).pushReplacementNamed("/dashboard"),
          signInWithGoogle: () async {
            await user.signInWithGoogle();
          },
          customUserForm: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(child: StyleTextField.email(
                controller: emailController,
              )),
              SizedBox(height: 10,),
              StyleTextField.password(
                controller: passwordController,
              ),
            ]
          )
        );
      }
    );
  }
}
