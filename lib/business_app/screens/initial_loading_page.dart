import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';
import 'package:business_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class InitialLoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Utils.getBasicTextPage("Getting Account Data...");

          default:
            if (snapshot.hasData) {
              final user = Provider.of<User>(context, listen: false);
              return FutureBuilder(
                future: user.notifyServerOfSignIn(snapshot.data.email),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Utils.getBasicTextPage("Contacting Server...");
                    
                    default:
                      if (!snapshot.hasError) {
                        if (user.businessName == null || user.businessName.isEmpty) {
                          return Utils.of(context).getLoadingScreenAndNavigate(route: "/accountInfo", loadingText: "Navigating to account info...",);
                        } else {
                          return Utils.of(context).getLoadingScreenAndNavigate(route: "/dashboard", loadingText: "Navigating to dashboard...");
                        }
                      } else {
                        return Utils.of(context).getLoadingScreenAndNavigate(route: "/home", loadingText: "Navigating to home page...");
                      }
                  }
                },
              ); 
            } else {
              return Utils.of(context).getLoadingScreenAndNavigate(route: "/home", loadingText: "Navigating to home page...");
            }
        }
      }
    );
  }
}