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
    List<String> data = prefs.getStringList('tes') ?? [];
    debugPrint("Get datanya ni coy : ${data.toString()}");

    return data;
  }

  void saveMonitoringGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = await getMonitoringGroup();

    if (monitoringGroupTC.text.isNotEmpty) {
      monitoringList.add(monitoringGroupTC.text);
      data.add(monitoringGroupTC.text);
      debugPrint(monitoringList.toString());

      prefs.setStringList('tes', data);
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

  Future saveSensorsData(int index) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    if (sensorsIdTC.text.isNotEmpty) {
      try {
        debugPrint("Ini data sensor dari user : ${sensorsIdTC.text}");

        String menuTitle = monitoringList[index];
        debugPrint("Ini nama monitornya : $monitoringList");

        sensorsData.value = await getSensorsData();
        debugPrint("Ini data sensorDatanya : $sensorsData");

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
        update();
        Get.back();

        debugPrint("Sukses save ke prefs, isinya $sensorsData");
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Tolong masukin sensor datanya dulu lah");
    }
  }
}
