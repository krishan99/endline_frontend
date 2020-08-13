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

class QueueSettings extends StatelessWidget {
  final Queue queue;

  const QueueSettings({
    @required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: "Queue Settings",
      formPageData: FormPageData([
        FormPageDataElement.widget(Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AccentedActionButton.light(
                    context: context,
                    text: "Delete Queue",
                    height: 50,
                    width: MediaQuery.of(context).size.width / 3,
                    onPressed: () async {
                      await BusinessAppServer.deleteQueue(queue);
                      Navigator.of(context).popAndPushNamed("/dashboard");
                    }),
                SizedBox(width: MediaQuery.of(context).size.width / 18),
                AccentedActionButton.light(
                    context: context,
                    text: "Get QR Code",
                    height: 50,
                    width: MediaQuery.of(context).size.width / 3,
                    onPressed: () async {
                      Navigator.of(context)
                          .pushNamed("/pdfPage", arguments: queue.code);
                    }),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AccentedActionButton.light(
                    context: context,
                    text: "Clear Queue",
                    height: 50,
                    width: MediaQuery.of(context).size.width / 3,
                    onPressed: () async {
                      await BusinessAppServer.clearQueue(queue);
                      Navigator.of(context).pop();
                    })
              ],
            )
          ],
        )),
        FormPageDataElement.textfield(TextFieldFormData(
            placeholderText: "Edit Queue Name",
            initialText: queue.name,
            isRequired: true,
            title: "Queue Name",
            maxLines: 1)),
        FormPageDataElement.textfield(TextFieldFormData(
            placeholderText: "Edit Queue Description",
            initialText: queue.description,
            isRequired: false,
            title: "Queue Description",
            maxLines: 4))
      ]),
      onPressed: (form) async {
        await queue.updateQueue(
            name: form[1].textfield.text, desc: form[2].textfield.text);
      },
      onSuccess: () {
        Navigator.of(context).pop();
      },
    );
  }
}
