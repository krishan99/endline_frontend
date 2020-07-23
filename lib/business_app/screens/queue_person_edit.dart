import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/business_app/screens/form_page.dart';
import 'package:business_app/services/services.dart';

class QueuePersonDescription extends StatelessWidget {
  QueuePerson person;

  QueuePersonDescription({
    Key key,
    @required this.person,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String subheading = "";
    if (person.phone != null) 
      subheading += "Phone Number: ${person.phone}";
    
    if (person.time != null)
      if (subheading.isNotEmpty)
        subheading += " | ";
      subheading += "Time Joined: ${person.time}";
    
    return FormPage(
      title: "Edit ${person.name ?? "Person"}",
      subheading: subheading,
      formPageData: FormPageData(
        [
          FormFieldData(
            placeholderText: "Add any notes for this person...",
            initialText: person.note,
            maxLines: 4
          )
        ]
      ),
      onPressed: (form) async {
        await person.updateToServer(note: form[0].text);
      },

      onSuccess: () {
        Navigator.of(context).pop();
      },
    );
  }
}
