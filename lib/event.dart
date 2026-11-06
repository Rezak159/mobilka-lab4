import 'package:flutter/material.dart';

class Event {
  int id;
  String title;
  DateTime date;
  TimeOfDay start;
  TimeOfDay end;
  String category;

  Event(this.id, this.title, this.date, this.start, this.end, this.category);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toString(),
      'startHour': start.hour,
      'startMinute': start.minute,
      'endHour': end.hour,
      'endMinute': end.minute,
      'category': category,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['id'],
      json['title'],
      DateTime.parse(json['date']),
      TimeOfDay(hour: json['startHour'], minute: json['startMinute']),
      TimeOfDay(hour: json['endHour'], minute: json['endMinute']),
      json['category'],
    );
  }
}

List<String> categories = ['Учёба', 'Работа', 'Личное', 'Спорт'];

Color categoryColor(String c) {
  if (c == 'Учёба') {
    return Colors.blue;
  }
  if (c == 'Работа') {
    return Colors.orange;
  }
  if (c == 'Спорт') {
    return Colors.purple;
  }
  return Colors.green;
}
