import 'dart:typed_data';

import 'package:business_app/theme/themes.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';

import 'package:business_app/utils.dart';

class PDFScreen extends StatelessWidget {
  final String code;

  const PDFScreen({
    Key key,
    @required this.code,
  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Utils.getInstructionPDFPath(code),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final path = snapshot.data as String;

          return PDFViewerScaffold(
            appBar: AppBar(
              backgroundColor: MyStyles.of(context).colors.accent,
              title: Text("Customer Instructions"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    try {
                      final ByteData bytes = await rootBundle.load(path);
                      await Share.file(
                          'instructions', 'temp.pdf', bytes.buffer.asUint8List(), 'temp/pdf');
                    } catch (e) {
                      print('error: $e');
                    }
                  },
                )
              ],
            ),
            path: path,
          );
        } else {
          return Utils.getBasicTextPage("Generating PDF");
        }
      }
    );
  }
}
