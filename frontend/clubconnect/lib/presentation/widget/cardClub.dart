import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Menu { eliminar, informacion }

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
            right: 10,
            top: 0,
            child: PopupMenuButton<Menu>(
              //popUpAnimationStyle: _animationStyle,
              icon: const Icon(Icons.more_vert),
              onSelected: (Menu item) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                PopupMenuItem<Menu>(
                  value: Menu.eliminar,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                    title: const Text('Abandonar Club'),
                    onTap: () async {
                      //Navigator.of(context).pop();
                      //confirmDeleteEvent(index);
                    },
                  ),
                ),
                PopupMenuItem<Menu>(
                  value: Menu.eliminar,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.black,
                    ),
                    title: const Text('Información'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      context.go('/home/0/club/${club.id}');

                      //Navigator.of(context).pop();
                      //confirmDeleteEvent(index);
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
