// these are sine helpful functions used accross the app

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double amount into dollar and cents
String formatDouble(double amount) {
  final format =
      NumberFormat.currency(locale: "en_US", symbol: "\$", decimalDigits: 2);
  return format.format(amount);
}

int calculateMonth(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}
