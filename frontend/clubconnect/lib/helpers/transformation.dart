import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:intl/intl.dart';

DateTime transformarAFecha(String fechaStr) {
  // Definir el formato de fecha esperado
  DateFormat formato = DateFormat('dd/MM/yyyy');
  // Parsear la cadena de fecha al tipo DateTime
  DateTime fecha = formato.parse(fechaStr);

  return fecha;
}

Future<String> toBase64C(String ruta) async {
  if (ruta.isNotEmpty) {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(ruta);
    File compressedFile = await FlutterNativeImage.compressImage(ruta,
        quality: 65,
        targetWidth: 400,
        targetHeight: (properties.height! * 400 / properties.width!).round());
    final bytes = await compressedFile.readAsBytes();
    String img64 = base64Encode(bytes);
    return img64;
  } else {
    return "";
  }
}

DateTime dateTimeWithHourSpecific(TimeOfDay hora) {
  return DateTime(
      DateTime.now().year, // Año actual
      DateTime.now().month, // Mes actual
      DateTime.now().day, // Día actual
      hora.hour, // Hora especificada en `hours`
      hora.minute // Minuto especificado en `horaInicio`
      );
}

Uint8List imagenFromBase64(String s) {
  return base64Decode(s);
}

String DateToString(DateTime date) {
  String formattedDate = DateFormat('dd/MM/yyyy').format(date);
  return formattedDate;
}

TimeOfDay convertirStringATimeOfDay(String horaString) {
  List<String> tiempo = horaString.split(":");
  int hora = int.parse(tiempo[0]);
  int minuto = int.parse(tiempo[1]);

  return TimeOfDay(hour: hora, minute: minuto);
}
