import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';
import 'package:tramo/app/routes/app_pages.dart';
import 'package:tramo/app/widgets/custom_button.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import 'setting_dialog.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final bool isShrink = controller.isNavbarShrink.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: BaseColors.primaryBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: 300,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(
                            "Sign out from this app?",
                            style: AppFonts.regularText.copyWith(
                              color: BaseColors.primaryText.withOpacity(.5),
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            height: 45,
                            child: myCustomButton(
                              onTap: () async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();

                                pref.setBool('session', false);

                                Get.offAndToNamed(Routes.LOGIN);
                              },
                              title: 'Sign Out',
                              color: AccentColors.redColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: isShrink ? 230 : 40,
            height: isShrink ? 44 : 40,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: BaseColors.secondaryBackground,
                width: 1,
              ),
            ),
            child: isShrink
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 45),
                      const Icon(
                        FontAwesomeIcons.rightFromBracket,
                        color: AccentColors.redColor,
                        size: 14,
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 150,
                        child: Text(
                          title,
                          style: AppFonts.semiBoldText
                              .copyWith(color: BaseColors.primaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Icon(
                      FontAwesomeIcons.rightFromBracket,
                      color: AccentColors.maroonColor,
                      size: 14,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
