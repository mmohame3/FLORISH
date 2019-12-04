import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:Florish/helpers/database_helpers.dart' as database;
import 'package:Florish/globals.dart' as globals;
import 'package:sqflite/sqflite.dart';
import 'package:Florish/homeScreen/homeScreenLayout.dart' as mainPage;

class Calendar extends StatefulWidget {
  final ValueChanged<database.Day> parentAction;
  const Calendar({Key key, this.parentAction}) : super(key: key);

  @override
  _CalendarState createState() => new _CalendarState();
}

class _CalendarState extends State<Calendar> {
  _CalendarState() {
    determineDay(DateTime.now()).then((calendarSelectedDay) => setState(() {
          globals.today = calendarSelectedDay;
        }));
  }

  Future<database.Day> determineDay(DateTime date) async {
//    DateTime time = DateTime.now();
//    DateTime yesterday = time.subtract(Duration(days: 1));
//    Database db = await DatabaseHelper.instance.database;
//
//    if (time.hour < resetTime) {
//      time = yesterday;
//    }

    Database db = await database.DatabaseHelper.instance.database;
    String selectedDate = mainPage.dateTimeToString(date);
    List<Map> result =
        await db.rawQuery('SELECT * FROM days WHERE day=?', [selectedDate]);

    database.Day day;
    double yesterHyd;

    if (result == null || result.isEmpty) {
      Future<List> yesterInfo = mainPage.getYesterInfo();
      yesterInfo.then((list) {
        yesterHyd = list[1];
      });
      yesterHyd ??= 0.0;

      day = new database.Day(
          date: selectedDate,
          hourList: new List<int>(),
          minuteList: new List<int>(),
          typeList: new List<int>(),
          maxBAC: 0.0,
          waterAtMaxBAC: 0,
          totalDrinks: 0,
          totalWaters: 0,
          sessionList: new List<int>(),
          hydratio: 0.0,
          yesterHydratio: yesterHyd,
          lastBAC: 0.0);

      await db.insert(database.tableDays, day.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return day;
    } else {
// alternate (read: better) way #2
      day = database.Day.fromMap(result[0]);

      day.sessionList ??= new List<int>();
      day.hourList ??= new List<int>();
      day.minuteList ??= new List<int>();
      day.typeList ??= new List<int>();

      day.hourList = new List<int>.from(day.hourList);
      day.minuteList = new List<int>.from(day.minuteList);
      day.typeList = new List<int>.from(day.typeList);
      day.sessionList = new List<int>.from(day.sessionList);

      return day;
    }
  }

  static Widget _soberIcon(String day) => Container(
      decoration: BoxDecoration(
          color: Color(0xFFF0F086),
          borderRadius: BorderRadius.all(Radius.circular(1000))),
      child: Center(
          child: Text(
        day,
        style: TextStyle(color: Colors.black),
      )));

  static Widget _tipsyIcon(String day) => Container(
      decoration: BoxDecoration(
          color: Color(0xFFF0BF72),
          borderRadius: BorderRadius.all(Radius.circular(1000))),
      child: Center(
          child: Text(
        day,
        style: TextStyle(color: Colors.black),
      )));

  static Widget _drunkIcon(String day) => Container(
      decoration: BoxDecoration(
          color: Color(0xFFEB9800),
          borderRadius: BorderRadius.all(Radius.circular(1000))),
      child: Center(
          child: Text(
        day,
        style: TextStyle(color: Colors.black),
      )));

  static Widget _veryDrunkIcon(String day) => Container(
      decoration: BoxDecoration(
          color: Color(0xFFC53E3E),
          borderRadius: BorderRadius.all(Radius.circular(1000))),
      child: Center(
          child: Text(
        day,
        style: TextStyle(color: Colors.black),
      )));

  EventList<Event> _markedDateMap = new EventList<Event>(events: {});
  static String noEventText = "No event here";
  String calendarText = noEventText;
  DateTime _currentDate = DateTime.now();

  // Where BAC
  // 0.00–0.03 = Sober; Yellow-Green
  // 0.03—0.06 = Tipsy; Yellow
  // 0.06-0.09 = Drunk; Orange
  // 0.10-0.12 = Very Drunk; Red
  List<DateTime> soberDates = [];
  List<DateTime> tipsyDates = [];
  List<DateTime> drunkDates = [];
  List<DateTime> veryDrunkDates = [];

  Future<List<database.Day>> _makeDayList() async {
    List<database.Day> dayList = List<database.Day>();

    Database db = await database.DatabaseHelper.instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM days');
    result.forEach((map) => dayList.add(database.Day.fromMap(map)));
    return dayList;
  }

  _sortDates() async {
    double max = mainPage.maxBAC;
    double threeQuartersMax = (3 * mainPage.maxBAC) / 4;
    double halfMax = mainPage.maxBAC / 2;
    double quarterMax = mainPage.maxBAC / 4;

    List<database.Day> dayList = await _makeDayList();

    for (int i = 0; i < dayList.length; i++)
      if (dayList[i].maxBAC > 0.00 && dayList[i].maxBAC < quarterMax)
        soberDates.add(stringToDateTime(dayList[i].getDate()));
      else if (dayList[i].maxBAC >= quarterMax && dayList[i].maxBAC < halfMax)
        tipsyDates.add(stringToDateTime(dayList[i].getDate()));
      else if (dayList[i].maxBAC >= halfMax &&
          dayList[i].maxBAC < threeQuartersMax)
        drunkDates.add(stringToDateTime(dayList[i].getDate()));
      else if (dayList[i].maxBAC >= threeQuartersMax &&
          dayList[i].maxBAC <= max)
        veryDrunkDates.add(stringToDateTime(dayList[i].getDate()));
  }

  @override
  Widget build(BuildContext context) {
    _sortDates();
    for (int i = 0; i < soberDates.length; i++) {
      _markedDateMap.add(
          soberDates[i],
          new Event(
              date: soberDates[i],
              icon: _soberIcon(soberDates[i].day.toString())));
    }

    for (int i = 0; i < tipsyDates.length; i++) {
      _markedDateMap.add(
          tipsyDates[i],
          new Event(
              date: tipsyDates[i],
              icon: _tipsyIcon(tipsyDates[i].day.toString())));
    }

    for (int i = 0; i < drunkDates.length; i++) {
      _markedDateMap.add(
          drunkDates[i],
          new Event(
              date: drunkDates[i],
              icon: _drunkIcon(drunkDates[i].day.toString())));
    }

    for (int i = 0; i < veryDrunkDates.length; i++) {
      _markedDateMap.add(
          veryDrunkDates[i],
          new Event(
              date: veryDrunkDates[i],
              icon: _veryDrunkIcon(veryDrunkDates[i].day.toString())));
    }

    return CalendarCarousel(
        selectedDateTime: _currentDate,
        selectedDayButtonColor: Color(0xFF97B633),
        selectedDayTextStyle: TextStyle(color: Colors.black),
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        daysHaveCircularBorder: null,
        weekendTextStyle: TextStyle(color: Colors.black),
        weekdayTextStyle: TextStyle(color: Colors.black),
        todayTextStyle: TextStyle(color: Colors.black),
        todayButtonColor: Color(0xFFC9D986),
        iconColor: Colors.black,
        headerTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.black,
        ),
        minSelectedDate: DateTime(2019, 8, 1), // TODO: make these infinite
        maxSelectedDate: DateTime(2022, 12, 31),
        markedDatesMap: _markedDateMap,
        markedDateShowIcon: true,
        markedDateIconMaxShown: 1,
        markedDateMoreShowTotal: null,
        markedDateIconBuilder: (event) {
          return event.icon;
        },
        onDayPressed: (DateTime date, List<Event> events) {
          this.setState(() => _currentDate =
              date); // changes the day that the calendar shows as selected
          determineDay(date).then((day) {
            widget.parentAction(day);
          });
        });
  }

