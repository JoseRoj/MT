import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:flutter/material.dart';

Widget userList({
  required String name,
  required String? image,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    width: 70,
    // Ajusta el ancho de los elementos según sea necesario
    child: Column(
      children: [
        ImageOval(
          image!,
          imagenFromBase64(image),
          60,
          60,
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
