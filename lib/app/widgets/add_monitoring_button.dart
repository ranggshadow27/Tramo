import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

class AddMonitoringButton extends StatelessWidget {
  const AddMonitoringButton({
    super.key,
    required this.controller,
    required this.title,
    this.callback,
  });

  final String title;
  final VoidCallback? callback;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final bool isShrink = controller.isNavbarShrink.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => myCustomDialog(context, controller),
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
                        FontAwesomeIcons.plus,
                        color: AccentColors.blueColor,
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
                      FontAwesomeIcons.plus,
                      color: AccentColors.blueColor,
                      size: 12,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Widget myCustomDialog(BuildContext context, HomeController controller) {
  return Dialog(
    child: IntrinsicHeight(
      child: Container(
        width: MediaQuery.sizeOf(context).width * .4,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("data"),
            TextField(
              controller: controller.monitoringGroupTC,
            ),
            ElevatedButton(
              onPressed: () {
                controller.saveMonitoringGroup();
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    ),
  );
}
