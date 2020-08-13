import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/screens/form_page.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotYourPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<User>(
        builder: (context, user, _) {
          return FormPage(
            title: "Forgot Your Password",
            subheading: "We will send you an email with a password reset link.",
            formPageData: FormPageData(
              [
                FormPageDataElement.textfield(
                  TextFieldFormData.email(),
                ),
              ]
            ),
            onPressed: (form) async {
              await user.sendPasswordResetLink(email: form[0].textfield.text);
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Email Sent!'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('You should recieve an email with reset instructions.'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Okay'),
                        onPressed: () {
                          Navigator.of(context).popAndPushNamed("/home");
                        },
                      ),
                    ],
                  );
                },
              );
            },

            // onSuccess: () => Navigator.of(context).popAndPushNamed("/home"),
          );
        }
      ),
    );
  }
}