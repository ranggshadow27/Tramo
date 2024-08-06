import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tramo/app/routes/app_pages.dart';
import 'package:tramo/app/widgets/error_notification.dart';
import 'package:tramo/app/widgets/info_notification.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  TextEditingController emailTC = TextEditingController();
  TextEditingController passTC = TextEditingController();

  login(BuildContext context) {
    if (emailTC.text.isNotEmpty && passTC.text.isNotEmpty) {
      if (emailTC.text == "testadmin" && passTC.text == "admintest") {
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
