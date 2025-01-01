import 'package:flutter/material.dart';
import 'package:newpapp/bar_graph/bar_graph.dart';
import 'package:newpapp/data/hairfall_data.dart';
import 'package:newpapp/date_time/date_time_helper.dart';
import 'package:provider/provider.dart';

class HairfallSummary extends StatelessWidget {
  final DateTime startOfWeek;

  const HairfallSummary({super.key, required this.startOfWeek});

  double calculateMax(HairfallData value, String sunday, String monday, String tuesday, String wednesday, String thursday, String friday, String saturday){
    double? max=100;
    List <double> values = [
      value.calculateDailyHairfallSummary()[sunday]??0,
      value.calculateDailyHairfallSummary()[monday]??0,
      value.calculateDailyHairfallSummary()[tuesday]??0,
      value.calculateDailyHairfallSummary()[wednesday]??0,
      value.calculateDailyHairfallSummary()[thursday]??0,
      value.calculateDailyHairfallSummary()[friday]??0,
      value.calculateDailyHairfallSummary()[saturday]??0,
    ];
    //sort from smallest to largest
    values.sort();
    max=values.last*1.1;

    return max==0 ? 100 : max;
  }
  @override
  Widget build(BuildContext context) {
    String sunday = convertDateTimetoString(startOfWeek.add(const Duration(days:0)));
    String monday = convertDateTimetoString(startOfWeek.add(const Duration(days:1)));
    String tuesday = convertDateTimetoString(startOfWeek.add(const Duration(days:2)));
    String wednesday = convertDateTimetoString(startOfWeek.add(const Duration(days:3)));
    String thursday = convertDateTimetoString(startOfWeek.add(const Duration(days:4)));
    String friday = convertDateTimetoString(startOfWeek.add(const Duration(days:5)));
    String saturday = convertDateTimetoString(startOfWeek.add(const Duration(days:6)));


    return Consumer<HairfallData>(builder: (context, value, child) => SizedBox(
      height:300,
      child: MyBarGraph(
        maxY: calculateMax(value, sunday, monday, tuesday, wednesday, thursday, friday, saturday), 
        sunAmount: value.calculateDailyHairfallSummary()[sunday]??0, 
        monAmount:  value.calculateDailyHairfallSummary()[monday]??0, 
        tueAmount:  value.calculateDailyHairfallSummary()[tuesday]??0, 
        wedAmount:  value.calculateDailyHairfallSummary()[wednesday]??0, 
        thursAmount:  value.calculateDailyHairfallSummary()[thursday]??0, 
        friAmount:  value.calculateDailyHairfallSummary()[friday]??0, 
        satAmount:  value.calculateDailyHairfallSummary()[saturday]??0)
    ),);
  }
}