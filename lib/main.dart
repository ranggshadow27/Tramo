import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';

void main() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool isLogin = pref.getBool('session') ?? false;

  debugPrint("Kita cek loginnya dahulu ges : $isLogin");

  runApp(
    GetMaterialApp(
      title: "Sysmo",
      debugShowCheckedModeBanner: false,
      initialRoute: !isLogin ? Routes.LOGIN : Routes.HOME,
      getPages: AppPages.routes,
    ),
  );
}
