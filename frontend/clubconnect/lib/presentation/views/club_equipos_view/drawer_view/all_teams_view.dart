import 'package:clubconnect/insfrastructure/models/equipo.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Teams extends ConsumerStatefulWidget {
  final int idclub;
  final List<Equipo> equipos;
  final String role;
  const Teams({
    super.key,
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

  Future<void> getEquipos() async {
    List<Equipo> response = [];
    if (widget.role == "Administrador") {
      response = await ref.read(clubConnectProvider).getEquipos(widget.idclub);
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
        await getEquipos();
      },
      child: ListView.builder(
        itemCount: equipos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(equipos[index].nombre),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => {
              context.go('/home/0/club/${widget.idclub}/0/${equipos[index].id}',
                  extra: {'team': equipos[index]}),
            },
          );
        },
      ),
    );
  }
}
