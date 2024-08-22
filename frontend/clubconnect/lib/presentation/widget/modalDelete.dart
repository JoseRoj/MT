import 'package:flutter/material.dart';

Future<bool> modalDelete(BuildContext context, String text) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(text, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ) ??
      false;
}
