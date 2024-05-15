import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tramo/app/widgets/edit_group_dialog.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import '../modules/home/controllers/home_controller.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';
import 'dropdown_field.dart';

Widget settingDialog(BuildContext context) {
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
              "| API Setting",
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
              title: "Update",
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
            const SizedBox(height: 20),
            Text(
              "| Groups Setting",
              style: AppFonts.regularText.copyWith(
                color: BaseColors.primaryText.withOpacity(.5),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 12),
            DropdownField(
              hintText: "Monitoring Group",
              labelText: "Select Group",
              items: List<String>.from(controller.monitoringList),
              errorText: "err",
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: myCustomButton(
                    onTap: () => showDialog(context: context, builder: editGroupDialog),
                    color: BaseColors.secondaryBackground,
                    title: "Edit Group",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: myCustomButton(
                    onTap: () => controller.deleteMonitoringGroup(),
                    color: AccentColors.maroonColor,
                    title: "Delete",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "| Profile Setting",
              style: AppFonts.regularText.copyWith(
                color: BaseColors.primaryText.withOpacity(.5),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: myCustomButton(
                    onTap: () => controller.exportProfile(),
                    title: "Export",
                    color: BaseColors.secondaryBackground,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: myCustomButton(
                    onTap: () => controller.importProfile(),
                    title: "Import",
                    color: BaseColors.secondaryBackground,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
