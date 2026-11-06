import 'package:flutter/material.dart';

import 'event.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key, this.event, required this.date});

  final Event? event;
  final DateTime date;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  late DateTime date;
  TimeOfDay start = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay end = TimeOfDay(hour: 10, minute: 0);
  String category = 'Учёба';
  String timeError = '';

  @override
  void initState() {
    super.initState();
    date = widget.date;
    if (widget.event != null) {
      controller.text = widget.event!.title;
      date = widget.event!.date;
      start = widget.event!.start;
      end = widget.event!.end;
      category = widget.event!.category;
    }
  }

  String timeText(TimeOfDay t) {
    return t.hour.toString() + ':' + t.minute.toString().padLeft(2, '0');
  }

  void save() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (end.hour * 60 + end.minute <= start.hour * 60 + start.minute) {
      setState(() {
        timeError = 'Конец должен быть позже начала';
      });
      return;
    }

    int id = 0;
    if (widget.event != null) {
      id = widget.event!.id;
    }

    Navigator.pop(
      context,
      Event(id, controller.text.trim(), date, start, end, category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.event == null ? 'Новое событие' : 'Редактирование'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: [
            TextFormField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Название'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название события';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(
                'Дата: ' +
                    date.day.toString() +
                    '.' +
                    date.month.toString() +
                    '.' +
                    date.year.toString(),
              ),
              trailing: Icon(Icons.calendar_month),
              onTap: () async {
                var d = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (d != null) {
                  setState(() {
                    date = d;
                  });
                }
              },
            ),
            ListTile(
              title: Text('Начало: ' + timeText(start)),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                var t = await showTimePicker(
                  context: context,
                  initialTime: start,
                );
                if (t != null) {
                  setState(() {
                    start = t;
                    timeError = '';
                  });
                }
              },
            ),
            ListTile(
              title: Text('Конец: ' + timeText(end)),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                var t = await showTimePicker(
                  context: context,
                  initialTime: end,
                );
                if (t != null) {
                  setState(() {
                    end = t;
                    timeError = '';
                  });
                }
              },
            ),
            if (timeError != '')
              Text(timeError, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            Text('Категория'),
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: categories.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 14, color: categoryColor(c)),
                      SizedBox(width: 10),
                      Text(c),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  category = v!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                save();
              },
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
