import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => myCustomDialog(context, controller, index),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: isShrink ? 160 : 40,
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
                      const SizedBox(width: 20),
                      const Icon(
                        FontAwesomeIcons.plus,
                        color: AccentColors.greenColor,
                        size: 12,
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
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
                      FontAwesomeIcons.plus,
                      color: AccentColors.greenColor,
                      size: 12,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Widget myCustomDialog(BuildContext context, HomeController controller, int index) {
  return Dialog(
    child: IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Please insert the Sensor Id from PRTG"),
            SizedBox(
              width: 300,
              child: TextField(
                controller: controller.sensorsIdTC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Please insert the PRTG IP"),
            SizedBox(
              width: 300,
              child: TextField(
                controller: controller.prtgIpTC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.saveSensorsData(index);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    ),
  );
}
