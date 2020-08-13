import 'dart:collection';

import 'package:business_app/components/buttons.dart';
import 'package:business_app/components/textfields.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/user_app/components/components.dart';
import 'package:business_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/theme/themes.dart';

class FormPageDataElementProtocol {
}

// extension Widget on FormPageDataElementProtocol {}

enum FormFieldDataType {
  email,
  phoneNumber,
  password,
  custom
}

class TextFieldFormData implements FormPageDataElementProtocol {
  FormFieldDataType type;
  String title;
  String placeholderText;
  String initialText;
  int maxLines;
  bool isRequired;
  final String Function(String) checkError;
  TextEditingController controller = TextEditingController();


  String get text => controller.text;

  String errorMessageFromInput() {
    if (this.isRequired && text.isEmpty) {
      return "Missing Required Field";
    } else if (checkError != null) {
      return checkError(text);
    } else {
      return null;
    }
  }

  factory TextFieldFormData.email({String title, String initialText, bool isRequired = true}) {
    return TextFieldFormData(
      type: FormFieldDataType.email,
      title: title,
      initialText: initialText,
      placeholderText: null,
      isRequired: isRequired,
      checkError: (text) => Utils.isValidEmail(text) ? null : "Invalid email"
    );
  }

  factory TextFieldFormData.password({String title, String initalText}) {
    return TextFieldFormData(
      type: FormFieldDataType.password,
      title: title,
      initialText: initalText,
      placeholderText: null,
    );
  }

  factory TextFieldFormData.phoneNumber({String title, String initalText, bool isRequired = true}) {
    return TextFieldFormData(
      type: FormFieldDataType.phoneNumber,
      title: title,
      initialText: initalText,
      placeholderText: null,
      isRequired: isRequired,
      checkError: (text) => text.length == 10 ? null : "invalid phone number"
    );
  }

  TextFieldFormData({
    this.type = FormFieldDataType.custom,
    this.title,
    this.maxLines,
    this.checkError,
    this.initialText,
    this.isRequired = true,
    this.placeholderText
  });
}

class CheckBoxFormData implements FormPageDataElementProtocol {
  String title;
  bool isOn;

  CheckBoxFormData({@required this.title, this.isOn = false});
}

enum FormPageDataElementType {
  checkbox,
  textfield,
  widget
}

class FormPageDataElement {
  FormPageDataElementType type;
  TextFieldFormData textfield;
  CheckBoxFormData checkbox;
  Widget widget;

  factory FormPageDataElement.widget(Widget widget) {
    return FormPageDataElement._(type: FormPageDataElementType.widget, widget: widget);
  }

  factory FormPageDataElement.textfield(TextFieldFormData textfield) {
    return FormPageDataElement._(type: FormPageDataElementType.textfield, textfield: textfield);
  }

  factory FormPageDataElement.checkbox(CheckBoxFormData checkbox) {
    return FormPageDataElement._(type: FormPageDataElementType.checkbox, checkbox: checkbox);
  }

  FormPageDataElement._({this.type, this.textfield, this.checkbox, this.widget});
}

class FormPageData extends ListBase<FormPageDataElement> {
  List<FormPageDataElement> _data;

  int get length => _data.length;

  set length(int newLength) {
    _data.length = newLength;
  }

  String getErrorMessageFromUserInput() {
    try {
      return _data
      .where((element) => element.type == FormPageDataElementType.textfield && element.textfield.isRequired == true)
      .map((e) => e.textfield.errorMessageFromInput())
      .firstWhere((message) => message != null);
    } on StateError {
      return null;
    } catch (error) {
      throw error;
    }
  }

  void checkUserInput() {
    final errorMessage = getErrorMessageFromUserInput();
    if (errorMessage != null) {
      throw CustomException(errorMessage);
    }
  }
  
  @override
  FormPageDataElement operator [](int index) {
    return _data[index];
  }
  
  @override
  void operator []=(int index, FormPageDataElement value) {
    _data[index] = value;
  }

  FormPageData(List<FormPageDataElement> data) {
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
    widget.formPageData.where((element) => element.type == FormPageDataElementType.textfield).forEach ((field) {
      field.textfield.controller = TextEditingController();
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.formPageData.where((element) => element.type == FormPageDataElementType.textfield).forEach((field) => field.textfield.controller.dispose());
  }


  @override
  Widget build(BuildContext context) {
    widget.formPageData.where((element) => element.type == FormPageDataElementType.textfield).forEach ((field) {
      field.textfield.controller.text = field.textfield.initialText;
    });

    return Scaffold(
        backgroundColor: MyStyles.of(context).colors.background1,
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
                        Row(
                          children: [
                            SizedBox(width: 10),
                            InkWell(
                              child: Text("←", style: MyStyles.of(context).textThemes.h3,),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: MyStyles.of(context).textThemes.h2,
                        ),
                        if (widget.subheading != null) 
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                widget.subheading,
                                textAlign: TextAlign.center,
                                style: MyStyles.of(context).textThemes.h3,
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
                          children: <Widget>[
                            (() {
                              switch (element.type) {
                                case FormPageDataElementType.textfield:
                                  final textField = element.textfield;
                                  return Column(
                                    children: <Widget>[
                                      if (textField.title != null && textField.title.isNotEmpty)
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text(textField.title, textAlign: TextAlign.start, style: MyStyles.of(context).textThemes.bodyText3)
                                        ),
                                      
                                      () {
                                        switch (textField.type) {
                                          case FormFieldDataType.email:
                                            return StyleTextField.email(
                                              controller: textField.controller,
                                              isRequired: textField.isRequired,
                                            );

                                          case FormFieldDataType.password:
                                            return StyleTextField.password(
                                              controller: textField.controller,
                                            );

                                          case FormFieldDataType.phoneNumber:
                                            return StyleTextField.phoneNumber(
                                              controller: textField.controller,
                                              isRequired: textField.isRequired,
                                            );

                                          case FormFieldDataType.custom:
                                            String placeholderText = (){
                                              if (textField.placeholderText != null) {
                                                if (textField.isRequired) {
                                                  return textField.placeholderText;
                                                } else {
                                                  return "${textField.placeholderText} (Optional)";
                                                }
                                              } else {
                                                return null;
                                              };
                                            }();

                                            return StyleTextField(
                                              controller: textField.controller,
                                              placeholderText: placeholderText,
                                              maxLines: textField.maxLines,
                                              getErrorMessage: textField.checkError,
                                            );
                                        }
                                      } (),
                                      
                                    ],
                                  );

                                case FormPageDataElementType.checkbox:
                                  final checkboxData = element.checkbox;
                                  return CheckboxListTile(
                                    title: Text(checkboxData.title, style: MyStyles.of(context).textThemes.bodyText2),
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    value: checkboxData.isOn,
                                    onChanged: (bool value) {
                                      setState(() {
                                        checkboxData.isOn = value;  
                                      });
                                    },
                                  );

                                case FormPageDataElementType.widget:
                                  return element.widget;
                                }            
                            } ()),
                            SizedBox(height: 12),
                          ],
                        );             
                      }).toList()
                    ),
                  ),
                  Spacer(),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    child: Consumer<User>(
                      builder: (context, user, _) {
                        return AccentedActionButton(
                          width: 233,
                          height: 55,
                          text: "Continue",
                          onPressed: () async {
                            widget.formPageData.checkUserInput();
                            await widget.onPressed(widget.formPageData);
                          },

                          onSuccess: widget.onSuccess,
                        );
                      }
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
          ),
      );
  }
}