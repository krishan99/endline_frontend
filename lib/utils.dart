//Generally helpful functions should go here.

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

class Utils {
  BuildContext context;

  static String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds~/Duration.secondsPerDay;
    seconds -= days*Duration.secondsPerDay;
    final hours = seconds~/Duration.secondsPerHour;
    seconds -= hours*Duration.secondsPerHour;
    final minutes = seconds~/Duration.secondsPerMinute;
    seconds -= minutes*Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0){
      tokens.add('${hours}h');
    }
    // if (tokens.isNotEmpty) {
      tokens.add('${minutes}m');
    // }
    // tokens.add('${seconds}s');

    return tokens.join(' ');
  }

  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static Future<Uint8List> getQrCode(String url) async {
    final uiImage = await QrPainter(
      data: url,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImage(300);

    final bytesData = await uiImage.toByteData(format: ImageByteFormat.png);
    final unit8List = bytesData.buffer.asUint8List();

    return unit8List;
  }

  static Widget getBasicTextPage(String text) {
    return Scaffold(
      body: Container(
      padding: EdgeInsets.all(40),
      alignment: Alignment.center,
        child: Text(text, textAlign: TextAlign.center,),
      ),
    );
  }

  Widget getLoadingScreenAndNavigate({@required String route, dynamic arguments, String loadingText = "Loading..."}) {
    Future.microtask(() => Navigator.of(context).pushReplacementNamed(route, arguments: arguments));
    return getBasicTextPage(loadingText);
  }

  static Widget getServerErrorPage() {
    return getBasicTextPage("There was an error contacting the server. Make sure you have internet.");
  }

  static Future<String> getInstructionPDFPath(String code) async {
    final output = await getTemporaryDirectory();
    final path = "${output.path}/${code}.pdf";

    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        var barcodeWidget = pw.BarcodeWidget(
            data: "https://endline-app.github.io/#/$code",
            width: 200,
            height: 200,
            barcode: pw.Barcode.qrCode()
          );

        return 
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Scan with Camera",
                            textScaleFactor: 4.0,
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 20),
                          barcodeWidget
                        ]
                      )
                )
          ])
          ]
        );
              
      }
    ));

    final file = File(path);
    await file.writeAsBytes(pdf.save());
    return path;
  }

  void toastMessage(String message) {
    Toast.show(message.toString(), context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void showErrorDialog({@required String title, @required String body}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
    }
  );
}

  static Utils of(BuildContext context) {
    return Utils(context);
  } 

  Utils(BuildContext context) {
    this.context = context;
  }
}




