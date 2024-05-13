import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      borderRadius: BorderRadius.circular(8),
      color: Colors.transparent,
      child: Center(
        child: InkWell(
          onTap: () {
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
              border: Border.all(
                color: BaseColors.secondaryBackground,
                width: isShrink ? 1 : 2,
              ),
            ),
            child: isShrink
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      const Icon(
                        FontAwesomeIcons.plus,
                        color: AccentColors.greenColor,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        child: Text(
                          title,
                          style: AppFonts.semiBoldText.copyWith(
                            color: BaseColors.primaryText,
                            fontSize: 12.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                : const Expanded(
                    child: Icon(FontAwesomeIcons.plus, color: AccentColors.greenColor, size: 12),
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
            GetBuilder<HomeController>(
              builder: (controller) => myTextField(
                hintText: "ex. 25609",
                c: controller.sensorsIdTC,
                errorText: controller.groupNameObx,
                labelText: "Insert the Sensor ID from PRTG",
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(height: 20),
            GetBuilder<HomeController>(
              builder: (controller) => myTextField(
                hintText: "ex. 202.55.175.235:8443",
                c: controller.prtgIpTC,
                errorText: controller.errNameObx,
                labelText: "Insert the PRTG IP",
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(height: 20),
            myCustomButton(
              onTap: () => controller.saveSensorsData(index),
            ),
          ],
        ),
      ),
    ),
  );
}
