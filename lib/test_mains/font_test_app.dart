import 'package:flutter/material.dart';

void main() => runApp(FontApp());

class FontApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FontWeightsDemo(),
    );
  }
}

class FontWeightsDemo extends StatelessWidget {
  final String font = "SanFrancisco";
  final double size = 20.0;
  final double height = 45.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w100",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w100),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w200",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w200),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w300",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w300),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w400",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w400),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w500",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w500),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w600",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w600),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w700",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w700),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w800",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w800),
                )),
          ),
          Container(
            height: height,
            child: Center(
                child: Text(
                  "This text has weight w900",
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: size,
                      fontWeight: FontWeight.w900),
                )),
          ),
        ],
      ),
    );
  }
}