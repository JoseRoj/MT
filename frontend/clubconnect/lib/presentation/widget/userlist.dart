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
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
              "https://img.freepik.com/foto-gratis/chico-guapo-seguro-posando-contra-pared-blanca_176420-32936.jpg"),
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
