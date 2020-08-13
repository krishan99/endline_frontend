import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/components/buttons.dart';
import 'package:business_app/theme/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:business_app/utils.dart';
import 'package:business_app/services/services.dart';

import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/business_app/screens/form_page.dart';
import 'package:intl/intl.dart';

class AccountSettings extends StatelessWidget {
  final User user;

  const AccountSettings({
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: "Account Settings",
      formPageData: FormPageData([
        FormPageDataElement.textfield(TextFieldFormData(
            placeholderText: "Edit Queue Name",
            initialText: user.businessName,
            isRequired: true,
            title: "Business Name",
            maxLines: 1)),
        FormPageDataElement.textfield(TextFieldFormData(
            placeholderText: "Edit Queue Description",
            initialText: user.businessDescription,
            isRequired: false,
            title: "Business Description",
            maxLines: 4)),
        FormPageDataElement.widget(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              AccentedActionButton.light(
                  context: context,
                  text: "Sign Out ",
                  height: 50,
                  width: MediaQuery.of(context).size.width / 3,
                  onPressed: () async {
                    await user.signOut();
                    Navigator.of(context).popAndPushNamed("/home");
                  }),
            ])),
      ]),
      onPressed: (form) async {
        await user.updateUserData(
            name: form[0].textfield.text, description: form[1].textfield.text);
      },
      onSuccess: () {
        Navigator.of(context).pop();
      },
    );
  }
}
