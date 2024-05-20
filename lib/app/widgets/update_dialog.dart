import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import 'confirm_delete_dialog.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';
import 'info_notification.dart';

Widget updateDialog(BuildContext context, int index, bool isMuted) {
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
              "| Sensor Setting",
              style: AppFonts.regularText.copyWith(
                color: BaseColors.primaryText.withOpacity(.5),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 18),
            Obx(
              () => myTextField(
                hintText: "ex. 25609",
                c: controller.sensorsIdTC,
                errorText:
                    controller.groupNameObs.value == "" ? null : controller.groupNameObs.value,
                labelText: "Insert the Sensor ID from PRTG",
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    controller.groupNameObs.value = "";
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => myTextField(
                hintText: "ex. 202.55.175.235:8443",
                c: controller.prtgIpTC,
                errorText: controller.errNameObs.value == "" ? null : controller.errNameObs.value,
                labelText: "Insert the PRTG IP",
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    controller.errNameObs.value = "";
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            myCustomButton(
              color: BaseColors.secondaryBackground,
              title: "Update",
              onTap: () async {
                await controller.updateSensor(index);
              },
            ),
            const SizedBox(height: 4),
            myCustomButton(
                color: BaseColors.secondaryBackground,
                title: !isMuted ? "Enable Alarm" : "Disable Alarm",
                onTap: () {
                  controller.disableAlert(index);
                  showInfoNotification(
                    context: context,
                    description: "${controller.sensorsValue[index]['name']} Muted",
                  );
                }),
            const SizedBox(height: 10),
            myCustomButton(
              color: AccentColors.redColor,
              title: "Delete",
              onTap: () {
                String data = controller.sensorsValue[index]['name'].toString();
                Get.back();
                showDialog(
                  context: context,
                  builder: (context) => confirmDeleteDialog(
                    "This action will remove sensor $data from sensor group",
                    () async {
                      await controller.deleteSensor(index);
                      Get.back();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
