import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tableDays = "days";
final String columnDay = "day";
final String columnHourList = 'hourlist';
final String columnMinuteList = 'minutelist';
final String columnTypeList = 'typelist';
final String columnConstantBACList = 'constantBACList';
final String columnMaxBAC = 'maxBAC';
final String columnMBWater = 'wateratmaxBAC';
final String columnDrinkCount = "totaldrinkcount";
final String columnWaterCount = "totalwatercount";
final String columnSession = "sessionlist";
final String columnHydratio = "hydratio";
final String columnYesterHydratio = "yesterhydratio";
final String columnLastBAC = "lastBAC";


class Day {
  String date;
  List<int> hourList;
  List<int> minuteList;
  List<int> typeList;
  List<int> constantBACList;
  double maxBAC;
  int waterAtMaxBAC;
  int totalDrinks;
  int totalWaters;
  List<int> sessionList;
  double hydratio;
  double yesterHydratio;
  double lastBAC;

  Day(
      {this.date,
        this.hourList,
        this.minuteList,
        this.typeList,
        this.constantBACList,
        this.maxBAC,
        this.waterAtMaxBAC,
        this.totalDrinks,
        this.totalWaters,
        this.hydratio,
        this.yesterHydratio,
        this.lastBAC});

  Day.fromMap(Map<String, dynamic> map) {
    date = map[columnDay];
    hourList = map[columnHourList];
    minuteList = map[columnMinuteList];
    typeList = map[columnTypeList];
    constantBACList = map[columnConstantBACList];
    maxBAC = map[columnMaxBAC];
    waterAtMaxBAC = map[columnMBWater];
    totalDrinks = map[columnDrinkCount];
    totalWaters = map[columnWaterCount];
    hydratio = map[columnHydratio];
    yesterHydratio = map[columnYesterHydratio];
    lastBAC = map[columnLastBAC];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDay: date,
      columnHourList: hourList,
      columnMinuteList: minuteList,
      columnTypeList: typeList,
      columnConstantBACList: constantBACList,
      columnMaxBAC: maxBAC,
      columnMBWater: waterAtMaxBAC,
      columnDrinkCount: totalDrinks,
      columnWaterCount: totalWaters,
      columnHydratio: hydratio,
      columnYesterHydratio: yesterHydratio,
      columnLastBAC: lastBAC,
    };

    return map;
  }

  @override
  String toString() {
    return 'Day {date: $date, hourList: $hourList, minuteList: $minuteList, typeList: $typeList, '
        'constantBACList: $constantBACList, maxBAC: $maxBAC, waterAtMaxBAC: $waterAtMaxBAC,'
        'totalDrinks: $totalDrinks, totalWaters: $totalWaters, '
        'todayhydratio: $hydratio, yesterhydratio: $yesterHydratio,'
        'lastBAC: $lastBAC}';
  }

  // NOTE: this many getters and setters CANNOT be efficient in a
  // database but this is how we're doing it right now.
  String getDate() {
    return this.date;
  }

  List getHours() {
    return this.hourList;
  }

  List getMinutes() {
    return this.minuteList;
  }

  List getTypes() {
    return this.typeList;
  }

  List getConstantBACs() {
    return this.constantBACList;
  }

  double getMaxBac() {
    return this.maxBAC;
  }

  int getWaterAtMax() {
    if (this.waterAtMaxBAC >= 5) {
      return 5;
    }return this.waterAtMaxBAC;
  }

  int getTotalDrinks() {
    return this.totalDrinks;
  }

  int getTotalWaters() {
    return this.totalWaters;
  }

  double getHydratio() {
    return this.hydratio;
  }

  double getYesterHydratio() {
    return this.yesterHydratio;
  }

  double getLastBAC() {
    return this.lastBAC;
  }

  void setDate(String date) {
    this.date = date;
  }

  void addHour(int hour) {
    this.hourList.add(hour);
  }

  void addMinute(int minute) {
    this.minuteList.add(minute);
  }

  void addType(int type) {
    this.typeList.add(type);
  }

  void addConstantBAC(int bac) {
    this.constantBACList.add(bac);
  }


  void setMaxBac(double mb) {
    this.maxBAC = mb;
  }

  void setWatersAtMaxBac(int wamb) {
    this.waterAtMaxBAC = wamb;
  }

  void setTotalDrinks(int drinks) {
    this.totalDrinks = drinks;
  }

  void setTotalWaters(int waters) {
    this.totalWaters = waters;
  }

  void setHydratio(double ratio) {
    this.hydratio = ratio;
  }

  void setYesterHydratio(double ratio) {
    this.yesterHydratio = ratio;
  }

}

class DatabaseHelper {

  static final _databaseName = "CalendarDatabase_3.db";
  static final _databaseVersion = 2;

  static final tableDays = "days";
  static final columnDay = "day";
  static final columnHourList = 'hourlist';
  static final columnMinuteList = 'minutelist';
  static final columnTypeList = 'typelist';
  static final columnConstantBACList = 'constantBACList';
  static final columnMaxBAC = 'maxBAC';
  static final columnMBWater = 'wateratmaxBAC';
  static final columnDrinkCount = "totaldrinkcount";
  static final columnWaterCount = "totalwatercount";
  static final columnHydratio = "hydratio";
  static final columnYesterHydratio = "yesterhydratio";
  static final columnLastBAC = "lastBAC";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableDays (
              $columnDay TEXT PRIMARY KEY,
                $columnHourList BLOB NOT NULL,
                $columnMinuteList BLOB NOT NULL,
                $columnTypeList BLOB NOT NULL,
                $columnConstantBACList BLOB NOT NULL,
                $columnMaxBAC REAL NOT NULL,
                $columnMBWater INTEGER NOT NULL,
                $columnDrinkCount INTEGER NOT NULL,
                $columnWaterCount INTEGER NOT NULL,
                $columnHydratio REAL NOT NULL,
                $columnYesterHydratio REAL NOT NULL,
                $columnLastBAC REAL NOT NULL
              )
              ''');
    await db.execute('CREATE TABLE inputTable (id INTEGER PRIMARY KEY, feet INTEGER, inch INTEGER, weight INTEGER, gender TEXT)');
  }

  saveInputInformation(inputTable) async {
    var connection = await database;
    await connection.delete('inputTable');
    return await connection.insert('inputTable', inputTable);
  }

  Future<void> insertDay(Day day) async {
    Database db = await database;
    await db.insert(tableDays, day.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDay(Day day) async {
    final db = await database;

    await db.update(tableDays, day.toMap(),
        where: "day = ?", whereArgs: [day.date]);
  }

  Future<void> deleteDay(String date) async {
    Database db = await instance.database;
    print("deleted?");
    return await db
        .delete(tableDays, where: '$columnDay = ?', whereArgs: [date]);
  }

  Future<void> resetDay(String date) async {
    Day newDay = Day(date: date, hourList: new List<int>(), minuteList: new List<int>(),
        typeList: new List<int>(), constantBACList: new List<int>(), maxBAC: 0.0, waterAtMaxBAC: 0, totalDrinks: 0,
        totalWaters: 0, hydratio: 0.0, yesterHydratio: 0.0,
        lastBAC: 0.0);
    updateDay(newDay);
  }

  Future<Day> getDay(String date) async {
    Database db = await instance.database;
    List result =
    await db.query(tableDays, where: '$columnDay = ?', whereArgs: [date]);
    return result.isNotEmpty ? Day.fromMap(result.first) : Null ;
  }

  getInputInformation() async {
    var _connection = await database;
    return await _connection.query('inputTable');
  }

}