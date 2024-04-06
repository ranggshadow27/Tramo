// import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';

class HomeController extends GetxController {
  @override
  void onInit() async {
    monitoringList.value = await getMonitoringGroup();
    sensorsData.value = await getSensorsData();
    super.onInit();
  }

  TextEditingController monitoringGroupTC = TextEditingController();
  TextEditingController sensorsIdTC = TextEditingController();
  TextEditingController prtgIpTC = TextEditingController();

  RxList monitoringList = [].obs;

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

  Future<List<String>> getMonitoringGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('monitoringMenu') ?? [];
    debugPrint("Berhasil load data menunya nih coy : ${data.toString()}");

    return data;
  }

  void saveMonitoringGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = await getMonitoringGroup();
    bool isDuplicate = data.any((element) => element == monitoringGroupTC.text);

    if (monitoringGroupTC.text.isNotEmpty) {
      if (!isDuplicate) {
        monitoringList.add(monitoringGroupTC.text);
        data.add(monitoringGroupTC.text);
        String sensorValueKey =
            "sensorvalue_${monitoringGroupTC.text.removeAllWhitespace.toLowerCase()}";

        prefs.setString(sensorValueKey, "[]");
        prefs.setStringList('monitoringMenu', data);

        debugPrint("Berikut sensorvaluenya : $sensorValueKey");
        debugPrint("Berhasil menambahkan menu baru berikut isinya ${monitoringList.toString()}");
      } else {
        debugPrint("Hmm.. menu sudah ada");
      }
    } else {
      debugPrint("Diisi dulu lah breay");
    }
  }

  Future<Map<String, dynamic>> getSensorsData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    String? data = pref.getString('sensorData');

    Map<String, dynamic> dataList = {};

    if (data != null) {
      debugPrint("Ini datanya coy ${jsonDecode(data).toString()}");
      dataList = jsonDecode(data);
    }

    debugPrint("Ini data list nya : $dataList");

    return dataList;
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
    final SharedPreferences pref = await SharedPreferences.getInstance();

    if (sensorsIdTC.text.isNotEmpty) {
      try {
        debugPrint("Ini data sensor dari user : ${sensorsIdTC.text}");

        String menuTitle = monitoringList[index];
        debugPrint("Ini nama monitornya : $menuTitle");

        sensorsData.value = await getSensorsData();
        String key = "sensorvalue_${menuTitle.toLowerCase().removeAllWhitespace}";

        List sensorsValue = await getSensorsValue(key);
        debugPrint("Ini sensorvaluenya abis diget $key : $sensorsValue");

        // debugPrint("Ini data sensorDatanya : $sensorsData");

        sensorsValue.add({
          "sensorId": sensorsIdTC.text,
          "value": [],
          "time": [],
        });

        // debugPrint("Ini sensorvaluenya setelah ditambah : $sensorsValue");

        if (sensorsData[menuTitle] == null) {
          sensorsData.addAll(
            {
              menuTitle: {
                'Id': [int.parse(sensorsIdTC.text)],
                'prtgIp': [int.parse(prtgIpTC.text)],
              }
            },
          );

          debugPrint("membuat data baru");
        } else {
          sensorsData[menuTitle]['Id'].add(int.parse(sensorsIdTC.text));
          sensorsData[menuTitle]['prtgIp'].add(int.parse(prtgIpTC.text));
          debugPrint("menambahkan data baru");
        }

        pref.setString('sensorData', jsonEncode(sensorsData));
        pref.setString(key, jsonEncode(sensorsValue));

        update();
        Get.back();

        debugPrint("Sukses save ke prefs, isinya: \n - $sensorsData \n - $key : $sensorsValue");
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Tolong masukin sensor datanya dulu lah");
    }
  }
}
