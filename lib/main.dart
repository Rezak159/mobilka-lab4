import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'calendar_state.dart';
import 'event.dart';
import 'event_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 183, 58, 114),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('ru')],
      locale: Locale('ru'),
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarState state = CalendarState();

  List<String> months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];
  List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void initState() {
    super.initState();
    state.addListener(() {
      setState(() {});
    });
    state.load();
  }

  String formatTime(TimeOfDay t) {
    String m = t.minute.toString();
    if (t.minute < 10) {
      m = '0' + m;
    }
    return t.hour.toString() + ':' + m;
  }

  Widget dayCell(DateTime date) {
    bool isSelected = state.sameDay(date, state.selected);
    bool isToday = state.sameDay(date, DateTime.now());
    var events = state.eventsForDay(date);

    return InkWell(
      onTap: () {
        state.selectDay(date);
      },
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: isSelected
                ? BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected == true
                    ? Colors.white
                    : isToday
                    ? Theme.of(context).colorScheme.primary
                    : null,
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
          ),
          if (events.isNotEmpty)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: categoryColor(events[0].category),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildGrid() {
    var first = DateTime(state.month.year, state.month.month, 1);
    int offset = first.weekday - 1;
    int days = DateTime(state.month.year, state.month.month + 1, 0).day;

    List<Widget> cells = [];
    for (int i = 0; i < offset; i++) {
      cells.add(Container());
    }
    for (int d = 1; d <= days; d++) {
      cells.add(dayCell(DateTime(state.month.year, state.month.month, d)));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      childAspectRatio: 1.1,
      physics: NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  @override
  Widget build(BuildContext context) {
    var events = state.eventsForDay(state.selected);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Календарь'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  state.prevMonth();
                },
                icon: Icon(Icons.chevron_left),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    var d = await showDatePicker(
                      context: context,
                      initialDate: state.selected,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      initialDatePickerMode: DatePickerMode.year,
                    );
                    if (d != null) {
                      state.goTo(d);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        months[state.month.month - 1] +
                            ' ' +
                            state.month.year.toString(),
                        style: TextStyle(fontSize: 22),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  state.nextMonth();
                },
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              for (var w in weekDays)
                Expanded(
                  child: Center(
                    child: Text(w, style: TextStyle(color: Colors.grey)),
                  ),
                ),
            ],
          ),
          buildGrid(),
          SizedBox(height: 10),
          Text(
            'События на ' +
                state.selected.day.toString() +
                '.' +
                state.selected.month.toString() +
                '.' +
                state.selected.year.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Text(events.length.toString()),
          if (events.isEmpty)
            Padding(padding: EdgeInsets.all(10), child: Text('Событий нет')),
          for (var e in events)
            ListTile(
              leading: Icon(
                Icons.circle,
                size: 14,
                color: categoryColor(e.category),
              ),
              title: Text(e.title),
              subtitle: Text(
                formatTime(e.start) +
                    ' - ' +
                    formatTime(e.end) +
                    '   ' +
                    e.category,
              ),
              trailing: IconButton(
                onPressed: () {
                  state.deleteEvent(e.id);
                },
                icon: Icon(Icons.delete),
              ),
              onTap: () async {
                var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventScreen(event: e, date: e.date),
                  ),
                );
                if (res != null) {
                  state.editEvent(res);
                }
              },
            ),
          SizedBox(height: 70),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventScreen(date: state.selected),
            ),
          );
          if (res != null) {
            state.addEvent(res);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
