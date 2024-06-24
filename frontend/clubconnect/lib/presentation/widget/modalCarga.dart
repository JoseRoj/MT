import 'package:flutter/material.dart';

Widget modalCarga(String text) {
  return AlertDialog(
    content: SizedBox(
      height: 100,
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(text),
        ],
      ),
    ),
  );
}
