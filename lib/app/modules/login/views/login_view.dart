import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:tramo/app/widgets/custom_button.dart';
import 'package:tramo/app/widgets/custom_textfield.dart';

import '../../../constants/themes/app_colors.dart';
import '../../../constants/themes/font_style.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: BaseColors.primaryBackground,
      body: Center(
        child: IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 35),
            width: mediaQuery.width * .25,
            decoration: BoxDecoration(
              color: BaseColors.secondaryBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome",
                  style: AppFonts.regularText.copyWith(
                    color: BaseColors.primaryText,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Please login to continue using app",
                  style: AppFonts.regularText.copyWith(
                    color: BaseColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: mediaQuery.width * .2,
                  child: myTextField(
                    hintText: 'Your username here',
                    labelText: 'Username',
                    c: controller.emailTC,
                    onChanged: (p0) {},
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: mediaQuery.width * .2,
                  child: myTextField(
                    hintText: '••••••••••••',
                    labelText: 'Password',
                    c: controller.passTC,
                    isPassword: true,
                    onChanged: (p0) {},
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: mediaQuery.width * .2,
                  height: 45,
                  child: myCustomButton(
                    onTap: () => controller.login(context),
                    title: 'Login',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
