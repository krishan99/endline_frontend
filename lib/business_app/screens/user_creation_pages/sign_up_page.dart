import 'package:business_app/components/textfields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/screens/home_page.dart';
import 'package:business_app/business_app/screens/user_creation_pages/create_user_page/create_user_page.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';
import 'package:business_app/utils.dart';



class SignUpPage extends StatefulWidget implements EntranceScreen {
  final double height;

  SignUpPage.height({this.height});

  SignUpPage({
    Key key,
    this.height,
  }) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController checkPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    emailController.addListener(() {
      print("hello: ${emailController.text}");
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    checkPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, _) {
        return CreateUserPage(
          height: widget.height,
          title: "Sign Up",
          googleSignInText: "Sign Up With Google",

          onContinue: () async {
            if (passwordController.text != checkPasswordController.text) {
              throw CustomException("passwords do not match");
            }

            await user.signUp(
              email: emailController.text,
              password: passwordController.text
            );
          },

          onSuccess: () => Navigator.of(context).pushReplacementNamed("/accountInfo"),
          
          signInWithGoogle: () async {
            await user.signUpWithGoogle();
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
              SizedBox(height: 10,),
              StyleTextField.password(
                controller: checkPasswordController,
                paceholderText: "Retype Password...",
                getErrorMessage: (text) {
                  if (text != passwordController.text) {
                    return "Passwords do Not Match";
                  } else {
                    return null;
                  }
                },
              ),
            ]
          )
        );
      }
    );
  }
}
