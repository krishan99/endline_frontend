import 'dart:convert';

import 'package:business_app/services/services.dart';
import 'package:business_app/user_app/models/models.dart';
import 'package:flutter/material.dart';

class UAppServer extends MyServer {
  //TODO: Use firebase Token ID instead.
  
  Future<QueueReqs> getQueueReqs({@required String code}) async {
    final response = await post(
      "api/v1/queue/user/getform",
      body: <String, String> {
        "code": code,
      });
    
    return QueueReqs.fromMap(response);

    // return QueueReqs(code: "43-4", qid: 1, needsName: true, needsPhoneNumber: true);
  }

  Future<void> addToQueue({@required int qid, String name = "John Doe", String phoneNumber = ""}) async {
    await post(
      "/api/v1/queue/user/postform",
      body: <String, String> {
        "qid": qid.toString(),
        "name": name,
        "phone": phoneNumber,
      }
    );
  }

  UAppServer();
}