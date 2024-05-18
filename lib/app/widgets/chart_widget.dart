import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tramo/app/constants/themes/font_style.dart';
import 'package:tramo/app/widgets/sensor_detail_widget.dart';
import 'package:tramo/app/widgets/sensor_detail_dialog.dart';

import '../constants/themes/app_colors.dart';

class ChartWidget extends StatelessWidget {
  final GetxController controller;

  String? chartTitle;
  String? sensorID;
  String? prtgIP;
  List mainData;
  List timeData;

  ChartWidget({
    required this.controller,
    this.chartTitle,
    this.sensorID,
    this.prtgIP,
    required this.mainData,
    required this.timeData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int latestData = mainData[mainData.length - 1];

    var maxVal = mainData.reduce(
      (previousValue, element) =>
          previousValue > element ? previousValue.toDouble() : element.toDouble(),
    );

    late double latestAverage;
    late int totalAvg;

    if (mainData.length >= 10) {
      // totalAvg = 10;
      latestAverage = mainData.reversed.toList().sublist(0, 10).fold(
            0,
            (prevVal, element) => prevVal > element ? prevVal : element,
          );
    } else {
      // totalAvg = mainData.reversed.toList().sublist(0, mainData.length).length;

      latestAverage = mainData.reversed.toList().sublist(0, mainData.length).fold(
            0,
            (prevVal, element) => prevVal > element ? prevVal : element,
          );
    }

    // double currentThresold = (latestAverage / totalAvg) * .85;
    double majorThresold = latestAverage * .2;
    double minorThresold = latestAverage * .7;

    if (maxVal <= 20000) {
      maxVal += 2000;
    } else if (maxVal >= 800000) {
      maxVal += 200000;
    } else {
      maxVal += 100000;
    }

    if (mainData.isEmpty) {
      return const CircularProgressIndicator();
    }

    return LayoutBuilder(builder: (context, constraints) {
      // var boxHeight = Get.width / constraints.maxHeight;
      var boxWidth = ((Get.width / (constraints.maxWidth + 10)) - 1).ceil();

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: BaseColors.navbarBackground.withOpacity(.5),
        ),
        height: 300,
        padding: const EdgeInsets.only(top: 20, bottom: 20, right: 30, left: 24),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.cyan.withOpacity(.2),
                strokeWidth: .3,
              ),
              drawVerticalLine: true,
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.cyan.withOpacity(.2),
                strokeWidth: .3,
              ),
              horizontalInterval: maxVal >= 800000
                  ? 200000
                  : maxVal <= 350000
                      ? maxVal <= 20000
                          ? 2000
                          : 50000
                      : 100000,
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                axisNameSize: 22,
                axisNameWidget: SizedBox(
                  width: boxWidth < 2
                      ? Get.width * .7
                      : boxWidth == 2
                          ? Get.width * .28
                          : boxWidth == 3
                              ? Get.width * .21
                              : Get.width * .15,
                  child: SensorDetailWidget(
                      chartTitle: "$chartTitle",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => sensorDetailDialog(
                            chartTitle ?? "",
                            sensorID ?? "",
                            prtgIP ?? "",
                          ),
                        );
                      }),
                ),
              ),
              rightTitles: AxisTitles(),
              leftTitles: AxisTitles(
                axisNameSize: 15,
                axisNameWidget: Text(
                  "Total Traffic (Kbps)",
                  style: AppFonts.mediumText.copyWith(
                    color: BaseColors.primaryText,
                    fontSize: 10.0,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxVal >= 800000
                      ? 200000
                      : maxVal <= 350000 && maxVal > 20000
                          ? 50000
                          : maxVal <= 20000
                              ? 2000
                              : 100000,
                  getTitlesWidget: (value, meta) {
                    for (var i = 0; i < mainData.length; i++) {
                      if (value == 0) {
                        return const SizedBox();
                      }

                      if (value == maxVal) {
                        return const SizedBox();
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        "${(value).toInt() ~/ 1000}K",
                        textAlign: TextAlign.right,
                        style: AppFonts.regularText.copyWith(
                          color: BaseColors.secondaryText,
                          fontSize: 10.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  interval: 1,
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    TextStyle style = AppFonts.regularText.copyWith(
                      color: BaseColors.primaryText,
                      fontSize: 10.0,
                    );

                    for (var i = 0; i < timeData.length; i++) {
                      // if (value.toInt() == 0 && timeData.length == 1) {
                      //   return RotatedBox(
                      //     quarterTurns: 3,
                      //     child: Text(timeData[i], style: style),
                      //   );
                      // }

                      // if (value.toInt() == 0 && timeData.length < 10) {
                      //   return const SizedBox();
                      // }

                      if (value.toInt() == i &&
                          int.parse(timeData[i].split(":")[1]) % 2 != 0 &&
                          timeData.length < 20) {
                        return const SizedBox();
                      }

                      if (value.toInt() == i &&
                          int.parse(timeData[i].split(":")[1]) % 2 == 0 &&
                          timeData.length < 20) {
                        return RotatedBox(
                          quarterTurns: 3,
                          child: Text(timeData[i], style: style),
                        );
                      }

                      if (value.toInt() == i &&
                          int.parse(timeData[i].split(":")[1]) % 5 != 0 &&
                          timeData.length > 20) {
                        return const SizedBox();
                      }

                      if (value.toInt() == i &&
                          int.parse(timeData[i].split(":")[1]) % 5 == 0 &&
                          timeData.length > 20) {
                        return RotatedBox(
                          quarterTurns: 3,
                          child: Text(timeData[i], style: style),
                        );
                      }

                      if (value.toInt() == i) {
                        return RotatedBox(
                          quarterTurns: 3,
                          child: Text(timeData[i], style: style),
                        );
                      }
                    }

                    return Text(value.toString());
                  },
                ),
              ),
            ),
            maxY: maxVal.toDouble(),
            minY: 0,
            maxX: mainData.length.toDouble() - 1,
            minX: 0,
            backgroundColor: BaseColors.primaryBackground,
            clipData: FlClipData.all(),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.cyan.withOpacity(.2),
                width: 1,
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                maxContentWidth: 200,
                tooltipBgColor: BaseColors.secondaryBackground.withOpacity(.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((e) {
                    final flSpot = e;

                    return LineTooltipItem(
                      "• Time: ${timeData[flSpot.x.toInt()]} WIB\n• Traffic: ${NumberFormat.decimalPattern().format(flSpot.y.toInt())} Kbps",
                      AppFonts.mediumText.copyWith(
                        color: BaseColors.primaryText,
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.left,
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                dotData: FlDotData(show: false),
                spots: List.generate(
                  mainData.length,
                  (index) => FlSpot(index.toDouble(), mainData[index].toDouble()),
                ),
                color: latestData >= minorThresold
                    ? AccentColors.tealColor
                    : latestData < minorThresold && latestData > majorThresold
                        ? AccentColors.yellowColor
                        : AccentColors.maroonColor,
                isCurved: true,
                barWidth: 3,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: latestData >= minorThresold
                        ? [
                            AccentColors.tealColor.withOpacity(.5),
                            AccentColors.tealColor.withOpacity(.25),
                            AccentColors.tealColor.withOpacity(.05),
                            AccentColors.tealColor.withOpacity(0),
                          ]
                        : latestData < minorThresold && latestData > majorThresold
                            ? [
                                AccentColors.yellowColor.withOpacity(.5),
                                AccentColors.yellowColor.withOpacity(.25),
                                AccentColors.yellowColor.withOpacity(0.05),
                                AccentColors.yellowColor.withOpacity(0),
                              ]
                            : [
                                AccentColors.maroonColor.withOpacity(.5),
                                AccentColors.maroonColor.withOpacity(.25),
                                AccentColors.maroonColor.withOpacity(.05),
                                AccentColors.maroonColor.withOpacity(0),
                              ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
