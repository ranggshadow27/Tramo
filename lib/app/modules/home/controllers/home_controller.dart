// import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:intl/intl.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';
import 'package:tramo/app/utils/utils.dart';

class HomeController extends GetxController {
  IdbFactory databaseFactory = getIdbFactory()!;
  Database? db;

  @override
  void onInit() async {
    super.onInit();
    await initDatabase();

    monitoringList.value = await getMonitoringGroup();
    sensorsData.value = await getSensorsData();

    isLoading = false;
    update();
  }

  TextEditingController monitoringGroupTC = TextEditingController();
  TextEditingController sensorsIdTC = TextEditingController();
  TextEditingController prtgIpTC = TextEditingController();

  RxList monitoringList = [].obs;

  RxBool isRefresh = true.obs;
  bool isLoading = true;
  RxBool isNavbarShrink = true.obs;
  RxBool isWideWindow = true.obs;
  RxInt activePage = 0.obs;
  RxString activeObjectName = "".obs;

  String? sensorKey;
  int? sensorIndex;

  // RxList sensorsData = [].obs;
  RxMap sensorsData = {}.obs;

  switchNavbarType() {
    isNavbarShrink.value = !isNavbarShrink.value;
  }

  switchPage(int indexPage) {
    activePage.value = indexPage;
    activeObjectName.value = "sv_${monitoringList[indexPage].toString().camelCase}";

    debugPrint(
        "Saat ini masuk page dari menu ${monitoringList[indexPage]} -- ${activeObjectName.value}");

    // isRefresh.value = true;
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

    debugPrint("Berikut monitoringMenunya :\n ${request.toString()}");

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
        update();
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

  Future getSensorsValue(String objectStore) async {
    List sensorsValueList = [];

    Transaction txn = db!.transaction('sensorsValue', 'readonly');
    ObjectStore store = txn.objectStore('sensorsValue');

    var obj = await store.getObject(objectStore);

    await txn.completed;

    if (obj != null) {
      sensorsValueList.addAll(List.from(obj as List));
      debugPrint("Ini isi data Sensor Value $objectStore : \n -> $sensorsValueList");

      return sensorsValueList;
    }

    debugPrint("Kayaknya data Sensor Valuenya kosong : \n -> $sensorsValueList");
    return sensorsValueList;
  }

  Future saveSensorValue(String objectName, int index, int value, String sensorName) async {
    List sensorsValueList = await getSensorsValue(objectName);

    DateTime now = DateTime.now();
    String timeValue = DateFormat.Hm().format(now);

    var senValLength = sensorsValueList[index]['time'] ?? [];

    debugPrint("ini lastest timeValue dari index ke $index -> ${senValLength.isEmpty}");

    if (senValLength.isEmpty || senValLength.last != timeValue) {
      Transaction txn = db!.transaction('sensorsValue', 'readwrite');
      ObjectStore store = txn.objectStore('sensorsValue');

      sensorsValueList[index]['value'].add(value);
      sensorsValueList[index].addAll({'name': sensorName});
      sensorsValueList[index]['time'].add(timeValue);

      await store.put(sensorsValueList, objectName);
      await txn.completed;

      debugPrint("Ini sensorsValueList setelah di Add-> \n${sensorsValueList[index]}");

      return sensorsValueList[index];
    } else {
      debugPrint("Time valuenya sama, gajadi ditambah");
    }
  }

  Future createSensorsStore(String key) async {
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

  Future<Map<String, dynamic>> getSensorsData({String? key}) async {
    Map<String, dynamic> sensors = {};
    Transaction txn = db!.transaction('sensorsData', 'readonly');
    ObjectStore store = txn.objectStore('sensorsData');

    var obj = await store.getObject('sensorsData');

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

        await createSensorsStore('sv_$menuTitle');

        Get.back();
        sensorsIdTC.clear();
        prtgIpTC.clear();

        isRefresh.value = true;

        update();

        debugPrint("Sukses save sensorsdata ke localStorage, isinya: \n - $sensorsData");
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Tolong masukin sensor datanya dulu lah");
    }
  }

  Future<dynamic> fetchApiData({
    required String key,
    required String objectName,
    required int index,
  }) async {
    List<dynamic> getCurrentSensorValue = await getSensorsValue(objectName);
    Map currentSensorValue = Map<String, dynamic>.from(getCurrentSensorValue[index]);

    debugPrint("Ini adalah currentSensorValue-> \n$currentSensorValue");

    if (isRefresh.isTrue) {
      var dio = Dio();
      var apiURL = "http://localhost:8080/backhaul/index.php?id=$key";

      try {
        final response = await dio.get(apiURL);
        if (response.statusCode == 200 && response.data != null) {
          Map<String, dynamic> responseData = Map<String, dynamic>.from(response.data);
          debugPrint('berikut datanya : \n-> ${responseData['sensordata']}');

          var apiValue = responseData['sensordata']['value'].toString().split(" ")[0];
          debugPrint("ini valuenyaa cuy : ${Utils.formatRawApiValue(apiValue)}");

          currentSensorValue['value'].add(Utils.formatRawApiValue(apiValue));

          await saveSensorValue(
            objectName,
            index,
            Utils.formatRawApiValue(apiValue),
            responseData['sensordata']['name'],
          );

          getCurrentSensorValue = await getSensorsValue(objectName);

          debugPrint(
              "Ini currentSensorValue setelah di Add Value Baru-> \n${getCurrentSensorValue[index]}");

          return Map<String, dynamic>.from(getCurrentSensorValue[index]);
        } else {
          return null;
        }
      } on DioException catch (e) {
        debugPrint("Terdapat Eror : ${e.message}");
      } finally {
        isRefresh.value = false;
      }
    } else {
      return currentSensorValue;
    }
  }
}
