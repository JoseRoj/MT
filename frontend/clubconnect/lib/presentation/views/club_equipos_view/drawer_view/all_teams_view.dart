import 'package:clubconnect/insfrastructure/models/equipo.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/modalDelete.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Teams extends ConsumerStatefulWidget {
  final int idclub;
  final List<Equipo> equipos;
  final String role;
  final Future<List<Equipo>> Function() getEquipos;
  const Teams({
    super.key,
    required this.getEquipos,
    required this.idclub,
    required this.equipos,
    required this.role,
  });

  @override
  TeamsState createState() => TeamsState();
}

class TeamsState extends ConsumerState<Teams> {
  late List<Equipo> equipos;

  @override
  void initState() {
    super.initState();
    equipos = widget.equipos;
  }

  Future<void> getEquiposs() async {
    List<Equipo> response = [];
    if (widget.role == "Administrador") {
      response = await widget.getEquipos();
    } else {
      response = await ref
          .read(clubConnectProvider)
          .getEquiposUser(ref.read(authProvider).id!, widget.idclub);
    }
    setState(() {
      equipos = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getEquiposs();
      },
      child: ListView.builder(
        itemCount: equipos.length,
        itemBuilder: (context, index) {
          return widget.role == "Administrador" || widget.role == "Entrenador"
              ? Dismissible(
                  key: Key(equipos[index].id.toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    // Mostrar una acción de confirmación en lugar de eliminar
                    bool confirm = await modalDelete(
                        context, "¿Desea eliminar el equipo?");
                    return confirm; // Retorna true si se debe eliminar, false para cancelar
                  },
                  onDismissed: (direction) async {
                    final response = await ref
                        .read(clubConnectProvider)
                        .deleteEquipo(int.parse(equipos[index].id!));
                    setState(() {
                      response == true ? equipos.removeAt(index) : null;
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    title: Text(equipos[index].nombre),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => {
                      context.go(
                          '/home/0/club/${widget.idclub}/0/${equipos[index].id}',
                          extra: {'team': equipos[index]}),
                    },
                  ),
                )
              : ListTile(
                  title: Text(equipos[index].nombre),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => {
                    context.go(
                        '/home/0/club/${widget.idclub}/0/${equipos[index].id}',
                        extra: {'team': equipos[index]}),
                  },
                );
        },
      ),
    );
  }
}