  DateTime stringToDateTime(String date) {
    List<String> dateObjects = date.split("/");
    String month = dateObjects[0];
    String day = minutesStringToString(dateObjects[1]);
    String year = dateObjects[2];

    String dateStringToConvert = year + month + day;
    DateTime parsedDate = DateTime.parse(dateStringToConvert);

    return parsedDate;
  }
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => new _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  database.Day day = globals.today;
  double maxBACOnDay = 0;
  int waterOnDay = 0;
  List<String> times;
  List<String> types;

  _updateSelectedDay(database.Day day) {
    setState(() {
      this.day = day;
    });
  }

  String typeToImageName(int type) {
    String path =
        type == 1 ? 'assets/images/soloCup.png' : 'assets/images/waterDrop.png';
    return path;
  }

  int bacToPlant(double bac) {
    bac = bac >= 0.12 ? 0.12 : bac; // sets BAC equal to 0.12 if >= 0.12
    int plantNum = (5 * (bac / .12)).floor();
    plantNum = plantNum > 4 ? 4 : plantNum;
    return plantNum;
  }

  String dateToString(String date) {
    String monthName;

    List<String> dateObjects = date.split("/");
    String month = dateObjects[0];
    String day = dateObjects[1];
    String year = dateObjects[2];

    String dateStringToConvert = year + month + day;
    DateTime parsedDate = DateTime.parse(dateStringToConvert);

    int monthInt = parsedDate.month;
    if (monthInt == 1) {
      monthName = 'JANUARY';
    } else if (monthInt == 2) {
      monthName = 'FEBRUARY';
    } else if (monthInt == 3) {
      monthName = 'MARCH';
    } else if (monthInt == 4) {
      monthName = 'APRIL';
    } else if (monthInt == 5) {
      monthName = 'MAY';
    } else if (monthInt == 6) {
      monthName = 'JUNE';
    } else if (monthInt == 7) {
      monthName = 'JULY';
    } else if (monthInt == 8) {
      monthName = 'AUGUST';
    } else if (monthInt == 9) {
      monthName = 'SEPTEMBER';
    } else if (monthInt == 10) {
      monthName = 'OCTOBER';
    } else if (monthInt == 11) {
      monthName = 'NOVEMBER';
    } else if (monthInt == 12) {
      monthName = 'DECEMBER';
    }

    return '$monthName ${parsedDate.day}, ${parsedDate.year}';
  }

