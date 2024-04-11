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
    List data = await getMonitoringGroup();
    bool isDuplicate = data.any((element) => element == monitoringGroupTC.text);

    if (monitoringGroupTC.text.isNotEmpty) {
      if (!isDuplicate) {
        data.add(monitoringGroupTC.text);
        // String sensorValueKey =
        //     "sensorvalue_${monitoringGroupTC.text.removeAllWhitespace.toLowerCase()}";

        var txn = db!.transaction('monitoringMenu', 'readwrite');
        var store = txn.objectStore('monitoringMenu');
        await store.put(data, 'monitoringMenuList');
        // await store.put([], sensorValueKey);

        await txn.completed;

        monitoringList.add(monitoringGroupTC.text);
        Get.back();
        monitoringGroupTC.clear();

        // debugPrint("Berikut sensorvaluenya : $sensorValueKey");
        debugPrint("Berhasil menambahkan menu baru berikut isinya ${monitoringList.toString()}");
      } else {
        debugPrint("Hmm.. menu sudah ada");
      }
    } else {
      debugPrint("Diisi dulu lah breay");
    }
  }

  Future<Map<String, dynamic>> getSensorsData() async {
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
      debugPrint("ini get sensorsData dari Objek yang udah dimap ges : \n $dataMap");
      sensors.addAll(dataMap);
    }

    if (sensorsData.isEmpty) {
      debugPrint("Sensors is Empty saddddddddddddd!");
    } else {
      debugPrint("Ini datanya coy ${sensorsData.toString()}");
    }

    return sensors;
  }

  Future getSensorsValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? data = pref.getString(key);

    if (data != null) {
      return jsonDecode(data);
    }

    return ["Kosong"];
  }

  Future saveSensorsData(int index) async {
    // final SharedPreferences pref = await SharedPreferences.getInstance();

    if (sensorsIdTC.text.isNotEmpty) {
      try {
        debugPrint("Ini data sensor dari user : ${sensorsIdTC.text}");

        String menuTitle = monitoringList[index].toString().camelCase!;
        debugPrint("Ini nama monitornya : $menuTitle");

        sensorsData.value = await getSensorsData();
        debugPrint("Ini data sensorDatanya : $sensorsData");

        // String key = "sensorvalue_${menuTitle.toLowerCase().removeAllWhitespace}";

        // List sensorsValue = await getSensorsValue(key);
        // debugPrint("Ini sensorvaluenya abis diget $key : $sensorsValue");

        // sensorsValue.add({
        //   "sensorId": sensorsIdTC.text,
        //   "value": [],
        //   "time": [],
        // });

        // debugPrint("Ini sensorvaluenya setelah ditambah : $sensorsValue");

        Transaction txn = db!.transaction('sensorsData', 'readwrite');
        ObjectStore store = txn.objectStore('sensorsData');

        if (sensorsData[menuTitle] == null) {
          sensorsData.addAll(
            {
              menuTitle: {
                'Id': [int.parse(sensorsIdTC.text)],
                'prtgIp': [int.parse(prtgIpTC.text)],
              }
            },
          );

          debugPrint("membuat data baru, output : $sensorsData");
        } else {
          sensorsData[menuTitle]['Id'].add(int.parse(sensorsIdTC.text));
          sensorsData[menuTitle]['prtgIp'].add(int.parse(prtgIpTC.text));

          debugPrint("menambahkan data baru, output : $sensorsData");
        }

        await store.put(sensorsData, 'sensorsData');

        // pref.setString('sensorData', jsonEncode(sensorsData));
        // pref.setString(key, jsonEncode(sensorsValue));

        Get.back();

        sensorsIdTC.clear();
        prtgIpTC.clear();

        update();

        debugPrint("Sukses save ke localStorage, isinya: \n - $sensorsData");
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Tolong masukin sensor datanya dulu lah");
    }
  }
}
