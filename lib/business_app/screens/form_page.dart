import 'dart:collection';

import 'package:business_app/components/buttons.dart';
import 'package:business_app/components/textfields.dart';
import 'package:business_app/user_app/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/theme/themes.dart';

class FormFieldData {
  String title;
  String placeholderText;
  String initialText;
  int maxLines;
  final String Function(String) checkError;
  TextEditingController controller = TextEditingController();

  String get text {
    return controller.text;
  }

  FormFieldData({
    this.title,
    this.maxLines,
    this.checkError,
    this.initialText,
    @required this.placeholderText
  });
}

class FormPageData extends ListBase<FormFieldData> {
  List<FormFieldData> _data;

  int get length => _data.length;

  set length(int newLength) {
    _data.length = newLength;
  }

  @override
  FormFieldData operator [](int index) {
      return _data[index];
    }
  
  @override
  void operator []=(int index, FormFieldData value) {
    _data[index] = value;
  }

  FormPageData(List<FormFieldData> data) {
    this._data = data;
  }
}

class FormPage extends StatefulWidget {
  final String title;
  final String subheading;
  final FormPageData formPageData;
  final Future<void> Function(FormPageData) onPressed;
  final void Function() onSuccess;

  FormPage({
    Key key,
    @required this.title,
    this.subheading,
    @required this.formPageData,
    this.onPressed,
    this.onSuccess,
  }) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {

  @override
  void initState() {
    super.initState();
    widget.formPageData.map((field) => field.controller = TextEditingController(text: field.initialText));
  }

  @override
  void dispose() {
    super.dispose();
    widget.formPageData.map((field) => field.controller.dispose());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyStyles.of(context).colors.background1,
        body: TappableFullScreenView(
          body: SafeArea(
            child: Container(
              color: MyStyles.of(context).colors.background1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: MyStyles.of(context).textThemes.h2,
                          )
                        ),
                        if (widget.subheading != null) 
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 6,
                              ),
                              Container(
                                child: Text(
                                  widget.subheading,
                                  textAlign: TextAlign.center,
                                  style: MyStyles.of(context).textThemes.h3,
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    // color: Colors.red,
                    // alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.formPageData.map((element) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[                            
                            if (element.title != null && element.title.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(element.title, textAlign: TextAlign.start, style: MyStyles.of(context).textThemes.bodyText3)
                              ),
                            
                            StyleTextField(
                              controller: element.controller,
                              placeholderText: element.placeholderText,
                              maxLines: element.maxLines,
                              getErrorMessage: element.checkError,
                            ),

                            SizedBox(height: 12,),
                          ],
                        );
                      }).toList()
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    alignment: Alignment.center,
                    child: Consumer<User>(
                      builder: (context, user, _) {
                        return AccentedActionButton(
                          width: 233,
                          height: 55,
                          text: "Continue",
                          onPressed: () async {
                            await widget.onPressed(widget.formPageData);
                          },

                          onSuccess: widget.onSuccess,
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}