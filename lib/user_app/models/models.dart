//When this file gets to big, split into multiple files.

import 'package:business_app/user_app/services/services.dart';
import 'package:flutter/material.dart';

class ModelData {
  User user;
  UAppServer server;

  ModelData() {
    user = User();
    server = UAppServer();
  }
}

class QueueReqs {
  final int qid;
  final String code;
  final String queueDescription;
  final String businessName;
  final bool needsName;
  final bool needsPhoneNumber;

  QueueReqs({
    this.qid,
    this.code,
    this.queueDescription,
    this.businessName,
    this.needsName,
    this.needsPhoneNumber,
  });

  static QueueReqs fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return QueueReqs(
      qid: map['qid'] as int,
      code: map['code'] as String,
      queueDescription: map['description'] as String,
      businessName: map['business'] as String,
      needsName: (map.containsKey("Name: ")),
      needsPhoneNumber: map.containsKey('Phone: '),
    );
  }

}

class User extends ChangeNotifier {
  String name;
  String phoneNumber;
  String notes;
}

