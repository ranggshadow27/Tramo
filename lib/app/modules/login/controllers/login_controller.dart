import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramo/app/routes/app_pages.dart';
import 'package:tramo/app/widgets/error_notification.dart';
import 'package:tramo/app/widgets/info_notification.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController

  @override
  void onInit() async {
    super.onInit();

    await sessionCheck();
  }

  TextEditingController emailTC = TextEditingController();
  TextEditingController passTC = TextEditingController();

  bool? isLogin;

  sessionCheck() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    isLogin = pref.getBool('session') ?? false;

    debugPrint("Session Check $isLogin");

    if (isLogin! == true) {
      return Get.offAndToNamed(Routes.HOME);
    }
  }

  login(BuildContext context) async {
    if (emailTC.text.isNotEmpty && passTC.text.isNotEmpty) {
      if (emailTC.text == "netlertadmin" && passTC.text == "admin@netlert") {
        SharedPreferences pref = await SharedPreferences.getInstance();

        pref.setBool('session', true);

        Get.offAndToNamed(Routes.HOME);
        showInfoNotification(
            context: context, description: "Login successfully");
      } else {
        showErrorNotification(
            context: context,
            type: 'major',
            description: "Login Error : Username or Password incorrect");
      }
    } else {
      showErrorNotification(
          context: context,
          type: 'major',
          description: "Login Error : Please fill the required field");
    }
  }
}
