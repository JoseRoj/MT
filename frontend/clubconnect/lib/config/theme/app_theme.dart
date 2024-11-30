import 'package:flutter/material.dart';

class AppTheme {
  /// Función para determinar el color del texto según el fondo
  Color getContrastingTextColor(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.4 ? Colors.black : Colors.white;
  }

  ThemeData getTheme({Color? scaffold}) {
    final Color backgroundColor = Color.fromARGB(0, 255, 255, 255);
    final Color textColor = getContrastingTextColor(
        scaffold ?? const Color.fromARGB(255, 255, 255, 255));
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: backgroundColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 20,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: textColor,
          fontSize: 12,
        ),
        titleLarge: TextStyle(
          color: textColor,
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
          color: textColor,
          fontSize: 24,
          overflow: TextOverflow.clip,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          color: textColor,
          fontSize: 20,
          overflow: TextOverflow.clip,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          color: textColor,
          fontSize: 24,
        ),
        labelMedium: TextStyle(
          color: textColor,
          fontSize: 15,
          overflow: TextOverflow.ellipsis,
        ),
        labelSmall: TextStyle(
          color: textColor,
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      // Configuración del tema del TimePicker
      timePickerTheme: TimePickerThemeData(
        confirmButtonStyle: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Color.fromARGB(255, 69, 223, 58),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            getContrastingTextColor(Color.fromARGB(255, 69, 223, 58)),
          ),
        ),
        hourMinuteTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Roboto',
        ),
        dayPeriodTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Roboto',
        ),
        helpTextStyle: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
