import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/business_app/screens/form_page.dart';
import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/theme/themes.dart';

class QueuePersonDescription extends StatelessWidget {
  final QueuePerson person;
  final int qid;

  const QueuePersonDescription({
    Key key,
    @required this.person,
    @required this.qid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: "${person.name ?? "Person"}",
      formPageData: FormPageData(
        [
          FormPageDataElement.widget(
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (person.phone != null && person.phone.isNotEmpty) 
                  Text("Phone Number: ${person.phone}", textAlign: TextAlign.center, style: MyStyles.of(context).textThemes.h4),

                if (person.time != null)
                  Text("Joined: ${person.formattedTime}", textAlign: TextAlign.center, style: MyStyles.of(context).textThemes.h4)
              ],
            )
          ),

          FormPageDataElement.textfield(
            TextFieldFormData(
              placeholderText: "Add any notes for this person...",
              initialText: person.note,
              isRequired: false,
              maxLines: 4
            )
          ),
        ]
      ),
      onPressed: (form) async {
        person.note = form[1].textfield.text;
        await BusinessAppServer.updatePerson(person, qid);
      },

      onSuccess: () {
        Navigator.of(context).pop();
      },
    );
  }
}
