import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/business_app/screens/form_page.dart';
import 'package:business_app/components/buttons.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/components/textfields.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateQueue extends StatelessWidget {
  Widget build(BuildContext context) {
    return FormPage(
      title: "Create a Queue",
      formPageData: FormPageData([
        FormPageDataElement.textfield(
          TextFieldFormData(
            placeholderText: "Enter Queue Name",
            isRequired: true,
            maxLines: 1,
            checkError: (text) {
              if (text != null && text.length < 5) {
                return "Queue name must be at least 5 characters.";
              } else {
                return null;
              }
            }
          )
        ),
        
        FormPageDataElement.textfield(
          TextFieldFormData(
            isRequired: false,
            placeholderText: "Enter Queue Description",
            maxLines: 3
          )
        )
      ]),
      onPressed: (formData) async {
        formData.checkUserInput();

        final name = formData[0].textfield.text;
        final description = formData[1].textfield.text;

        AllQueuesInfo qinfo = Provider.of<AllQueuesInfo>(context, listen: false);

        await qinfo.makeQueue(
          name: name,
          description: description,
        );
      },
      onSuccess: () => Navigator.pop(context),
    );
  }
}
