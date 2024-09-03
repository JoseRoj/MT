import 'package:clubconnect/insfrastructure/models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  final Equipo equipo;
  final int idClub;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomDrawer({
    Key? key,
    required this.equipo,
    required this.idClub,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    equipo.nombre,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          _buildListTile(
            context: context,
            icon: Icons.calendar_today,
            title: 'Eventos Activos',
            index: 0,
          ),
          _buildListTile(
            context: context,
            icon: Icons.calendar_today,
            title: 'Crear Evento',
            index: 1,
          ),
          _buildListTile(
            context: context,
            icon: Icons.list_alt,
            title: 'Todos los Eventos',
            index: 2,
          ),
          _buildListTile(
            context: context,
            icon: Icons.group,
            title: 'Miembros',
            index: 3,
          ),
          _buildListTile(
            context: context,
            icon: Icons.event_repeat_rounded,
            title: 'Config Eventos Recurrentes',
            index: 4,
          ),
          _buildListTile(
            context: context,
            icon: Icons.stacked_line_chart,
            title: 'Estadísticas',
            index: 5,
          ),
          // Agrega más ListTile según sea necesario
        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        //context.go('/home/0/club/${idClub}/0/${equipo.id}/1');
        //print("id" + idClub.toString());

        context.go('/home/0/club/$idClub/0/${equipo.id}/$index',
            extra: {'team': equipo});

        //context.go('/home/0/club/$idClub/0/${equipo.id!}/0/0');

        scaffoldKey.currentState!.closeDrawer();
      },
    );
  }
}
