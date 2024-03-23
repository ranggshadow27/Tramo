import 'package:flutter/material.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({
    super.key,
    required this.dataMonit,
    required this.index,
    this.dat,
    this.maxHeig,
  });

  final List dataMonit;
  final int index;
  final String? dat;
  final double? maxHeig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaseColors.primaryBackground,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: BaseColors.secondaryText.withOpacity(.25),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dataMonit[index],
                  style: AppFonts.boldText.copyWith(
                    color: BaseColors.primaryText,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Monitoring",
                  style: AppFonts.regularText.copyWith(
                    color: BaseColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;

              return Container(
                height: maxHeig! < 400 || maxHeig! < 670
                    ? height * .8
                    : constraints.maxWidth < 900
                        ? height * .9
                        : height * .9,
                width: width * 1,
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth <= 720 ? 2 : 3,
                    childAspectRatio: constraints.maxWidth <= 720 ? 1.5 : 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AccentColors.tealColor,
                    ),
                    child: Center(
                      child: Text(dat!),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
