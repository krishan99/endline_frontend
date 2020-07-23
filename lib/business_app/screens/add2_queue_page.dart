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

class Add2Queue extends StatelessWidget {
  @override
  final Queue queue;

  Add2Queue(this.queue);

  Widget build(BuildContext context) {
    return FormPage(
      title: "Add Someone to the Queue",
      formPageData: FormPageData([
        FormFieldData(placeholderText: "Enter Name"),
        FormFieldData(placeholderText: "Enter Phone Number", maxLines: 1)
      ]),
      onPressed: (formData) async {
        if (formData[0].text.isEmpty) {
          throw CustomException("You must enter a name.");
        }
        queue.people.add2Queue(
            name: formData[0].text, id: queue.id, phone: formData[1].text);
      },
      onSuccess: () => Navigator.pop(context),
    );
  }
}
