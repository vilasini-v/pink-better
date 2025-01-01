import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:newpapp/bar_graph/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final double? maxY;
  final double sunAmount;
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thursAmount;
  final double friAmount;
  final double satAmount;

  const MyBarGraph({
    super.key,
    required this.maxY,
    required this.sunAmount, 
    required this.monAmount, 
    required this.tueAmount, 
    required this.wedAmount, 
    required this.thursAmount,
    required this.friAmount,
    required this.satAmount
    });

  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(sunAmount: sunAmount, monAmount: monAmount, tueAmount: tueAmount, wedAmount: wedAmount, thursAmount: thursAmount, friAmount: friAmount, satAmount: satAmount);
    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
        maxY: 80,
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          show:true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
            )
          ),
        ),
        barGroups: myBarData.barData
          .map((data)=>BarChartGroupData(
            x: data.x,
            barRods: [
              BarChartRodData(
                toY: data.y,
                color: const Color.fromARGB(255, 225, 160, 182),
                width: 15,
                borderRadius: BorderRadius.circular(4)),
            ]))
          .toList(),

      )
    );
  }
}
Widget getBottomTitles(double value, TitleMeta meta){
  const style= TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
  Widget text;
  switch(value.toInt()){
    case 0:
    text = const Text('S', style: style);
    break;
    case 1:
    text = const Text('M', style: style);
    break;
    case 2:
    text =const Text('T', style: style);
    break;
    case 3:
    text =const Text('W', style: style);
    break;
    case 4:
    text =const Text('T', style: style);
    break;
    case 5:
    text =const Text('F', style: style);
    break;
    case 6:
    text =const Text('S', style: style);
    break;
    default:
    text = const Text('');
  }
  return SideTitleWidget(axisSide: meta.axisSide, child: text);
}