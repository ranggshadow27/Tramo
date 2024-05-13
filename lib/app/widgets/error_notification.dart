import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tramo/app/constants/themes/font_style.dart';

import '../constants/themes/app_colors.dart';

showErrorNotification({
  required BuildContext context,
  required String type,
  required String description,
  title = "Alert",
}) {
  return ElegantNotification(
    icon: Icon(
      FontAwesomeIcons.circleExclamation,
      color: type == "minor" ? AccentColors.warningColor : AccentColors.redColor,
    ),
    progressIndicatorColor: type == "minor" ? AccentColors.warningColor : AccentColors.redColor,
    width: 360,
    toastDuration: const Duration(seconds: 5),
    stackedOptions: StackedOptions(
      key: 'topRight',
      type: StackedType.above,
      itemOffset: const Offset(0, 5),
    ),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      title,
      style: AppFonts.regularText.copyWith(color: BaseColors.primaryText),
    ),
    background: BaseColors.secondaryBackground,
    description: Text(
      description,
      style: AppFonts.regularText.copyWith(color: BaseColors.primaryText.withOpacity(.8)),
    ),
    onDismiss: () {},
  ).show(context);
}
