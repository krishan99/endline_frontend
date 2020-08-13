import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/services/services.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class BusinessAppServer extends MyServer {
  static const String _tokenHeader = "Authorization";

  static IO.Socket socket = IO.io(MyServer.socketPath, <String, dynamic>{
    'transports': ['websocket'],
    'autoconnect': false,
    'extraHeaders': MyServer.headers
  });

  static bool connectSocket() {
    socket.connect();
    socket.on('connect', (_) {
      print('Connected to socket');
    });
    return true;
  }

  static bool joinRoom(int qid) {
    socket.emit('join', {'qid': qid});
    return true;
  }

  static Future<Map<String, dynamic>> signIn({@required String token}) async {
    _setToken(token);

    return await MyServer.post("api/v1/account/signin",
        body: <String, String>{});
  }

//qid: x, id: y, note:'new note', new_id:w
  static Future<void> reorderPerson(
      {@required QueuePerson person,
      @required int qid,
      int oldPersonId,
      int newPersonId}) async {
    await MyServer.post("/api/v1/queue/manage/update_person",
        body: <String, String>{
          "qid": "$qid",
          "id": "${oldPersonId ?? person.id}",
          "note": "${person.note}",
          "new_id": "${newPersonId ?? ""}",
        });
  }

  static Future<void> updatePerson(QueuePerson person, int qid) async {
    await reorderPerson(person: person, qid: qid);
  }

  static void signOut() {
    MyServer.resetHeaders();
  }

  static Future<void> signUp(
      {@required String token, String name, String description}) async {
    _setToken(token);

    await MyServer.post("api/v1/account/signup", body: <String, String>{
      "name": name ?? "",
      "description": description ?? ""
    });
  }

  static void _setToken(String token) {
    MyServer.headers[_tokenHeader] = token;
  }

  static Future<void> updateUserData(
      {@required String name, @required String description}) async {
    await MyServer.post("api/v1/account/update",
        body: <String, String>{"name": name, "description": description});
  }

  static Future<List<Queue>> getListofQueues() async {
    Map<String, dynamic> body = await MyServer.get("api/v1/queue/retrieve_all");
    return (body["queues"] as List)
        .map((queueMapObject) =>
            Queue.fromMap(queueMapObject as Map<String, dynamic>))
        .toList();
  }

  static Future<Queue> makeQueue(String name, String description) async {
    Map<String, dynamic> body =
        await MyServer.post("api/v1/queue/make", body: <String, String>{
      "qname": name,
      "description": description,
    });

    return Queue.fromMap(body);
  }

  static Future<void> updateQueue(Queue queue) async {
    await MyServer.post("api/v1/queue/update", body: queue.toMap());
  }

  static Future<void> clearQueue(Queue queue) async {
    await MyServer.post("api/v1/queue/manage/remove_all", body: <String, int>{
      "qid": queue.id,
    });
  }

  static Future<void> deleteQueue(Queue queue) async {
    if (queue.numCurrentlyOn != 0) {
      throw CustomException("There is still ${queue.numCurrentlyOn} ${queue.numCurrentlyOn == 1 ? "person" : "people"} on the queue.");
    }

    await MyServer.post("api/v1/queue/delete", body: <String, int>{
      "qid": queue.id,
    });
  }

  static Future<void> deletePerson(int qid, int person_id) async {
    await MyServer.post("api/v1/queue/manage/delete", body: <String, int>{
      "qid": qid,
      "id": person_id,
    });
  }

  static Future<void> notifyPerson(int qid, int person_id) async {
    await MyServer.post("api/v1/queue/manage/notify", body: <String, int>{
      "qid": qid,
      "id": person_id,
    });
  }

  static Future<void> addToQueue(
      {@required int qid,
      String name = "John Doe",
      String phoneNumber = ""}) async {
    await MyServer.post("api/v1/queue/user/postform", body: <String, String>{
      "qid": qid.toString(),
      "name": name,
      "phone": phoneNumber,
    });
  }

  // BusinessAppServer._();
}
