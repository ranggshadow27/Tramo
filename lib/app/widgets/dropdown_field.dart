import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

class DropdownField extends StatelessWidget {
  const DropdownField({
    super.key,
    required this.items,
    required this.errorText,
    required this.hintText,
    required this.labelText,
  });

  final List<String> items;
  final String hintText, labelText, errorText;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return DropdownButtonFormField2(
      isExpanded: true,
      hint: Text(
        hintText,
        style: AppFonts.regularText.copyWith(
          color: BaseColors.primaryText.withOpacity(.3),
          fontSize: 14.0,
        ),
      ),
      decoration: InputDecoration(
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AccentColors.redColor, width: 2),
        ),
        fillColor: BaseColors.primaryText.withOpacity(.02),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AccentColors.tealColor, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: AppFonts.regularText.copyWith(
          color: BaseColors.primaryText.withOpacity(.3),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.solidCircle,
                    color: AccentColors.tealColor,
                    size: 8,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item,
                    style: AppFonts.regularText.copyWith(
                      color: BaseColors.primaryText,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              )))
          .toList(),
      validator: (value) {
        if (value == null) {
          return 'Please select gender.';
        }
        return null;
      },
      onChanged: (value) {
        controller.selectedGroupName = value;

        debugPrint(controller.selectedGroupName);
      },
      onSaved: (value) {
        // selectedValue = value.toString();
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: BaseColors.secondaryBackground,
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
