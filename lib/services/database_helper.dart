import 'dart:io';
import 'package:crypto_profit_loss_calculator/model/pnl.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// TODO: database clear ozellıgı eklenmelı

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper.internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }
  DatabaseHelper.internal();
  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database!;
    } else {
      return _database!;
    }
  }

  Future<Database> _initializeDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "database.db");
    bool exists = await databaseExists(path);
    if (!exists) {
      print("Assetden yeni bir kopya oluşturuluyor");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
      ByteData data = await rootBundle.load(join("assets", "database.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("olan db acılıyor");
    }
    return await openDatabase(path, readOnly: false);
  }

  // String dateFormat(DateTime dt) {
  //   String month;
  //   switch (dt.month) {
  //     case 1:
  //       month = "Ocak";
  //       break;
  //     case 2:
  //       month = "Şubat";
  //       break;
  //     case 3:
  //       month = "Mart";
  //       break;
  //     case 4:
  //       month = "Nisan";
  //       break;
  //     case 5:
  //       month = "Mayıs";
  //       break;
  //     case 6:
  //       month = "Haziran";
  //       break;
  //     case 7:
  //       month = "Temmuz";
  //       break;
  //     case 8:
  //       month = "Ağustos";
  //       break;
  //     case 9:
  //       month = "Eylül";
  //       break;
  //     case 10:
  //       month = "Ekim";
  //       break;
  //     case 11:
  //       month = "Kasım";
  //       break;
  //     case 12:
  //       month = "Aralık";
  //       break;
  //   }
  //   return month + " " + dt.day.toString() + ", " + dt.year.toString();
  // }

  Future<int> addPnl(CoinPnL coinPnl) async {
    Database db = await _getDatabase();
    return await db.insert("Pnl", coinPnl.toMap());
  }

  Future<int> deletePnl(int id) async {
    Database db = await _getDatabase();
    return await db.delete("Pnl", where: "id = ? ", whereArgs: [id]);
  }

  Future<List<CoinPnL>> getCoinPnLList() async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> coinPnLMapList =
        await db.rawQuery("Select * From Pnl ;");
    List<CoinPnL> coinPnLList = [];
    for (Map map in coinPnLMapList) {
      // print("db içi print ${map["date"]}");
      coinPnLList.add(CoinPnL.fromMap(map));
    }
    return coinPnLList;
  }

  Future<CoinPnL> getCoinPnLbyId(int id) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> coinPnLMapList =
        await db.rawQuery("Select * From Pnl Where id == $id;");

    return CoinPnL.fromMap(coinPnLMapList[0]);
  }

  Future updateCoinPnL(CoinPnL coinPnL) async {
    Database db = await _getDatabase();
    print(coinPnL.toMap());

    return await db
        .update("Pnl", coinPnL.toMap(), where: "id=?", whereArgs: [coinPnL.id]);
  }

  Future<int> lenghtAllCoinPnL() async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> sonuc =
        await db.rawQuery("Select Count() From Pnl ;");
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    return sonuc[0]["Count()"];
  }
}
