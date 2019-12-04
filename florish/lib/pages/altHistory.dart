import 'package:flutter/material.dart';
import 'package:Florish/helpers/database_helpers.dart' as database;
import 'package:sqflite/sqflite.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Florish/globals.dart' as globals;
import 'package:Florish/homeScreen/homeScreenLayout.dart' as mainPage;

class AltHistoryPage extends StatefulWidget {
  @override
  _AltHistoryPageState createState() => new _AltHistoryPageState();
}

class _AltHistoryPageState extends State<AltHistoryPage> {
  List<Widget> widgetList = [];

  _AltHistoryPageState() {
    _updateWidgetList();
  }

  Future<List<database.Day>> _makeDayList() async {
    List<database.Day> dayList = List<database.Day>();

    Database db = await database.DatabaseHelper.instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM days');
    result.forEach((map) => dayList.add(database.Day.fromMap(map)));
    return dayList;
  }

  Widget makeWidget(database.Day day) {
    return Container(
        color: Colors.white,
        child:
//        BacChart()
            ExpansionTile(
                initiallyExpanded: false,
                backgroundColor: Colors.white,
                title: Container(
                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                    child: Row(children: <Widget>[
                      Container(
                          width: 80,
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                              'assets/images/plants/drink${mainPage.bacToPlant(day.getMaxBac())}water${day.getTotalWaters()}.png',
                              height: 50,
                              width: 50)),
                      Row(children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${getWeekday(day.getDate())}'),
//                                style:
//                                    TextStyle(fontSize: 16, color: Colors.black)),
                              Container(
//                                padding: EdgeInsets.only(bottom: 10),
                                  child: Text(dateToString(day.getDate()),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
//                                        color: Colors.black)
                                      )))
                            ]),
//                                Row(children: <Widget>[
//                                  Image.asset(
//                                    'assets/images/soloCup.png',
//                                    width: 20,
//                                  ),
//                                  Text(
//                                      '    ' +
//                                          day.getTotalDrinks().toString() +
//                                          '          ',
//                                      style: TextStyle(color: Colors.black)), //TODO: space this with flex
//                                  Image.asset(
//                                    'assets/images/waterDrop.png',
//                                    width: 20,
//                                  ),
//                                  Text('    ' + day.getTotalWaters().toString(),
//                                      style: TextStyle(color: Colors.black))
//                                ]),
                      ])
                    ])),
                children: <Widget>[
              Row(children: <Widget>[
                Image.asset(
                  'assets/images/soloCup.png',
                  width: 20,
                ),
                Text('    ' + day.getTotalDrinks().toString() + '          ',
                    style: TextStyle(
                        color: Colors.black)), //TODO: space this with flex
                Image.asset(
                  'assets/images/waterDrop.png',
                  width: 20,
                ),
                Text('    ' + day.getTotalWaters().toString(),
                    style: TextStyle(color: Colors.black))
              ]),
              Container(
                  width: 2 * MediaQuery.of(context).size.width / 3,
                  height: 100,
                  child: BacChart())
            ]));
  }

  _updateWidgetList() async {
    List<database.Day> dayList = await _makeDayList();
    dayList.forEach((day) => widgetList.add(makeWidget(day)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Your Drinking History'),
          backgroundColor: Color(0xFF97B633),
        ),
        backgroundColor: Color(0xFFF2F2F2),
        body: FutureBuilder(
//            <List<Widget>>(
            future: _updateWidgetList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widgetList)));
              } else if (snapshot.hasError) {
                return new Text("${snapshot.error}");
              }
              return new Container(
                alignment: AlignmentDirectional.center,
                child: new CircularProgressIndicator(),
              );
            }));
//        body:
  }

  String getWeekday(String date) {
    String weekday;

    List<String> dateObjects = date.split("/");
    String month = dateObjects[0];
    String day = dateObjects[1];
    String year = dateObjects[2];

    String dateStringToConvert = year + day + month;
    DateTime parsedDate = DateTime.parse(dateStringToConvert);

    int weekdayInt = parsedDate.weekday;
    if (weekdayInt == 1) {
      weekday = 'MONDAY';
    } else if (weekdayInt == 2) {
      weekday = 'TUESDAY';
    } else if (weekdayInt == 3) {
      weekday = 'WEDNESDAY';
    } else if (weekdayInt == 4) {
      weekday = 'THURSDAY';
    } else if (weekdayInt == 5) {
      weekday = 'FRIDAY';
    } else if (weekdayInt == 6) {
      weekday = 'SATURDAY';
    } else if (weekdayInt == 7) {
      weekday = 'SUNDAY';
    }

    return weekday;
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
      monthName = 'January';
    } else if (monthInt == 2) {
      monthName = 'February';
    } else if (monthInt == 3) {
      monthName = 'March';
    } else if (monthInt == 4) {
      monthName = 'April';
    } else if (monthInt == 5) {
      monthName = 'May';
    } else if (monthInt == 6) {
      monthName = 'June';
    } else if (monthInt == 7) {
      monthName = 'July';
    } else if (monthInt == 8) {
      monthName = 'August';
    } else if (monthInt == 9) {
      monthName = 'September';
    } else if (monthInt == 10) {
      monthName = 'October';
    } else if (monthInt == 11) {
      monthName = 'November';
    } else if (monthInt == 12) {
      monthName = 'December';
    }

    return '$monthName ${parsedDate.day}, ${parsedDate.year}';
  }
}

class BacChart extends StatelessWidget {
//  final List<charts.Series> seriesList;
//  final bool animate;

//  BacChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      _createBacData(),
      animate: false,
    );
  }

  static List<charts.Series<TimeSeriesBac, DateTime>> _createBacData() {
    final data = [
      new TimeSeriesBac(new DateTime(20191104), 0.02),
      new TimeSeriesBac(new DateTime(20191105), 0.09),
      new TimeSeriesBac(new DateTime(20191106), 0.04)
    ];
    return [
      new charts.Series<TimeSeriesBac, DateTime>(
        id: 'BAC',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesBac bac, _) => bac.time,
        measureFn: (TimeSeriesBac bac, _) => bac.bac,
        data: data,
      )
    ];
  }
}

class TimeSeriesBac {
  final DateTime time;
  final double bac;

  TimeSeriesBac(this.time, this.bac);
}