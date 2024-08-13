import 'package:flutter/material.dart';

Widget modalCarga(String text) {
  return AlertDialog(
    content: SizedBox(
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Ajusta el tamaño de la columna al contenido

        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
