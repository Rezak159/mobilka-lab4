import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'event.dart';

class EventRepository {
  List<Event> events = [];
  int lastId = 0;

  Future<void> load() async {
    var prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('events');
    if (data == null) {
      return;
    }

    List list = jsonDecode(data);
    events = list.map((e) => Event.fromJson(e)).toList();

    for (var e in events) {
      if (e.id > lastId) {
        lastId = e.id;
      }
    }
  }

  void save() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'events',
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  List<Event> getAll() {
    return events;
  }

  void add(Event e) {
    lastId++;
    e.id = lastId;
    events.add(e);
    save();
  }

  void update(Event e) {
    for (int i = 0; i < events.length; i++) {
      if (events[i].id == e.id) {
        events[i] = e;
      }
    }
    save();
  }

  void delete(int id) {
    events.removeWhere((e) => e.id == id);
    save();
  }
}