  Widget dataReturn() {
    if (day.typeList.length > 0) {
      return Container(
          padding: EdgeInsets.only(top: 10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                  Widget>[
            Column(children: <Widget>[
              Container(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width / 15),
                  child: Image.asset(
                    'assets/images/plants/drink${bacToPlant(day.getMaxBac())}water${day.getWaterAtMax()}.png',
                    width: MediaQuery.of(context).size.width / 3,
                  )),
              Text(day.getDate()),
            ]),
            SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 3,
                      maxWidth: MediaQuery.of(context).size.width / 4,
                    ),
                    child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          for (int i = 0; day.getHours().length > i; i++)
                            TableRow(children: [
                              TableCell(
                                  child: Text(day.getHours()[i].toString() +
                                      ':' +
                                      minutesIntToString(day.getMinutes()[i]))),
                              TableCell(
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Image.asset(
                                          typeToImageName(day.getTypes()[i]),
                                          height: 15)))
                            ])
                        ])))
          ]));
    } else {
      return Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
          child: Text(
            'No data for this day',
            style: TextStyle(color: Colors.grey[600]),
          ));
    }
  }

  Widget graphReturn() {}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Your Drinking History'),
          backgroundColor: Color(0xFF97B633),
        ),
        body: Container(
            // gives calendar space around it
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
            ),
            color: Color(0xFFF2F2F2),
            child: Column(children: [
              Container(
                  // white background
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 20,
                    right: MediaQuery.of(context).size.width / 20,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.white),
                  child: Calendar(
                    parentAction: _updateSelectedDay,
                  )),
              SizedBox(height: MediaQuery.of(context).size.height / 70),
              Container(
                width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/3,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.white),
                  child: Carousel(
                    images: [
                      Container(color: Colors.red), Container(color: Colors.yellow),
//                      dataReturn(), graphReturn()
                    ],
                    dotSize: 4.0,
                    dotSpacing: 15.0,
                    dotColor: Colors.blue,
                    dotIncreasedColor: Colors.black,
                    dotIncreaseSize: 0,
                    indicatorBgPadding: 5.0,
//                    dotBgColor: Colors.white,
//moveIndicatorFromBottom: 100,
//MediaQuery.of(context).size.height/3,
//                    borderRadius: true,
                  )),
//                  dataReturn()),
            ])));
  }
}

String minutesIntToString(int minutes) {
  String minuteString = minutes.toString();
  if (minuteString.length < 2) {
    minuteString = '0' + minutes.toString()[0];
  }
  return minuteString;
}

String minutesStringToString(String minutes) {
  String minuteString = minutes.toString();
  if (minuteString.length < 2) {
    minuteString = '0' + minutes.toString()[0];
  }
  return minuteString;
}
