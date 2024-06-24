import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color.fromARGB(255, 85, 237, 115),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          bodySmall: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          titleLarge: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontSize: 24,
            overflow: TextOverflow.clip,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            color: Colors.black,
            fontSize: 20,
            overflow: TextOverflow.clip,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
          labelMedium: TextStyle(
            color: Colors.black,
            fontSize: 15,
            overflow: TextOverflow.ellipsis,
          ),
          labelSmall: TextStyle(
            color: Colors.black,
            fontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Definir el tema del TimePicker aquí
        timePickerTheme: TimePickerThemeData(
          confirmButtonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Color.fromARGB(255, 61, 255, 47),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              Color.fromARGB(255, 15, 16, 17),
            ),
          ),
          hourMinuteTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 61, 255, 47),
            fontFamily: 'Roboto', // Cambia esto por la fuente que desees
          ),
          dayPeriodTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 15, 16, 17),
            fontFamily: 'Roboto', // Cambia esto por la fuente que desees
          ),
          helpTextStyle: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.normal,
            color: Colors.grey,
            fontFamily: 'Roboto', // Cambia esto por la fuente que desees
          ),
          // Otros estilos pueden ser configurados aquí
        ),
      );
}
