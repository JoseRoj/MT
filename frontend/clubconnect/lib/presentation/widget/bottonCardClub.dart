import 'dart:typed_data';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget bottomCardClub(Club club, List<Deporte> deportes, BuildContext context,
    Function() closeWindow) {
  print(deportes);
  final deporte =
      deportes.firstWhere((deporte) => deporte.id == club.idDeporte).nombre;
  return Stack(
    children: [
      Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: club.logo == "" || club.logo == null
                  ? ClipOval(
                      child: Image.asset(
                        'assets/nofoto.jpeg',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    )
                  : ClipOval(
                      child: Image.memory(
                        imagenFromBase64(club.logo),
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    ),
            ),
            Container(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${club.nombre}",
                      style: AppTheme().getTheme().textTheme.titleSmall),
                  Text(deporte!),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                ),
                onPressed: () {
                  context.go('/home/0/club/${club.id}');
                },
                child: Text(
                  'Ver',
                  style: AppTheme().getTheme().textTheme.labelSmall,
                ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: IconButton.filled(
          constraints: BoxConstraints.tightFor(
            width: 25,
            height: 25,
          ),
          iconSize: 10,
          onPressed: () {
            closeWindow();
          },
          icon: Icon(Icons.close),
        ),
      ),
    ],
  );
}
