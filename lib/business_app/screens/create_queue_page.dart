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
  @override
  final AllQueuesInfo qinfo;

  CreateQueue(this.qinfo);
  Widget build(BuildContext context) {
    return FormPage(
      title: "Create a Queue",
      formPageData: FormPageData([
        FormFieldData(
          placeholderText: "Enter Queue Name",
          checkError: (text) {
            if (text != null && text.length < 5) {
              return "Queue name must be at least 5 characters.";
            } else {
              return null;
            }
          }),
        FormFieldData(placeholderText: "Enter Queue Description (Optional)", maxLines: 3)
      ]),
      onPressed: (formData) async {
        if (formData[0].text.isEmpty) {
          throw CustomException("You must enter a queue name.");
        }
        qinfo.makeQueue(formData[0].text, formData[1].text);
      },
      onSuccess: () => Navigator.pop(context),
    );
  }
}
