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
        FormPageDataElement.textfield(
          TextFieldFormData(
            placeholderText: "Enter Name",
            isRequired: true,
            maxLines: 1
          )
        ),
        FormPageDataElement.textfield(TextFieldFormData.phoneNumber(isRequired: false)),
      ]),
      onPressed: (formData) async {
        await queue.addPerson(
            name: formData[0].textfield.text, id: queue.id, phone: formData[1].textfield.text);
      },
      onSuccess: () => Navigator.pop(context),
    );
  }
}
