import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String dateToText(String message, DateTime date) {
  String day = DateFormat('d').format(date); // Día como texto
  String month = DateFormat('MMMM').format(date); // Nombre del mes completo
  String year = DateFormat('y').format(date); // Año como texto

  return "${message} ${day} ${month} ${year}";
}
