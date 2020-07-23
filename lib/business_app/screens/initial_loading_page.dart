import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialLoadingPage extends StatelessWidget {
  Widget _getServerErrorPage() {
    return _getBasicTextPage("There was an error contacting the server. Make sure you have internet.");
  }

  Widget _getBasicTextPage(String text) {
    return Scaffold(
      body: Container(
      padding: EdgeInsets.all(40),
      alignment: Alignment.center,
        child: Text(text, textAlign: TextAlign.center,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _getLoadingScreenAndNavigate(String route, String loadingText) {
      Future.microtask(() => Navigator.of(context).pushReplacementNamed(route));
      return _getBasicTextPage(loadingText);
    }

    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return _getBasicTextPage("Getting Account Data...");

          default:
            if (snapshot.hasData) {
              final user = Provider.of<User>(context, listen: false);
              return FutureBuilder(
                future: user.notifyServerOfSignIn(snapshot.data.email),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return _getBasicTextPage("Contacting Server...");
                    
                    default:
                      if (!snapshot.hasError) {
                        if (user.businessName == null || user.businessName.isEmpty) {
                          return _getLoadingScreenAndNavigate("/accountInfo", "Navigating to account info...");
                        } else {
                          return _getLoadingScreenAndNavigate("/dashboard", "Navigating to dashboard...");
                        }
                      } else {
                        return _getLoadingScreenAndNavigate("/home", "Navigating to home page...");
                      }
                  }
                },
              ); 
            } else {
              return _getLoadingScreenAndNavigate("/home", "Navigating to home page...");
            }
        }
      }
    );
  }
}