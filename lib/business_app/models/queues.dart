import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/services/services.dart';

BusinessAppServer server = new BusinessAppServer();

enum QueueEntryState {
  notified,
  pendingNotification,
  waiting,
  pendingDeletion,
  deleted
}

class QueuePerson with ChangeNotifier{
  int id;
  String _name;
  String _note;
  String _phone;
  String _time;

  String get name => _name;
  String get note => _note;
  String get phone => _phone;
  String get time => _time;

  QueueEntryState _state;
  QueueEntryState get state => _state;
  set state(QueueEntryState newValue) {
    _state = newValue;
    notifyListeners();
  }

  void update(Map<String, dynamic> info){
    _updateFromData(
      name: info["name"],
      note: info["note"],
      phone: info["phone"],
      time: info["created"]
    );
  }

  Future<void> updateToServer({String name, String note, String phone, String time}) async {
    _updateFromData(name: name, note: note, phone: phone, time: time);
    await server.updatePerson(this);
  }

  void _updateFromData({String name, String note, String phone, String time}) {
    _name = name ?? _name;
    _note = note ?? _note;
    _phone = phone ?? _phone;
    _time = time ?? _time;
    notifyListeners();
  }

  QueuePerson({
    @required this.id,
    String name,
    String note,
    QueueEntryState state = QueueEntryState.waiting,
  }) {
    this._name = name;
    this._note = note;
    this._state = state;
    this._phone = phone;
  }
}

class QueuePeople with ChangeNotifier {
  final int id;
  // this is an ordered map
  var theline = new SplayTreeMap<int, QueuePerson>();
  Iterable<QueuePerson> get body => theline.values;
  BusinessAppServer server;

  QueuePeople({
    this.id,
    @required this.server,
  }) {}

  void connectSocket () {
    print("update $id");
    BusinessAppServer.socket.on("update $id", (data) {
        print("hi");
        updateFromSever(data["line"]);
        notifyListeners();
    });
  }

  void updateFromSever(List<dynamic> serverLine){
    for(var i=0; i < serverLine.length; i++){
      int k = serverLine[i]["id"];
      if(!theline.containsKey(k)){
        theline[k]=new QueuePerson(id: k);
      }
      theline[k].update(serverLine[i]);
    }
    // delete anything not on server anymore
    var keys = theline.keys;
    var toRemove = [];
    for(var k in keys){
      bool there = false;
      for(var j=0; j<serverLine.length; j++){
        if(serverLine[j]["id"]==k){
          there=true;
          break;
        }
      }
      if(!there) toRemove.add(k);
    }

    toRemove.forEach((k) {theline.remove(k);});
  }

  int get numWaiting {
    return _getNumOfState(QueueEntryState.waiting);
  }

  int get numNotified {
    return _getNumOfStates([QueueEntryState.notified, QueueEntryState.pendingNotification]);
  }

  int get numCompleted {
    return _getNumOfStates([QueueEntryState.notified, QueueEntryState.pendingDeletion]);
  }

  int _getNumOfStates(List<QueueEntryState> states) {
    return theline.keys.where((k) => states.contains(theline[k].state)).length;
  }

  int _getNumOfState(QueueEntryState state) {
    return _getNumOfStates([state]);
  }

  void remove(int personId) async{
    if(!theline.containsKey(personId)){
      print("Invalid id to remove");
      return;
    }

    await server.deletePerson(id, personId);
    theline.remove(personId);
    notifyListeners();
  }
 
  void add2Queue({@required String name, @required int id, @required String phone}) {
    theline.putIfAbsent(-1, () => QueuePerson(id: -1, name: name));
    server.addToQueue(name: name, phoneNumber: phone, qid: id);
    notifyListeners();
  }
}

enum QueueState {
  active, inactive
}

class Queue with ChangeNotifier {
  final int id;
  String _name;
  String _description;
  String _code;
  QueueState _state;
  QueuePeople people;

  String get name => _name;
  String get description => _description;
  String get code => _code;
  QueueState get state => _state;
  set state(QueueState newValue) {
    _state = newValue;
    notifyListeners();
  }

  static Queue fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Queue(
      id: map['qid'],
      name: map['qname'],
      description: map['description'],
      code: map['code'],
    );
  }

  void update(Queue info){
    _name = info.name ?? _name;
    _description = info.description ?? _description;
    _code = info.code ?? _code;
    notifyListeners();
  }

  void listen() {
    BusinessAppServer.joinRoom(id);
  }

  Queue({
    this.id,
    String name,
    String description,
    QueueState state = QueueState.inactive,
    String code
  }){
    this._name = name;
    this._description = description;
    this._state = QueueState.inactive;
    this._code = code;
    this.people = QueuePeople(id: this.id, server: server);
  }
}

//TODO: Someone please make sure this is ok
class AllQueuesInfo with ChangeNotifier {
  final BusinessAppServer server;
  var queues = new Map<int, Queue>();
  Iterable<Queue> get body => queues.values;

  Future<void> retrieveServer() async {
    //This now returns a list of queues instead of maps
    var serverQueues = await server.getListofQueues();

    // update info based on server
    for(var i=0; i<serverQueues.length; i++){
      int k = serverQueues[i].id;
      if(!queues.containsKey(k)){
        queues[k]=new Queue(id: k);
      }
      queues[k].update(serverQueues[i]);
    }
    // delete anything not on server anymore
    var keys = queues.keys;
    var toRemove = [];
    for(var k in keys){
      bool there = false;
      for(var j=0; j<serverQueues.length; j++){
        if(serverQueues[j].id==k){
          there=true;
          break;
        }
      }
      if(!there) toRemove.add(k);
    }

    toRemove.forEach((element) {queues.remove(element as int);});
  }

  //TODO: Someone please make sure this is ok
  Future<void> makeQueue(String name, String description) async {
    Queue queue = await server.makeQueue(name, description);
    queues[queue.id] = queue;
    // int k = n["qid"];
    // queues[k] = new Queue(id: k);
    // queues[k].update(n);
    notifyListeners();
  }

  Future<void> deleteQueue(int qid) async {
    await server.deleteQueue(qid);
  }

  Future<void> refresh() async {
    retrieveServer();
    notifyListeners();
  }

  AllQueuesInfo({@required this.server});
}
