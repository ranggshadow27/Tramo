import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import 'setting_dialog.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({
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
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) {
                controller.saveApiURL.value = false;

                controller.groupNameObx = null;
                return settingDialog(context);
              },
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: isShrink ? 230 : 40,
            height: isShrink ? 54 : 40,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
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
                        FontAwesomeIcons.gear,
                        color: BaseColors.primaryText,
                        size: 12,
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 150,
                        child: Text(
                          title,
                          style: AppFonts.semiBoldText.copyWith(color: BaseColors.primaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Icon(
                      FontAwesomeIcons.gear,
                      color: BaseColors.primaryText,
                      size: 12,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
