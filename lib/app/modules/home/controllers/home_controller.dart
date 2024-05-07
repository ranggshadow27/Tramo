// import 'package:flutter/material.dart';

import 'dart:async';

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

    activePage.value = await getLastActivePage();

    monitoringList.value = await getMonitoringGroup();
    sensorsData.value = await getSensorsData();

    if (monitoringList.isNotEmpty) {
      switchPage(activePage.value);
    }

    sensorsValue = await getSensorsValue(activeObjectName.value);

    isLoading = false;
    update();
  }

  TextEditingController monitoringGroupTC = TextEditingController();
  TextEditingController sensorsIdTC = TextEditingController();
  TextEditingController prtgIpTC = TextEditingController();

  RxList monitoringList = [].obs;

  RxBool isRefresh = true.obs;
  bool isLoading = true;
  bool isTimerRunning = false;
  RxBool isNavbarShrink = true.obs;
  RxBool isWideWindow = true.obs;
  RxInt activePage = 0.obs;
  RxString activeObjectName = "".obs;

  String? sensorKey;
  int? sensorIndex;

  List sensorsValue = [];
  RxMap sensorsData = {}.obs;

  int totalDataFetched = 0;

  Timer? timer;

  switchNavbarType() {
    isNavbarShrink.value = !isNavbarShrink.value;
  }

  saveActivePage() async {
    await Utils.transaction(
      type: "save",
      db: db!,
      objectStore: 'lastPage',
      action: 'readwrite',
      data: activePage.value,
    );
  }

  getLastActivePage() async {
    var request = await Utils.transaction(
      type: "get",
      db: db!,
      objectStore: 'lastPage',
      action: 'readonly',
      data: activePage.value,
    );

    int lastPage = int.parse(request != null ? request.toString() : "0");

    debugPrint("LAST PAGENYA : $lastPage");

    return lastPage;
  }

  switchPage(int indexPage) async {
    // if (timer != null && timer!.isActive) {
    //   timer!.cancel();

    //   isTimerRunning = false;
    //   debugPrint("Timer sudah dikensel anjas");
    // }

    activePage.value = indexPage;

    saveActivePage();
    activeObjectName.value = "sv_${monitoringList[indexPage].toString().camelCase}";

    debugPrint(
        "Saat ini masuk page dari menu ${monitoringList[indexPage]} -- ${activeObjectName.value}");

    sensorsValue = await getSensorsValue(activeObjectName.value);

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
        if (!db.objectStoreNames.contains('lastPage')) {
          db.createObjectStore('lastPage', autoIncrement: true);
        }
      },
    );
  }

  Future<List<dynamic>> getMonitoringGroup() async {
    var request = await Utils.transaction(
      type: 'get',
      db: db!,
      objectStore: 'monitoringMenu',
      object: 'monitoringMenuList',
      action: 'readonly',
    );

    debugPrint("Berikut monitoringMenunya :\n ${request.toString()}");

    if (request == null) {
      return [];
    }

    return List.from(request as List);
  }

  void saveMonitoringGroup() async {
    List monitoringData = await getMonitoringGroup();
    bool isDuplicate = monitoringData.any((element) => element == monitoringGroupTC.text);

    if (monitoringGroupTC.text.isNotEmpty) {
      String sensorValueKey = "sv_${monitoringGroupTC.text.camelCase}";
      if (!isDuplicate) {
        monitoringData.add(monitoringGroupTC.text);

        await Utils.transaction(
          type: "save",
          db: db!,
          objectStore: 'monitoringMenu',
          action: 'readwrite',
          object: 'monitoringMenuList',
          data: monitoringData,
        );

        await Utils.transaction(
          type: "save",
          db: db!,
          objectStore: 'sensorsValue',
          action: 'readwrite',
          object: sensorValueKey,
          data: [],
        );

        monitoringList.add(monitoringGroupTC.text);

        if (monitoringList.length == 1) {
          activeObjectName.value = "sv_${monitoringList[0].toString().camelCase}";
        }

        update();
        Get.back();
        monitoringGroupTC.clear();

        debugPrint(
            "Berhasil menambahkan menu ${activeObjectName.value} berikut isinya \n ->${monitoringList.toString()}");
      } else {
        debugPrint("Hmm.. menu sudah ada");
      }
    } else {
      debugPrint("Diisi dulu lah breay");
    }
  }

  Future getSensorsValue(String objectStore) async {
    List sensorsValueList = [];

    if (objectStore == "" && monitoringList.isNotEmpty) {
      objectStore = "sv_${monitoringList[0].toString().camelCase}";
      debugPrint("Kayaknya data Sensor Valuenya $objectStore kosong 2 : \n -> $sensorsValue");
    }

    if (objectStore == "" && monitoringList.isEmpty) {
      debugPrint("Kayaknya data Sensor Valuenya $objectStore kosong 2 : \n -> $sensorsValue");

      return [];
    }

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
    List sensorsValueList = sensorsValue;

    DateTime now = DateTime.now();
    String timeValue = DateFormat.Hm().format(now);

    var senValLength = sensorsValueList[index]['time'] ?? [];

    debugPrint("ini lastest timeValue dari index ke $index -> ${senValLength.isEmpty}");

    if (senValLength.isEmpty || senValLength.last != timeValue) {
      Transaction txn = db!.transaction('sensorsValue', 'readwrite');
      ObjectStore store = txn.objectStore('sensorsValue');

      if (sensorsValueList.length >= 60) {
        sensorsValueList[index]['value'].removeAt(0);
        sensorsValueList[index]['time'].removeAt(0);
      }

      sensorsValueList[index]['value'].add(value);
      sensorsValueList[index].addAll({'name': sensorName});
      sensorsValueList[index]['time'].add(timeValue);

      await store.put(sensorsValueList, objectName);
      await txn.completed;

      debugPrint("Ini sensorsValueList setelah di Add-> \n${sensorsValueList[index]}");
      debugPrint("Ini sensorsValueList -> \n$sensorsValueList");
      sensorsValue = sensorsValueList;

      return sensorsValueList[index];
    } else {
      debugPrint("Time valuenya sama, gajadi ditambah");
    }
  }

  Future createSensorsStore(String key) async {
    List sensorsValueList = sensorsValue;

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
    Map currentSensorValue = Map<String, dynamic>.from(sensorsValue[index]);

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

          await saveSensorValue(
            objectName,
            index,
            Utils.formatRawApiValue(apiValue),
            responseData['sensordata']['name'],
          );

          debugPrint("Ini currentSensorValue setelah di Add Value Baru-> \n${sensorsValue[index]}");

          if (isTimerRunning == false) {
            timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
              isRefresh.value = true;
              update();
            });

            isTimerRunning = true;
          }

          return Map<String, dynamic>.from(sensorsValue[index]);
        } else {
          return null;
        }
      } on DioException catch (e) {
        debugPrint("Terdapat Eror : ${e.message}");
      } finally {
        totalDataFetched++;

        debugPrint("Data sudah terget ke $totalDataFetched");
        isRefresh.value = false;
      }
    } else {
      return currentSensorValue;
    }
  }
}
