// import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';

class HomeController extends GetxController {
  @override
  void onInit() async {
    monitoringList.value = await getMonitoringGroup();
    super.onInit();
  }

  TextEditingController monitoringGroupTC = TextEditingController();
  RxBool isNavbarShrink = true.obs;
  RxList monitoringList = [].obs;

  RxInt activePage = 0.obs;

  switchNavbarType() {
    isNavbarShrink.value = !isNavbarShrink.value;
  }

  switchPage(int indexPage) {
    activePage.value = indexPage;
    debugPrint("Saat ini masuk page dari menu ${monitoringList[indexPage]}");
  }

  Future<List<String>> getMonitoringGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('tes') ?? [];
    debugPrint("Get datanya ni coy : ${data.toString()}");

    return data;
  }

  autoColor(int index) {
    List monitoringColorList = [
      AccentColors.brownColor,
      AccentColors.greenColor,
      AccentColors.maroonColor,
      AccentColors.purpleColor,
    ];

    for (var i = 0; i < monitoringList.length; i++) {
      int index = i % monitoringColorList.length;
      monitoringColorList.add(monitoringColorList[index]);
    }

    return monitoringColorList[index];
  }

  void saveMonitoringGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> data = await getMonitoringGroup();
    monitoringList.add(monitoringGroupTC.text);
    data.add(monitoringGroupTC.text);
    debugPrint(monitoringList.toString());

    prefs.setStringList('tes', data);
  }
}
