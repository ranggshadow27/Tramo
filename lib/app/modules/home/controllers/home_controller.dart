import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:intl/intl.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';
import 'package:tramo/app/constants/themes/font_style.dart';
import 'package:tramo/app/utils/utils.dart';
import 'package:tramo/app/widgets/error_notification.dart';
import 'package:tramo/app/widgets/info_notification.dart';

import 'dart:html' as html;

class HomeController extends GetxController {
  IdbFactory databaseFactory = getIdbFactory()!;
  Database? db;

  @override
  void onInit() async {
    super.onInit();
    await initDatabase();

    activePage.value = await getLastActivePage();

    dropdownData = await getMonitoringGroup();
    monitoringList.value = dropdownData;

    sensorsData.value = await getSensorsData();

    apiServerTC.text = await getApiEndPoint();

    if (monitoringList.isNotEmpty) {
      switchPage(activePage.value);
      isLoading = false;
    }

    sensorsValue = await getSensorsValue(activeObjectName.value);

    isLoading = false;
    update();
  }

  TextEditingController monitoringGroupTC = TextEditingController();
  TextEditingController sensorsIdTC = TextEditingController();
  TextEditingController prtgIpTC = TextEditingController();
  TextEditingController apiServerTC = TextEditingController();
  TextEditingController renameGroupTC = TextEditingController();

  final audioplayer = AudioPlayer();

  RxList monitoringList = [].obs;

  bool isLoading = true;
  bool isTimerRunning = false;
  bool isNotificationPlay = false;

  RxBool isRefresh = true.obs;
  RxBool isNavbarShrink = true.obs;
  RxBool isWideWindow = true.obs;
  RxBool saveApiURL = false.obs;
  RxBool updateGroupSuccess = false.obs;

  RxInt activePage = 0.obs;
  RxString activeObjectName = "".obs;
  RxString errNameObs = "".obs;
  RxString groupNameObs = "".obs;

  String? selectedGroupName;
  String? sensorKey;
  int? sensorIndex;

  List dropdownData = [];
  List sensorsValue = [];
  RxMap sensorsData = {}.obs;

  int totalDataFetched = 0;

  Timer? timer;

