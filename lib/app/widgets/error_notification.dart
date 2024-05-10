import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flutter/widgets.dart';
import 'package:tramo/app/constants/themes/font_style.dart';

import '../constants/themes/app_colors.dart';

showErrorNotification({required BuildContext context}) {
  ElegantNotification.error(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'topRight',
      type: StackedType.below,
      itemOffset: Offset(0, 5),
    ),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      'Error',
      style: AppFonts.regularText.copyWith(color: BaseColors.primaryText),
    ),
    background: BaseColors.secondaryBackground,
    description: Text(
      'Error example notification',
      style: AppFonts.regularText.copyWith(color: BaseColors.primaryText.withOpacity(.8)),
    ),
    onDismiss: () {},
  ).show(context);
}
