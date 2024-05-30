import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/presentation/views/Clubequipos.dart';
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
        context.go('/home/0/club/${club.id}/equipos');
      },
      child: Card(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(children: [
          Container(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromARGB(255, 0, 0, 0), // Color del borde
                      width: 2, // Ancho del borde
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
                        style: TextStyle(
                            color: const Color.fromARGB(255, 188, 78, 78)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