  switchNavbarType() {
    isNavbarShrink.value = !isNavbarShrink.value;
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
        if (!db.objectStoreNames.contains('apiEndPoint')) {
          db.createObjectStore('apiEndPoint', autoIncrement: true);
        }
      },
    );
  }

  saveApiEndPoint() async {
    try {
      await Utils.transaction(
        type: "save",
        db: db!,
        objectStore: 'apiEndPoint',
        action: 'readwrite',
        data: apiServerTC.text,
      );

      debugPrint("API Server URL telah diupdate ke ${apiServerTC.text}");
    } catch (e) {
      debugPrint("Eror mengganti Api Server ke ${apiServerTC.text}");
    } finally {
      saveApiURL.value = true;
      isRefresh.value = true;

      update();
    }
  }

  Future<String> getApiEndPoint() async {
    var request = await Utils.transaction(
      type: "get",
      db: db!,
      objectStore: 'apiEndPoint',
      action: 'readonly',
    );

    debugPrint("Berikut datanya oyyyyyy : ${request.toString()}");

    return request ?? "localhost:8080";
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
    );

    int lastPage = int.parse(request != null ? request.toString() : "0");

    debugPrint("LAST PAGENYA : $lastPage");

    return lastPage;
  }

  switchPage(int indexPage) async {
    isRefresh.value = true;

    activePage.value = indexPage;

    saveActivePage();
    activeObjectName.value = "sv_${monitoringList[indexPage].toString().camelCase}";

    debugPrint(
        "Saat ini masuk page dari menu ${monitoringList[indexPage]} -- ${activeObjectName.value}");

    sensorsValue = await getSensorsValue(activeObjectName.value);

    debugPrint("Berikut data dari menu ${activeObjectName.value}\n $sensorsValue");

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
        groupNameObs.value = "Group name is already exist.";
        update();

        debugPrint("Hmm.. menu sudah ada");
      }
    } else {
      groupNameObs.value = "Group name cannot be empty.";

      debugPrint("Diisi dulu lah breay");
    }
  }

  deleteMonitoringGroup() async {
    List groupData = monitoringList;

    try {
      if (selectedGroupName != null || selectedGroupName != "") {
        String sensorValueKey = selectedGroupName!.camelCase!;

        int groupIndex = groupData.indexOf(selectedGroupName);

        groupData.removeAt(groupIndex);
        sensorsData.removeWhere((key, value) => key == sensorValueKey);

        await Utils.transaction(
          type: "save",
          db: db!,
          objectStore: 'monitoringMenu',
          action: 'readwrite',
          object: 'monitoringMenuList',
          data: groupData,
        );

        await Utils.transaction(
          type: "save",
          db: db!,
          objectStore: 'sensorsData',
          action: 'readwrite',
          object: 'sensorsData',
          data: sensorsData,
        );

        await Utils.transaction(
          type: "delete",
          db: db!,
          objectStore: 'sensorsValue',
          action: 'readwrite',
          object: "sv_$sensorValueKey",
        );

        switchPage(groupIndex > 0 ? groupIndex - 1 : 0);

        debugPrint("Sukses menghapus grup nya ");
      }
    } catch (e) {
      debugPrint("Gagal menghapus grup nya euy, $e");
    } finally {
      isRefresh.value = true;

      Get.back();

      update();
    }
  }

  updateMonitoringGroup() async {
    List groupData = monitoringList;
    Map newSensorData = {};

    List newSensorValue = [];

    try {
      if (renameGroupTC.text.isNotEmpty && renameGroupTC.text != selectedGroupName) {
        int groupIndex = groupData.indexOf(selectedGroupName);

        debugPrint(
            "Update Group\n1. Ini datanya cuy --->\n${groupData[groupIndex]} diganti ke ${renameGroupTC.text}");

        groupData[groupIndex] = renameGroupTC.text;

        await Utils.transaction(
          type: "save",
          db: db!,
          objectStore: 'monitoringMenu',
          action: 'readwrite',
          object: 'monitoringMenuList',
          data: groupData,
        );

        debugPrint("2. Ini groupDatanya cuy --->\n$groupData");

        String oldGroupName = selectedGroupName.toString().camelCase!;
        String newGroupName = renameGroupTC.text.toString().camelCase!;

        debugPrint("3. Ini old&newnya cuy --->\nold: $oldGroupName new: $newGroupName");

        for (var key in sensorsData.keys) {
          if (key == oldGroupName) {
            newSensorData[newGroupName] = sensorsData[oldGroupName];
          } else {
            newSensorData[key] = sensorsData[key];
          }
        }

        await Utils.transaction(
          type: "save",
          db: db!,
          objectStore: 'sensorsData',
          action: 'readwrite',
          object: 'sensorsData',
          data: newSensorData,
        );

        sensorsData.value = newSensorData;

        debugPrint("5. Ini newSensorDatanya cuy --->\n$newSensorData");

        newSensorValue = await getSensorsValue("sv_$oldGroupName");

        await Utils.transaction(
          type: "delete",
          db: db!,
          objectStore: 'sensorsValue',
          action: 'readwrite',
          object: "sv_$oldGroupName",
        );

        await Utils.transaction(
          type: "save",
          db: db!,
          objectStore: 'sensorsValue',
          action: 'readwrite',
          object: "sv_$newGroupName",
          data: newSensorValue,
        );

        sensorsValue = newSensorValue;

        debugPrint(
            "5. Ini newSensorValuenya cuy --->\n$newSensorValue\nsave di : ${"sv_$newGroupName"} ");

        debugPrint("6. Proses Update Selesai");

        switchPage(groupIndex);

        Get.back();
        Get.back();
      } else if (renameGroupTC.text.isEmpty) {
        errNameObs.value = "New name cannot be Empty!";
      } else {
        errNameObs.value = "Please rename with other name";
      }
    } catch (e) {
      debugPrint("Gagal update group Err: $e");
    } finally {
      update();
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

  Future saveSensorValue(
    String objectName,
    int index,
    int value,
    String sensorName,
  ) async {
    List sensorsValueList = sensorsValue;

    DateTime now = DateTime.now();
    String timeValue = DateFormat.Hm().format(now);

    var senValLength = sensorsValueList[index]['time'] ?? [];

    debugPrint("ini lastest timeValue dari index ke $index -> ${senValLength.isEmpty}");

    if (senValLength.isEmpty || senValLength.last != timeValue) {
      Transaction txn = db!.transaction('sensorsValue', 'readwrite');
      ObjectStore store = txn.objectStore('sensorsValue');

      int maxValue = 60;
      int countMaxLength = sensorsValueList[index]['value'].length - maxValue;

      if (sensorsValueList[index]['value'].length > maxValue) {
        sensorsValueList[index]['value'].removeRange(0, countMaxLength);
        sensorsValueList[index]['time'].removeRange(0, countMaxLength);
      }

      if (sensorsValueList[index]['value'].length == maxValue) {
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

      return sensorsValue[index];
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
    if (sensorsIdTC.text.isNotEmpty && prtgIpTC.text.isNotEmpty) {
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
            'alert': [true],
          });

          debugPrint(
              "membuat data ke keyedSensorsData $menuTitle, output : \n -> $keyedSensorsData");
        } else {
          keyedSensorsData['Id'].add(int.parse(sensorsIdTC.text));
          keyedSensorsData['prtgIp'].add(int.parse(prtgIpTC.text));
          keyedSensorsData['alert'].add(true);

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
    }

    if (sensorsIdTC.text.isEmpty || sensorsIdTC.text == "") {
      groupNameObs.value = "Sensor ID cannot be Empty";
    }
    if (prtgIpTC.text.isEmpty || prtgIpTC.text == "") {
      errNameObs.value = "PRTG IP cannot be Empty";
    }
  }

  Future<dynamic> fetchApiData({
    required String key,
    required String objectName,
    required int index,
    required BuildContext context,
  }) async {
    Map currentSensorValue = Map<String, dynamic>.from(sensorsValue[index]);

    if (isRefresh.isTrue) {
      var dio = Dio();

      var apiEndpoint = await getApiEndPoint();
      var apiURL = "http://$apiEndpoint/backhaul/index.php?id=$key";

      if (apiEndpoint == "localhost:8080") {
        apiURL = "http://localhost:8080/backhaul/index.php?id=$key";
      }

      debugPrint("BERIKUT API URLNYA -> $apiURL ~~~~~~~~~~~");

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
            timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
              isRefresh.value = true;
              debugPrint("IS NOTIFICATION IS ACTIVE? ---------------");
              await notificationAlert(context);

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
        return null;
      } finally {
        totalDataFetched++;

        debugPrint("Data sudah terget ke $totalDataFetched");
        isRefresh.value = false;
      }
    } else {
      return currentSensorValue;
    }
  }

  updateSensor(int index) async {
    String menuTitle = monitoringList[activePage.value].toString().camelCase!;

    if (sensorsIdTC.text.isNotEmpty && prtgIpTC.text.isNotEmpty) {
      Map<String, dynamic> keyedSensorsData = await getSensorsData(key: menuTitle);

      keyedSensorsData['Id'][index] = (int.parse(sensorsIdTC.text));
      keyedSensorsData['prtgIp'][index] = (int.parse(prtgIpTC.text));

      sensorsData.addAll({menuTitle: keyedSensorsData});

      isRefresh.value = true;

      await Utils.transaction(
        type: "save",
        db: db!,
        objectStore: "sensorsData",
        action: 'readwrite',
        data: sensorsData,
      );

      sensorsValue[index]['sensorId'] = (int.parse(sensorsIdTC.text));
      sensorsValue[index]['name'] = "Updating sensor from server, Pls wait..";
      sensorsValue[index]['value'] = [];
      sensorsValue[index]['time'] = [];

      await Utils.transaction(
        type: "save",
        db: db!,
        objectStore: "sensorsValue",
        action: 'readwrite',
        data: sensorsValue,
        object: activeObjectName.value,
      );
    }

    if (sensorsIdTC.text.isEmpty || sensorsIdTC.text == "") {
      groupNameObs.value = "Sensor ID cannot be Empty";

      return;
    }
    if (prtgIpTC.text.isEmpty || prtgIpTC.text == "") {
      errNameObs.value = "PRTG IP cannot be Empty";

      return;
    }

    sensorsIdTC.clear();
    prtgIpTC.clear();
    Get.back();

    update();
  }

  deleteSensor(int index) async {
    String menuTitle = monitoringList[activePage.value].toString().camelCase!;

    sensorsValue.removeRange(index, index + 1);
    sensorsData[menuTitle]['Id'].removeRange(index, index + 1);
    sensorsData[menuTitle]['prtgIp'].removeRange(index, index + 1);

    isRefresh.value = true;

    await Utils.transaction(
      type: "save",
      db: db!,
      objectStore: "sensorsData",
      action: 'readwrite',
      data: sensorsData,
    );

    await Utils.transaction(
      type: "save",
      db: db!,
      objectStore: "sensorsValue",
      action: 'readwrite',
      data: sensorsValue,
      object: activeObjectName.value,
    );

    update();
  }

  disableAlert(int index) async {
    String menuTitle = monitoringList[activePage.value].toString().camelCase!;
    bool isAlertEnable = sensorsData[menuTitle]['alert'][index];
    debugPrint("-----------> Alert Sensor ${sensorsValue[index]['name']} Before $isAlertEnable");

    isAlertEnable = !isAlertEnable;
    isRefresh.value = true;

    sensorsData[menuTitle]['alert'][index] = isAlertEnable;

    await Utils.transaction(
      type: "save",
      db: db!,
      objectStore: "sensorsData",
      action: 'readwrite',
      data: sensorsData,
    );

    debugPrint("-----------> Alert Sensor ${sensorsValue[index]['name']} After $isAlertEnable");

    Get.back();

    update();
  }

  notificationAlert(BuildContext context) async {
    // await audioplayer.setPlayerMode(PlayerMode.lowLatency);
    String menuTitle = monitoringList[activePage.value].toString().camelCase!;

    debugPrint("----------------------> Thresold Logic");

    for (var i = 0; i < sensorsValue.length; i++) {
      int currentData = sensorsValue[i]["value"].last;
      String sensorName = sensorsValue[i]["name"];

      bool isAlertEnable = sensorsData[menuTitle]['alert'][i];

      List reversedData = List.from(sensorsValue[i]["value"].reversed);
      List lastestData = [];

      if (reversedData.length >= 10) {
        lastestData = reversedData.sublist(0, 10);
      } else {
        lastestData = reversedData.sublist(0, reversedData.length);
      }

      debugPrint("----------------------> Latest Data :\n$lastestData");

      // double maxlastestData = lastestData.fold(0, (prev, element) => prev + element);

      double maxlastestData = lastestData.fold(
          0, (previousValue, element) => previousValue > element ? previousValue : element);

      double avgData = maxlastestData;

      // int maxVal = sensorsValue.reduce((prev, element) => null);

      double thresoldMajor = avgData * 0.3;
      double thresoldMinor = avgData * 0.7;

      debugPrint("jumlah lastestData data ke $i = ${lastestData.length}");
      debugPrint("avgData ke $i = $avgData");
      debugPrint("currentData ke $i = $currentData");

      debugPrint("thresoldMinor data ke $i = $thresoldMinor");
      debugPrint("thresoldMajor data ke $i = $thresoldMajor");

      if (isNotificationPlay == false && isAlertEnable == true) {
        if (currentData <= thresoldMajor || currentData < 10) {
          debugPrint("----------------------> Playing Major Alarm");
          showErrorNotification(
              context: context, description: "$sensorName is low Traffic", type: "major");

          await audioplayer.play(DeviceFileSource('/assets/sounds/major_alarm.wav'), volume: .8);
        }

        if (currentData <= thresoldMinor && currentData >= thresoldMajor) {
          debugPrint("----------------------> Playing Minor Alarm");
          showErrorNotification(
              context: context, description: "$sensorName is low Traffic", type: "minor");

          await audioplayer.play(DeviceFileSource('/assets/sounds/minor_alarm.wav'), volume: .5);
        }
      }
    }

    isNotificationPlay = false;
  }

  playSound() {
    debugPrint("----------------------> Playing Minor Alarm");

    audioplayer.play(DeviceFileSource('/assets/sounds/minor_alarm.wav'), volume: .5);
  }

  exportProfile() async {
    Map<String, dynamic> myJson = {
      "groups": monitoringList,
      "sensorsData": sensorsData,
    };

    String jsonString = jsonEncode(myJson);

    // debugPrint("Ini JSON Stringnya cuy \n $jsonString");

    final blob = html.Blob([jsonString]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "tramoProfile_backup.json")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  importProfile() async {
    final input = html.FileUploadInputElement()..accept = '.json';

    input.onChange.listen((event) async {
      final files = input.files;

      if (files != null && files.isNotEmpty) {
        final file = files.first;

        final reader = html.FileReader();
        reader.readAsText(file);

        reader.onLoadEnd.listen((event) async {
          final jsonString = reader.result as String;

          Map importedJson = jsonDecode(jsonString);

          monitoringList.value = importedJson['groups'];

          Map<String, dynamic> newSensorsData =
              Map<String, dynamic>.from(importedJson['sensorsData']);

          // debugPrint("1. Berikut importedJsonnya :\n$importedJson");
          // debugPrint("2. Berikut newSensorsData :\n$newSensorsData");

          sensorsData.value = newSensorsData;

          for (var i = 0; i < monitoringList.length; i++) {
            String objectStore = monitoringList[i].toString().camelCase!;

            List sensorsValueList = [];

            // debugPrint("3. $objectStore ");

            if (newSensorsData[objectStore] != null) {
              // debugPrint("4. $sensorsValueList ");

              for (var i = 0; i < newSensorsData[objectStore]["Id"].length; i++) {
                sensorsValueList.add({
                  "sensorId": newSensorsData[objectStore]["Id"][i],
                  "value": [],
                  "time": [],
                });
              }
              // debugPrint("5. $sensorsValueList ");
            }

            await Utils.transaction(
              type: "save",
              db: db!,
              objectStore: 'sensorsValue',
              action: 'readwrite',
              object: 'sv_$objectStore',
              data: sensorsValueList,
            );

            sensorsValue = sensorsValueList;
          }

          // debugPrint("6. $sensorsValue ");

          isRefresh.value = true;

          await Utils.transaction(
            type: "save",
            db: db!,
            objectStore: 'monitoringMenu',
            action: 'readwrite',
            object: 'monitoringMenuList',
            data: monitoringList,
          );

          await Utils.transaction(
            type: "save",
            db: db!,
            objectStore: 'sensorsData',
            action: 'readwrite',
            object: 'sensorsData',
            data: newSensorsData,
          );
          update();

          // debugPrint("2. Berikut newSensorsData :\n$sensorsData");

          Get.back();
        });
      } else {
        debugPrint("File yg di Import Tidak ada CUY!");
      }
    });

    html.document.body!.children.add(input);
    input.click();
    input.remove();
  }
}
