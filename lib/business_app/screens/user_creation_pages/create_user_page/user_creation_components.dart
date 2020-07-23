import 'package:business_app/theme/themes.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  
  const GoogleSignInButton({
    Key key,
    this.text = "Sign in with Google",
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                  image: AssetImage("assets/images/google_logo.png"),
                  height: 24.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  this.text,
                  style: MyStyles.of(context)
                      .textThemes
                      .h4
                      .copyWith(fontSize: 17),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
