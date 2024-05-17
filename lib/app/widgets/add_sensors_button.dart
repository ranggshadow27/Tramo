import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';
import 'package:tramo/app/widgets/custom_button.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import 'custom_textfield.dart';

class AddSensorButton extends StatelessWidget {
  const AddSensorButton({
    super.key,
    required this.controller,
    required this.title,
    required this.index,
    this.callback,
  });

  final String title;
  final VoidCallback? callback;
  final HomeController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool isShrink = controller.isWideWindow.value;

    return Material(
      color: BaseColors.secondaryBackground,
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: InkWell(
          onTap: () {
            controller.prtgIpTC.clear();
            controller.sensorsIdTC.clear();
            controller.errNameObs.value = "";
            controller.groupNameObs.value = "";

            showDialog(
              context: context,
              builder: (context) => myCustomDialog(context, index),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: isShrink ? 130 : 30,
            height: isShrink ? 40 : 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: isShrink
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      const Icon(
                        FontAwesomeIcons.plus,
                        color: AccentColors.greenColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        child: Text(
                          title,
                          style: AppFonts.semiBoldText.copyWith(
                            color: BaseColors.primaryText,
                            fontSize: 14.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                : const SizedBox(
                    child: Icon(
                      FontAwesomeIcons.plus,
                      color: AccentColors.greenColor,
                      size: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Widget myCustomDialog(BuildContext context, int index) {
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
          children: [
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
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            myCustomButton(
              onTap: () => controller.saveSensorsData(index),
            ),
          ],
        ),
      ),
    ),
  );
}
