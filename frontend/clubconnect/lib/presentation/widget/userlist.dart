import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:flutter/material.dart';

Widget userList({
  required String name,
  required String? image,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: 50,
    // Ajusta el ancho de los elementos según sea necesario
    child: Column(
      children: [
        ImageOval(
          image!,
          imagenFromBase64(image),
          50,
          50,
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
          maxLines: 2,
        ),
      ],
    ),
  );
}
