
import 'package:business_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum StyleTextFieldType { email, password }

enum StyleTextFieldStatus { neutral, error }

class StyleTextField extends StatelessWidget {
  final IconData icon;
  final StyleTextFieldStatus status;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final String Function(String) getErrorMessage;
  final String placeholderText;
  final TextInputType textInputType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;
  final int maxLines;
  final TextEditingController controller;

  StyleTextField(
    {Key key,
    this.controller,
    this.obscureText = false,
    this.textInputType,
    this.icon,
    this.getErrorMessage,
    this.status = StyleTextFieldStatus.neutral,
    this.onChanged,
    this.inputFormatters,
    this.onSubmitted,
    @required this.placeholderText,
    this.maxLines = 1}
  ) : super(key: key);


  factory StyleTextField.email({
    TextEditingController controller,
    StyleTextFieldStatus status = StyleTextFieldStatus.neutral,
    Function(String) onChanged,
    Function(String) onSubmitted,
  }) {
    return StyleTextField(
      controller: controller,
      icon: Icons.email,
      textInputType: TextInputType.emailAddress,
      status: status,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      placeholderText: "Email...",
      getErrorMessage: (text) {
        bool isValidEmail = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
        if (isValidEmail) {
          return null;
        } else {
          return "Email is not valid";
        }
      },
      maxLines: 1,
    );
  }

  factory StyleTextField.password({
    TextEditingController controller,
    String paceholderText,
    StyleTextFieldStatus status = StyleTextFieldStatus.neutral,
    Function(String) onChanged,
    Function(String) onSubmitted,
    String Function(String) getErrorMessage,
  }) {
    return StyleTextField(
      controller: controller,
      icon: Icons.panorama_fish_eye,
      textInputType: TextInputType.visiblePassword,
      obscureText: true,
      status: status,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      placeholderText: paceholderText ?? "Password...",
      getErrorMessage: getErrorMessage ?? (text) {
        if (text.length <= 5) {
          return "Password should contains more then 5 character";
        } else {
          return null;
        }
      },
      maxLines: 1,
    );
  }

  factory StyleTextField.phoneNumber({
    TextEditingController controller,
    String paceholderText,
    StyleTextFieldStatus status = StyleTextFieldStatus.neutral,
    Function(String) onChanged,
    Function(String) onSubmitted,
  }) {
    return StyleTextField(
      controller: controller,
      textInputType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      status: status,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      placeholderText: "Phone Number...",
      maxLines: 1,
    );
  }

  Color get borderColor {
    switch (status) {
      case StyleTextFieldStatus.neutral:
        return Colors.transparent;
      case StyleTextFieldStatus.error:
        return Colors.red;
    }
  }

  Color get iconColor {
    switch (status) {
      case StyleTextFieldStatus.neutral:
        return null;
      case StyleTextFieldStatus.error:
        return Colors.red;
    }
  }

  Alignment get textFieldFontAlignment {
    if (maxLines != null && maxLines <= 1) {
      return Alignment.center;
    } else {
      return Alignment.topLeft;
    }
  }

  EdgeInsets get insets {
    if (icon == null) {
      return EdgeInsets.only(left: 10);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            alignment: textFieldFontAlignment,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: MyStyles.of(context).colors.background1,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2))
                ]),
            padding: insets,
            child: FormField<String>(
              validator: getErrorMessage,
              initialValue: placeholderText,
              autovalidate: true,
              builder: (FormFieldState<String> state) {
                return Column(
                  children: [
                    TextFormField(
                      controller: controller,
                      keyboardType: textInputType,
                      obscureText: obscureText,
                      inputFormatters: inputFormatters,
                      onChanged: (text) {
                        if (onChanged != null) {
                          onChanged(text);
                        }
                        state.didChange(text);
                      },
                      onFieldSubmitted: onSubmitted,
                      maxLines: maxLines,
                      cursorColor: Colors.blue,
                      style: MyStyles.of(context)
                          .textThemes
                          .placeholder
                          .copyWith(color: Colors.grey[900]),
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        prefixIcon: (icon != null)
                            ? Icon(icon, color: iconColor)
                            : null,
                        hintStyle: MyStyles.of(context).textThemes.placeholder,
                        border: InputBorder.none,
                        hintText: placeholderText,
                      )
                    ),

                    if(state.errorText != null && controller.text.isNotEmpty)
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        alignment: Alignment.center,
                        child: Text(
                          state.errorText,
                          textAlign: TextAlign.center,
                          style: MyStyles.of(context).textThemes.errorSubText
                        ),
                      )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
