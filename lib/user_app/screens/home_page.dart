import 'package:business_app/components/components.dart';
import 'package:business_app/components/shake_widget.dart';
import 'package:business_app/components/textfields.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';
import 'package:business_app/user_app/components/components.dart';
import 'package:business_app/user_app/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  String errorMessage;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TappableGradientScaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "EndLine",
                  style: MyStyles.of(context)
                      .textThemes
                      .h1
                      .copyWith(color: Colors.white),
                ),
                SizedBox(height: 20),

                Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      constraints: BoxConstraints(maxWidth: 250),
                      child: StyleTextField(
                        controller: codeController,
                        textInputType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        placeholderText: "Enter Pin...",
                      ),
                    ),
                    () {
                      if (widget.errorMessage != null) {
                        return ShakeWidget(
                          key: ValueKey(codeController.text),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(widget.errorMessage,
                                style: MyStyles.of(context)
                                    .textThemes
                                    .subtext
                                    .copyWith(color: Colors.white)),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }()
                  ],
                ),

                Container(
                  padding: EdgeInsets.all(15),
                  color: Colors.transparent,
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Consumer<UAppServer>(builder: (context, server, _) {
                    return LoadingButton(
                      defaultWidget: Text("Submit",
                          style: MyStyles.of(context)
                              .textThemes
                              .buttonActionText2),
                      onPressed: () async {
                        final apiResponse =
                          await ApiResponse.fromFunction(() async {
                          return await server.getQueueReqs(
                            code: codeController.text);
                          }
                        );

                        if (apiResponse.isError) {
                          setState(() {
                            widget.errorMessage = apiResponse.message;
                          });
                        }

                        return () {
                          if (apiResponse.isSuccess) {
                            Navigator.of(context).pushNamed("/join_queue",
                                arguments: apiResponse.data);
                          }
                        };
                      },
                    );
                  }),
                ),

                // SizedBox(height: 20),
                Container(
                  child: Text(
                    "Need Help?",
                    style: MyStyles.of(context)
                        .textThemes
                        .h3
                        .copyWith(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.all(15),
              alignment: Alignment.bottomCenter,
              child: Text(
                "Business Owner?",
                style: MyStyles.of(context)
                    .textThemes
                    .h3
                    .copyWith(color: Colors.white),
              ))
        ],
      ),
    );
  }
}