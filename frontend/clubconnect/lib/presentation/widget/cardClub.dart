import 'package:clubconnect/config/theme/app_theme.dart';
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
                  child: ClipOval(
                    child: Image(
                      image: AssetImage('assets/miembros.png'),
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${club.nombre}", style: StyleText.titleSmall),
                      Text(
                        'Voleibol',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 188, 78, 78)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => context.go("/home/0/club/${club.id}"),
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Color.fromARGB(255, 41, 98, 28).withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage("assets/actividad.png"),
                        ),
                        Text('  3', style: StyleText.labelSmall)
                      ],
                    )),
              ))
        ]),
      ),
    );
  }
}
