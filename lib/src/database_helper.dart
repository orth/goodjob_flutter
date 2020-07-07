import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:goodjob/src/business.dart';
import 'package:goodjob/goodjob.dart';
import 'package:path/path.dart';
import 'package:quiver/cache.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Database _database;
  String keyName = "keyname";
  String languageValue = "language_value";
  String path;
  String tableName = '';
  static DatabaseHelper _databaseHelper;
  Map<String, MapCache<String, String>> map;

  static getInstance() {
    if (_databaseHelper == null) {
      _databaseHelper = new DatabaseHelper();
    }
    return _databaseHelper;
  }

  clearDB() {
    if (_database != null) {
      _database.close();
    }
  }

  ///数据库初始化
  Future init({id}) async {
    List<LanguageModel> list =
        await GoodJobBusiness().getGoodJobDataJson(id == null ? "10133" : id);
    if (_database == null || !_database.isOpen) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'demo.db');
      _database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
        //几种语言就建几个表
        list.forEach((v) async {
          String name = v.lang;
          tableName = name;
          debugPrint("tableName:" + tableName.toString());
          await db.execute('CREATE TABLE $name (id INTEGER PRIMARY KEY, name TEXT, value INTEGER)');
        });
      });
      map = new Map();
      list.forEach((v) {
        //循环插入所有数据
        v.listMap.forEach((f) {
          insertData(f, v.lang);
        });
        String name = v.lang;
        map[name] = v.mapCache;
      });
      print("mapCache:${map.length.toString()}");
    }

    if (tableName.isNotEmpty) {
      return 1;
    } else {
      return 0;
    }
  }

  //插入一条翻译
  Future insertData(Map<String, dynamic> map, String tableName) async {
    if (_database.isOpen) {
      await _database.transaction((txn) async {
        txn.insert(tableName, map);
      });
    } else {
      debugPrint("数据库未打开");
    }
  }

  Future queryAll() async {
    debugPrint("tableName:" + tableName);
    if (tableName.isNotEmpty) {
      List<Map<String, dynamic>> records = await _database.query(tableName);
// Update it in memory...this will throw an exception
//      mapRead['my_column'] = 1;
      return records.toString();
    }
  }

  //获取翻译文字
  Future queryValue(String nameKey) async {
    debugPrint("queryValue:$nameKey,$tableName");
    try {
      List<Map> maps = await _database.query(tableName,
          columns: ['name', 'value'], where: '"name" = ?', whereArgs: [nameKey]);
      debugPrint(tableName + '----' + maps.toString());
      return maps.first['value'];
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }

  Future queryCacheValue(String nameKey) async {
    MapCache<String, String> mapCache = new MapCache();
    try {
      mapCache = map[tableName];
      print("mapCache:" + mapCache.toString());
      var v = await mapCache.get(nameKey);
      print("mapCacheValue:" + v.toString());
      return v;
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }

//  Future getTodo(String key) async {
//    List<Map> maps = await _database.query(tableName,
//        columns: [columnId, columnDone, columnTitle], where: '$key = ?', whereArgs: [id]);
//    if (maps.length > 0) {
//      return Todo.fromMap(maps.first);
//    }
//    return null;
//  }
}
