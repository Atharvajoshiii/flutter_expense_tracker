import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newproject/bar%20graph/indivisual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndivisualBar> barData = [];
  void initializebardata() {
    barData = List.generate(widget.monthlySummary.length,
        (index) => IndivisualBar(x: index, y: widget.monthlySummary[index]));
  }

  // calculate the upper limit of graph

  double CalculateMax() {
    double max = 500;
    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;
    if (max < 500) {
      return 500;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    initializebardata();
    double barwidth = 20;
    double spaceBetweenBars = 15;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width:
            barwidth * barData.length + spaceBetweenBars * (barData.length - 1),
        child: BarChart(BarChartData(
            minY: 0,
            maxY: CalculateMax(),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
                show: true,
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getBottomTitles,
                        reservedSize: 24))),
            barGroups: barData
                .map((data) => BarChartGroupData(x: data.x, barRods: [
                      BarChartRodData(
                          toY: data.y,
                          width: barwidth,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade800,
                          backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: CalculateMax(),
                              color: const Color.fromARGB(255, 212, 211, 211)))
                    ]))
                .toList())),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'J';
      break;
    case 1:
      text = 'F';
      break;
    case 2:
      text = 'M';
      break;
    case 3:
      text = 'A';
      break;
    case 4:
      text = 'M';
      break;
    case 5:
      text = 'J';
      break;
    case 6:
      text = 'J';
      break;
    case 7:
      text = 'A';
      break;
    case 8:
      text = 'S';
      break;
    case 9:
      text = 'O';
      break;
    case 10:
      text = 'N';
      break;
    case 11:
      text = 'D';
      break;
    default:
      text = "";
      break;
  }

  return SideTitleWidget(
      child: Text(
        text,
        style: textStyle,
      ),
      axisSide: meta.axisSide);
}
