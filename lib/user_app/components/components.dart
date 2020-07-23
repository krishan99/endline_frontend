import 'package:business_app/components/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:business_app/components/components.dart';
import 'package:business_app/theme/themes.dart';

class TappableGradientScaffold extends StatelessWidget {
  final Widget body;

  const TappableGradientScaffold({Key key, @required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: MyStyles.of(context).colors.accentGradient
        ),
        child: TappableFullScreenView(body: body,)
      ),
    );
  }
}

class TappableFullScreenView extends StatelessWidget {

  final Widget body;

  const TappableFullScreenView({
    Key key,
    this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          onTap: (){FocusScope.of(context).requestFocus(new FocusNode());},
          child: SafeArea(
            child: body
          )
        ),
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {
  final double height;
  final double width;
  final Gradient gradient;
  final Color color;
  final Widget defaultWidget;
  final Function onPressed;

  const LoadingButton({Key key, this.height, this.width, this.gradient, this.color, this.defaultWidget, this.onPressed}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      gradient: gradient,
      color: color ?? Colors.grey[900],
      child: Container(
        child: ProgressButton(
          width: width,
          height: height,
          defaultWidget: defaultWidget,
          type: ProgressButtonType.Flat,
          borderRadius: 1,
          animate: false,
          progressWidget: JumpingDotsProgressIndicator(
            fontSize: 20,
            color: Colors.white,
          ),
          onPressed: onPressed
        ),
      ),
    );
  }
}