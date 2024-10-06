import 'dart:math';

import 'package:flutter/material.dart';

class RowTile extends StatelessWidget {
  final String title;
  final Icon icon;
  final VoidCallback? onTap; // Añadir el callback
  final Future<void> Function()?
      onTapFuture; // Cambiar el tipo de onTap a Future<void>

  const RowTile(
      {super.key,
      required this.title,
      required this.icon,
      this.onTap,
      this.onTapFuture});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.navigate_next_sharp),
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          onTapFuture!();
        }
      },
      contentPadding: EdgeInsets.zero, // Elimina el padding adicional
      visualDensity:
          const VisualDensity(vertical: -4), // Reduce la altura vertical
    );
  }
}
