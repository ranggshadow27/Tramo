import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';
import 'package:tramo/app/widgets/custom_button.dart';
import 'package:tramo/app/widgets/custom_textfield.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import 'dropdown_field.dart';

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
              "API Setting",
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
              "Groups Setting",
              style: AppFonts.regularText.copyWith(
                color: BaseColors.primaryText.withOpacity(.5),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 16),
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
                    onTap: () => controller.exportProfile(),
                    color: BaseColors.secondaryBackground,
                    title: "Update",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: myCustomButton(
                    onTap: () => controller.exportProfile(),
                    color: AccentColors.maroonColor,
                    title: "Delete",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Profile Setting",
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
                SizedBox(width: 10),
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
