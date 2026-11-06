import 'package:flutter/material.dart';

import 'event.dart';
import 'event_repository.dart';

class CalendarState extends ChangeNotifier {
  EventRepository repo = EventRepository();
  DateTime selected = DateTime.now();
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  void load() async {
    await repo.load();
    notifyListeners();
  }

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Event> eventsForDay(DateTime day) {
    List<Event> list = [];

    for (var e in repo.getAll()) {
      if (sameDay(e.date, day)) {
        list.add(e);
      }
    }

    list.sort((a, b) {
      int x = a.start.hour * 60 + a.start.minute;
      int y = b.start.hour * 60 + b.start.minute;
      return x.compareTo(y);
    });

    return list;
  }

  void selectDay(DateTime day) {
    selected = day;
    notifyListeners();
  }

  void nextMonth() {
    month = DateTime(month.year, month.month + 1);
    notifyListeners();
  }

  void prevMonth() {
    month = DateTime(month.year, month.month - 1);
    notifyListeners();
  }

  void goTo(DateTime d) {
    selected = d;
    month = DateTime(d.year, d.month);
    notifyListeners();
  }

  void addEvent(Event e) {
    print('add ' + e.title);
    repo.add(e);
    selected = e.date;
    month = DateTime(e.date.year, e.date.month);
    notifyListeners();
  }

  void editEvent(Event e) {
    repo.update(e);
    selected = e.date;
    month = DateTime(e.date.year, e.date.month);
    notifyListeners();
  }

  void deleteEvent(int id) {
    repo.delete(id);
    notifyListeners();
  }
}
