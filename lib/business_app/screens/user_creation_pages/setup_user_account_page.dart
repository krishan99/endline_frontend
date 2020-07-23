import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/screens/form_page.dart';
import 'package:business_app/components/buttons.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/components/textfields.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, _) {
      return FormPage(
        title: "Hello There!",
        subheading: "We're almost finished.",
        formPageData: FormPageData([
          FormFieldData(
            placeholderText: "Enter Business Name"
          ),
          FormFieldData(
            placeholderText: "Enter Business Description", maxLines: 6)
          ]
        ),
        
        onPressed: (formData) async {
          if (formData[0].text.isEmpty) {
            throw CustomException("You must enter a business name.");
          }

          await user.updateUserData(
            name: formData[0].text,
            description: formData[1].text
          );
        },

        onSuccess: () => Navigator.of(context).pushReplacementNamed("/dashboard"),
      );
    });
  }
}
