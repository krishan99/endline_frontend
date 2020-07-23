
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class MyStyles {
  static MyStyles lightMode = MyStyles._(images: MyImages.lightMode, colors: MyColors.lightMode, textThemes: MyTextThemes.lightMode);
  static MyStyles darkMode = MyStyles._(images: MyImages.darkMode, colors: MyColors.darkMode, textThemes: MyTextThemes.darkMode);

  static MyStyles of(BuildContext context) {
    switch (MediaQuery.of(context).platformBrightness) {
      case Brightness.light: 
        return MyStyles.darkMode;
      case Brightness.dark:
        return MyStyles.darkMode;
    }
  }

  final MyImages images;
  final MyColors colors;
  final MyTextThemes textThemes;

  const MyStyles._({this.images, this.colors, this.textThemes});
}

class MyImages {
  static const imagePath = "assets/images/";

  static final MyImages lightMode = MyImages._(
    userAccountIcon: Image.asset("${imagePath}user_account_icon.png"),
    gearIcon: Image.asset("${imagePath}gear_icon.png"),
  );

  static final MyImages darkMode = lightMode.copyWith();

  final Image userAccountIcon;
  final Image gearIcon;

  MyImages._({
    this.userAccountIcon,
    this.gearIcon
  });

  MyImages copyWith({
    Image userAccountIcon,
    Image gearIcon,
  }) {
    return MyImages._(
      userAccountIcon: userAccountIcon ?? this.userAccountIcon,
      gearIcon: gearIcon ?? this.gearIcon
    );
  }
}

class MyColors {
  static MyColors lightMode = const MyColors._(
    background1: Colors.white,
    background2: Color.fromRGBO(248, 248, 248, 1),
    accent: Color.fromRGBO(255, 83, 83, 1),
    active: Color.fromRGBO(52, 209, 42, 1),
    secondary: Color.fromRGBO(98, 98, 98, 1),
    accentGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromRGBO(255, 75, 43, 1),
        Color.fromRGBO(255, 65, 108, 1)
      ]
    ),
    statusBarColor: Colors.transparent,
    systemBarIconBrightness: Brightness.light,
  );

  static MyColors darkMode = MyColors.lightMode.copyWith(systemBarIconBrightness: Brightness.dark);

  MyColors copyWith({Color background1, Color background2, Color accent, Color active, Color secondary, LinearGradient accentGradient, Color statusBarColor, Brightness systemBarIconBrightness}) {
    return MyColors._(
      background1: background1 ?? this.background1,
      background2: background2 ?? this.background2,
      accent: accent ?? this.accent, 
      active: active ?? this.active,
      secondary: secondary ?? this.secondary,
      accentGradient: accentGradient ?? this.accentGradient,
      statusBarColor: statusBarColor ?? this.statusBarColor,
      systemBarIconBrightness: systemBarIconBrightness ?? this.systemBarIconBrightness,
    );
  }

  final Color background1;
  final Color background2;
  final Color accent;
  final Color secondary;
  final LinearGradient accentGradient;
  final Color statusBarColor;
  final Color active;
  final Brightness systemBarIconBrightness;
  const MyColors._({this.background1, this.background2, this.active, this.accent, this.secondary, this.accentGradient, this.statusBarColor, this.systemBarIconBrightness}); 
}

class MyTextThemes {
  static const _fontFamily = "SanFrancisco";

  static const lightMode = MyTextThemes._(
    h1: TextStyle(fontSize: 47, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.bold),
    h2: TextStyle(fontSize: 40, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.bold),
    h3: TextStyle(fontSize: 20, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(98, 98, 98, 1), fontWeight: FontWeight.bold),
    h4: TextStyle(fontSize: 20, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(57, 57, 57, 1), fontWeight: FontWeight.w300),
    h5: TextStyle(fontSize: 10, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(98, 98, 98, 1), fontWeight: FontWeight.w300),
    bodyText1: TextStyle(fontSize: 20, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.bold),
    bodyText2: TextStyle(fontSize: 18, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(116, 116, 116, 1), fontWeight: FontWeight.bold),
    bodyText3: TextStyle(fontSize: 17, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(103, 103, 103, 1), fontWeight: FontWeight.w300),
    buttonActionText1: TextStyle(fontSize: 20, fontFamily: MyTextThemes._fontFamily, color: Colors.white, fontWeight: FontWeight.w300),
    buttonActionText2: TextStyle(fontSize: 18, fontFamily: MyTextThemes._fontFamily, color: Colors.white, fontWeight: FontWeight.w300),
    buttonActionText3: TextStyle(fontSize: 16, fontFamily: MyTextThemes._fontFamily, color: Colors.white, fontWeight: FontWeight.w300),
    subtext: TextStyle(fontSize: 15, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(160, 160, 160, 1), fontWeight: FontWeight.w300),
    errorSubText: TextStyle(fontSize: 12, fontFamily: MyTextThemes._fontFamily, color: Colors.red, fontWeight: FontWeight.w300),
    placeholder: TextStyle(fontSize: 15, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(186, 186, 186, 1), fontWeight: FontWeight.w300),
    active: TextStyle(fontSize: 20, fontFamily: MyTextThemes._fontFamily, color: Color.fromRGBO(174, 214, 64, 1), fontWeight: FontWeight.bold),
    disabled: TextStyle(fontSize: 20, fontFamily: MyTextThemes._fontFamily, color: Colors.red, fontWeight: FontWeight.bold)
  );

  static const darkMode = lightMode;

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle bodyText1;
  final TextStyle bodyText2;
  final TextStyle bodyText3;
  final TextStyle buttonActionText1;
  final TextStyle buttonActionText2;
  final TextStyle buttonActionText3;
  final TextStyle formField1;
  final TextStyle subtext;
  final TextStyle errorSubText;
  final TextStyle placeholder;
  final TextStyle active;
  final TextStyle disabled;
  

  const MyTextThemes._({
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.bodyText1,
    this.bodyText2,
    this.bodyText3,
    this.buttonActionText1,
    this.buttonActionText2,
    this.buttonActionText3,
    this.formField1,
    this.subtext,
    this.errorSubText,
    this.placeholder,
    this.active,
    this.disabled
  });

}
