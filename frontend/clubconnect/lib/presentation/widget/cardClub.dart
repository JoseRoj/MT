import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardClub extends StatelessWidget {
  final Club club;
  const CardClub({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    print("cardClub");
    TextTheme StyleText = AppTheme().getTheme().textTheme;
    return GestureDetector(
      onTap: () {
        context.go('/home/0/club/${club.id}/0');
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 255, 255, 255),
                  AppTheme().getTheme().colorScheme.primary.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          const Color.fromARGB(255, 0, 0, 0), // Color del borde
                      width: 1, // Ancho del borde
                    ),
                  ),
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
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${club.nombre}", style: StyleText.titleSmall),
                      Text(
                        '${club.deporte}',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 188, 78, 78)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            child: IconButton(
              onPressed: () {
                context.go('/home/0/club/${club.id}');
              },
              icon: Icon(Icons.info_outline),
            ),
            right: 10,
            top: 0,
          )
        ],
      ),
    );
  }
}
