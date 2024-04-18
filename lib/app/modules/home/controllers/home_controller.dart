// import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';

class HomeController extends GetxController {
  IdbFactory databaseFactory = getIdbFactory()!;
  Database? db;

  @override
  void onInit() async {
    super.onInit();
    await initDatabase();
    monitoringList.value = await getMonitoringGroup();
    sensorsData.value = await getSensorsData();
    isLoading.value = false;
  }

  TextEditingController monitoringGroupTC = TextEditingController();
  TextEditingController sensorsIdTC = TextEditingController();
  TextEditingController prtgIpTC = TextEditingController();

  RxList monitoringList = [].obs;

  RxBool isLoading = true.obs;
  RxBool isNavbarShrink = true.obs;
  RxBool isWideWindow = true.obs;
  RxInt activePage = 0.obs;

  // RxList sensorsData = [].obs;
  RxMap sensorsData = {}.obs;

  switchNavbarType() {
    isNavbarShrink.value = !isNavbarShrink.value;
  }

  switchPage(int indexPage) {
    activePage.value = indexPage;
    debugPrint("Saat ini masuk page dari menu ${monitoringList[indexPage]}");
    update();
  }

  autoColor(int index) {
    List monitoringColorList = [
      AccentColors.brownColor,
      AccentColors.greenColor,
      AccentColors.maroonColor,
      AccentColors.blueColor,
      AccentColors.purpleColor,
      AccentColors.pinkColor,
    ];

    for (var i = 0; i < monitoringList.length; i++) {
      int index = i % monitoringColorList.length;
      monitoringColorList.add(monitoringColorList[index]);
    }

    return monitoringColorList[index];
  }

  Future<void> initDatabase() async {
    const String dbName = 'tramoAppDatabase';
    const int dbVersion = 1;
    db = await databaseFactory.open(
      dbName,
      version: dbVersion,
      onUpgradeNeeded: (VersionChangeEvent event) {
        Database db = event.database;
        if (!db.objectStoreNames.contains('monitoringMenu')) {
          db.createObjectStore('monitoringMenu', autoIncrement: true);
        }
        if (!db.objectStoreNames.contains('sensorsData')) {
          db.createObjectStore('sensorsData', autoIncrement: true);
        }
        if (!db.objectStoreNames.contains('sensorsValue')) {
          db.createObjectStore('sensorsValue', autoIncrement: true);
        }
      },
    );
  }

  Future<List<dynamic>> getMonitoringGroup() async {
    var txn = db!.transaction('monitoringMenu', 'readonly');
    var store = txn.objectStore('monitoringMenu');
    var request = await store.getObject('monitoringMenuList');

    await txn.completed;

    return request != null ? List.from(request as List) : [];
  }

  void saveMonitoringGroup() async {
    List monitoringData = await getMonitoringGroup();
    bool isDuplicate = monitoringData.any((element) => element == monitoringGroupTC.text);

    if (monitoringGroupTC.text.isNotEmpty) {
      String sensorValueKey = "sv_${monitoringGroupTC.text.camelCase}";
      if (!isDuplicate) {
        monitoringData.add(monitoringGroupTC.text);

        var txn = db!.transaction('monitoringMenu', 'readwrite');
        var store = txn.objectStore('monitoringMenu');
        await store.put(monitoringData, 'monitoringMenuList');
        await txn.completed;

        var txnSv = db!.transaction('sensorsValue', 'readwrite');
        var storeSv = txnSv.objectStore('sensorsValue');
        await storeSv.put([], sensorValueKey);
        await txnSv.completed;

        monitoringList.add(monitoringGroupTC.text);
        Get.back();
        monitoringGroupTC.clear();

        debugPrint(
            "Berhasil menambahkan menu $sensorValueKey berikut isinya \n ->${monitoringList.toString()}");
      } else {
        debugPrint("Hmm.. menu sudah ada");
      }
    } else {
      debugPrint("Diisi dulu lah breay");
    }
  }

