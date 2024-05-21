import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color.fromARGB(255, 255, 255, 255),
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
            fontSize: 12,
          ),
          labelSmall: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
      );
}
