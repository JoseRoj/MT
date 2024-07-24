import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> cuppertinoModal(
  BuildContext context,
  DateTime? initDateTime,
  DateTime? minDateTime,
  DateTime? maxDateTime,
) async {
  DateTime? selectedDate;
  int aplicar = 0;
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      height: 250,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              backgroundColor: Colors.white,
              minimumDate: minDateTime ?? DateTime.now(),
              maximumDate:
                  maxDateTime ?? DateTime.now().add(const Duration(days: 365)),
              initialDateTime: initDateTime ?? DateTime.now(),
              onDateTimeChanged: (DateTime value) {
                selectedDate = value;
              },
            ),
          ),
          CupertinoButton(
            child: const Text('Aplicar Nuevo Limite'),
            onPressed: () {
              aplicar = 1;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ),
  );
  return aplicar == 1 ? selectedDate : null;
}
