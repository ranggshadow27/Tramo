import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tramo/app/widgets/confirm_reset_data_dialog.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import '../modules/home/controllers/home_controller.dart';
import 'confirm_delete_dialog.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

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
            Obx(
              () => myTextField(
                hintText: "Insert New Group Name",
                labelText: "Rename Group",
                errorText: controller.errNameObs.value != "" ? controller.errNameObs.value : null,
                c: controller.renameGroupTC,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    controller.errNameObs.value = "";
                  }

                  debugPrint("THIS IS_> $value");
                },
              ),
            ),
            const SizedBox(height: 6),
            myCustomButton(
              onTap: () {
                controller.updateMonitoringGroup();
              },
              title: "Rename Group",
              color: BaseColors.secondaryBackground,
            ),
            const SizedBox(height: 4),
            Obx(() => controller.updateGroupSuccess.isFalse
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
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => confirmDeleteDialog(
                    "This action will delete ${controller.selectedGroupName!} from monitoring group",
                    () => controller.deleteMonitoringGroup(),
                  ),
                );
              },
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => confirmResetDataDialog(
                          controller.selectedGroupName!,
                          () => controller.resetSensorValue(context),
                        ),
                      );
                    },
                    color: BaseColors.secondaryBackground,
                    title: "Reset Data",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: myCustomButton(
                    onTap: () {},
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
