import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import '../modules/home/controllers/home_controller.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';
import 'dropdown_field.dart';

Widget editGroupDialog(BuildContext context) {
  final controller = Get.put(HomeController());

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "| Group Setting",
              style: AppFonts.regularText.copyWith(
                color: BaseColors.primaryText.withOpacity(.5),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 16),
            myTextField(
              hintText: "localhost:8080",
              labelText: "Server URL",
              c: controller.apiServerTC,
            ),
            const SizedBox(height: 6),
            myCustomButton(
              onTap: () => controller.saveApiEndPoint(),
              title: "Rename Group",
              color: BaseColors.secondaryBackground,
            ),
            const SizedBox(height: 4),
            Obx(() => controller.saveApiURL.isFalse
                ? const SizedBox()
                : Text(
                    "  Done Save",
                    style: AppFonts.regularText.copyWith(
                      color: AccentColors.tealColor,
                      fontSize: 12.0,
                    ),
                  )),
            const SizedBox(height: 4),
            myCustomButton(
              onTap: () => controller.exportProfile(),
              color: AccentColors.maroonColor,
              title: "Remove Group",
            ),
            const SizedBox(height: 14),
            Text(
              "| Sensor Setting",
              style: AppFonts.regularText.copyWith(
                color: BaseColors.primaryText.withOpacity(.5),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: myCustomButton(
                    onTap: () => controller.exportProfile(),
                    color: BaseColors.secondaryBackground,
                    title: "Reset Data",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: myCustomButton(
                    onTap: () => controller.exportProfile(),
                    color: BaseColors.secondaryBackground,
                    title: "Clear",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
