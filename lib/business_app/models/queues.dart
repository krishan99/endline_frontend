import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/services/services.dart';
import 'package:intl/intl.dart';

import '../../utils.dart';

// BusinessAppServer server = new BusinessAppServer();

enum QueueEntryState {
  notified,
  pendingNotification,
  waiting,
  pendingDeletion,
  deleted
}

class QueuePerson with ChangeNotifier {
  int id;
  String _name;
  String _note;
  String _phone;
  DateTime _time;

  String get name => _name;
  String get note => _note;
  set note(note) {
    _updateFromData(note: note);
  }

  String get phone => _phone;
  DateTime get time => _time;

  QueueEntryState _state;
  QueueEntryState get state => _state;

  set state(QueueEntryState newValue) {
    _state = newValue;
    notifyListeners();
  }

  String get formattedTime => DateFormat.jm().format(time.toLocal());

  Duration getDurationSinceAdded() {
    return DateTime.now().difference(time);
  }

  String getFormattedTimeSinceAdded() {
    return Utils.formatDuration(getDurationSinceAdded());
  }

  void _updateFromData(
      {String name, String note, String phone, DateTime time}) {
    _name = name ?? _name;
    _note = note ?? _note;
    _phone = phone ?? _phone;
    _time = time ?? _time;
    notifyListeners();
  }

  static QueuePerson fromMap(Map<String, dynamic> map) {
    final utcTime = DateTime.parse(map["created"]);

    QueueEntryState state;

    if (map["notified"] != null) {
      state = (map["notified"] as int) == 0
          ? QueueEntryState.waiting
          : QueueEntryState.notified;
    } else {
      state = QueueEntryState.waiting;
    }

    return QueuePerson(
        id: map["id"],
        name: map["name"],
        note: map["note"],
        phone: map["phone"],
        state: state,
        time: DateTime.utc(utcTime.year, utcTime.month, utcTime.day,
            utcTime.hour, utcTime.minute, utcTime.second));
  }

  QueuePerson({
    @required this.id,
    String name,
    String note,
    String phone,
    DateTime time,
    QueueEntryState state = QueueEntryState.waiting,
  }) {
    this._name = name;
    this._note = note;
    this._state = state;
    this._phone = phone;
    this._time = time ?? DateTime.now();
  }
}

enum QueueState { active, inactive }

class Queue with ChangeNotifier {
  final int id;
  String _name;
  String _description;
  String _code;

  String get name => _name;
  String get description => _description;
  String get code => _code;

  int get length => body.length;

  QueueState _state;
  QueueState get state => _state;
  set state(QueueState newValue) {
    if (_state != newValue && newValue == QueueState.active) {
      _numCompleted = 0;
    }

    _state = newValue;
    notifyListeners();
  }

  List<QueuePerson> body = [];

  int _numCompleted = 0;
  int get numCompleted => _numCompleted;

  int get numWaiting {
    return _getNumOfState(QueueEntryState.waiting);
  }

  int get numNotified {
    return _getNumOfStates(
        [QueueEntryState.notified, QueueEntryState.pendingNotification]);
  }

  int get numCurrentlyOn {
    return numWaiting + numNotified;
  }

  static Queue fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Queue(
        id: map['qid'],
        name: map['qname'],
        description: map['description'],
        code: map['code'],
        state: map['active'] == 1 ? QueueState.active : QueueState.inactive);
  }

  Map<String, dynamic> toMap() {
    return {
      'qid': id,
      'qname': name,
      'description': description,
      'code': code,
      'active': (state == QueueState.active) ? 1 : 0,
    };
  }

  void connectSocket() {
    print("update $id");
    BusinessAppServer.socket.on("update $id", (data) {
      List<Map<String, dynamic>> serverLineAsMaps =
          (data["line"] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();
      List<QueuePerson> serverLine =
          serverLineAsMaps.map((e) => QueuePerson.fromMap(e)).toList();

      if (serverLine.length == 0) {
        print("something");
      }

      updateFromSever(serverLine);
    });
  }

  int _getNumOfStates(List<QueueEntryState> states) {
    return body.where((k) => states.contains(k.state)).toList().length;
  }

  int _getNumOfState(QueueEntryState state) {
    return _getNumOfStates([state]);
  }

  void updateFromSever(List<QueuePerson> serverLine) {
    body = serverLine;
    notifyListeners();
  }

  void toggleState() {
    this.state = this.state == QueueState.active
        ? QueueState.inactive
        : QueueState.active;
  }

  Future<void> remove(int personId) async {
    assert(body.where((person) => person.id == personId).length == 1);
    body.removeWhere((element) => element.id == personId);
    await BusinessAppServer.deletePerson(id, personId);
    _numCompleted += 1;
    notifyListeners();
  }

  Future<void> notify(int personId) async {
    final personIndex = body.indexWhere((element) => element.id == personId);
    assert(personIndex != -1);

    final oldState = body[personIndex].state;

    body[personIndex].state = QueueEntryState.pendingNotification;

    try {
      await BusinessAppServer.notifyPerson(id, personId);
      body[personIndex].state = QueueEntryState.notified;
    } catch (error) {
      body[personIndex].state = oldState;
      throw error;
    }

    notifyListeners();
  }

  Future<void> reorderPerson(int oldIndex, int newIndex) async {
    BusinessAppServer.reorderPerson(
        person: body[oldIndex],
        qid: this.id,
        oldPersonId: body[oldIndex].id,
        newPersonId: body[newIndex].id);

    final temp = body[oldIndex];
    body.removeAt(oldIndex);

    if (newIndex == body.length) {
      body.add(temp);
    } else {
      body.insert(newIndex, temp);
    }

    notifyListeners();
  }

  Future<void> addPerson(
      {@required String name, @required int id, String phone}) async {
    if (body.indexWhere((element) => element.id == id) == -1) {
      body.add(QueuePerson(id: -1, name: name, phone: phone));
      notifyListeners();
    }

    await BusinessAppServer.addToQueue(name: name, phoneNumber: phone, qid: id);
  }

  void update(Queue info) {
    _name = info.name ?? _name;
    _description = info.description ?? _description;
    _code = info.code ?? _code;
    state = state ?? info.state;
    notifyListeners();
  }

  void _updateFromData({String name, String desc}) {
    _name = name ?? _name;
    _description = desc ?? _description;
    notifyListeners();
  }

  void listen() {
    BusinessAppServer.joinRoom(id);
  }

  Future<void> updateQueue({String name, String desc}) async {
    _updateFromData(name: name, desc: desc);
    await BusinessAppServer.updateQueue(this);
  }

  Queue(
      {this.id,
      String name,
      String description,
      QueueState state = QueueState.inactive,
      String code}) {
    this._name = name;
    this._description = description;
    this._state = QueueState.inactive;
    this._code = code;
  }
}

class AllQueuesInfo with ChangeNotifier {
  List<Queue> _queues = [];
  List<Queue> get queues => _queues;

  Future<void> refresh() async {
    this._queues = await BusinessAppServer.getListofQueues();
    notifyListeners();
  }

  Future<void> makeQueue(
      {String name, String description}) async {
    Queue queue = await BusinessAppServer.makeQueue(name, description);
    _queues.add(queue);
    notifyListeners();
  }

  Future<void> deleteQueue(int qid) async {
    final queue = _queues.where((element) => element.id == qid).toList()[0];

    await BusinessAppServer.deleteQueue(queue);
    _queues.removeWhere((element) => element.id == qid);
    notifyListeners();
  }

  AllQueuesInfo();
}