  Future<Map<String, dynamic>> getSensorsData({String? key}) async {
    Map<String, dynamic> sensors = {};
    Transaction txn = db!.transaction('sensorsData', 'readonly');
    ObjectStore store = txn.objectStore('sensorsData');

    var obj = await store.getObject('sensorsData');

    // var cursor = store.openCursor(autoAdvance: true).asBroadcastStream();

    // await for (var entry in cursor) {
    //   // sensorsData.addAll({entry.key.toString(): entry.value});
    //   debugPrint("Ini datanya --> ${entry.key} : ${entry.value}");
    // }

    await txn.completed;

    if (obj != null) {
      Map<String, dynamic> dataMap = (obj as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
      debugPrint("ini get sensorsData dari Objek yang udah dimap ges : \n -> $dataMap");
      sensors.addAll(dataMap);
    }

    if (sensorsData.isEmpty) {
      debugPrint("Sensors is Empty saddddddddddddd!");
    }

    if (key != null) {
      if (sensors[key] != null) {
        debugPrint("ini keynya : \n -> $key");
        debugPrint(
            "ini get sensorsData sesuai keynya : \n -> tipe : ${sensors[key].runtimeType} ${sensors[key]}");
        return Map<String, dynamic>.from(sensors[key]);
      } else {
        return Map<String, dynamic>.from({});
      }
    }

    debugPrint("Return semua sensors data -> $key");

    return sensors;
  }

  Future getSensorsValue(String key) async {
    List sensorsValueList = [];

    Transaction txn = db!.transaction('sensorsValue', 'readonly');
    ObjectStore store = txn.objectStore('sensorsValue');

    var obj = await store.getObject(key);

    await txn.completed;

    if (obj != null) {
      sensorsValueList.addAll(List.from(obj as List));
      debugPrint("Ini isi data Sensor Value $key : \n -> $sensorsValueList");

      return sensorsValueList;
    }

    debugPrint("Kayaknya data Sensor Valuenya kosong : \n -> $sensorsValueList");
    return sensorsValueList;
  }

  Future saveSensorsValue(String key) async {
    List sensorsValueList = await getSensorsValue(key);

    sensorsValueList.add({
      "sensorId": sensorsIdTC.text,
      "value": [],
      "time": [],
    });

    Transaction txn = db!.transaction('sensorsValue', 'readwrite');
    ObjectStore store = txn.objectStore('sensorsValue');

    await store.put(sensorsValueList, key);

    debugPrint("Sukses input data Sensor Valuenya ke objekstore $key : \n -> $sensorsValueList");

    await txn.completed;
  }

  Future saveSensorsData(int index) async {
    if (sensorsIdTC.text.isNotEmpty) {
      try {
        String menuTitle = monitoringList[index].toString().camelCase!;
        Map<String, dynamic> keyedSensorsData = {};

        debugPrint("Ini nama monitornya : $menuTitle");
        debugPrint("Ini data sensor dari user : ${sensorsIdTC.text}");

        keyedSensorsData = await getSensorsData(key: menuTitle);

        debugPrint("Ini data keyedsensorDatanya : \n -> $keyedSensorsData");

        if (keyedSensorsData.isEmpty) {
          keyedSensorsData.addAll({
            'Id': [int.parse(sensorsIdTC.text)],
            'prtgIp': [int.parse(prtgIpTC.text)],
          });

          debugPrint(
              "membuat data ke keyedSensorsData $menuTitle, output : \n -> $keyedSensorsData");
        } else {
          keyedSensorsData['Id'].add(int.parse(sensorsIdTC.text));
          keyedSensorsData['prtgIp'].add(int.parse(prtgIpTC.text));

          debugPrint("menambahkan data baru, output : $keyedSensorsData");
        }

        sensorsData.addAll({menuTitle: keyedSensorsData});
        debugPrint("menambahkan data ke master sensors data juga, output : $sensorsData");

        Transaction txn = db!.transaction('sensorsData', 'readwrite');
        ObjectStore store = txn.objectStore('sensorsData');

        await store.put(sensorsData, 'sensorsData');
        await txn.completed;

        await saveSensorsValue('sv_$menuTitle');

        Get.back();
        sensorsIdTC.clear();
        prtgIpTC.clear();

        update();

        debugPrint("Sukses save sensorsdata ke localStorage, isinya: \n - $sensorsData");
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Tolong masukin sensor datanya dulu lah");
    }
  }
}
