import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';

void main() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool isLogin = pref.getBool('session') ?? false;

  runApp(
    GetMaterialApp(
      title: "NETLERT Monitor",
      debugShowCheckedModeBanner: false,
      initialRoute: !isLogin ? Routes.LOGIN : Routes.HOME,
      getPages: AppPages.routes,
    ),
  );
}
