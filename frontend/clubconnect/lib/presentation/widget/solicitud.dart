import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:flutter/material.dart';

Widget solicitud(Solicitud solicitud, BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
    width: MediaQuery.of(context).size.width * 0.9,
    height: 80,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
      boxShadow: [
        BoxShadow(
          color: Color.fromARGB(255, 94, 94, 94)
              .withOpacity(0.2), // Color de la sombra
          spreadRadius: 5,
          blurRadius: 5,
          offset: Offset(0, 2), // Desplazamiento de la sombra
        ),
      ],
      color: const Color.fromRGBO(255, 255, 255, 40), // Color del contenedor
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              child: Text(
                  "${solicitud.nombre} ${solicitud.apellido1} ${solicitud.apellido2} ha enviado una solicitud de unión al Club el ${DateToString(solicitud.fechaSolicitud)}",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3),
            ),
          ),
          Container()
        ],
      ),
    ),
  );
}
