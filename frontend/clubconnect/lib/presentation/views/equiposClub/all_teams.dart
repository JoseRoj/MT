import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../insfrastructure/models.dart';

class AllTeamsWidget extends ConsumerStatefulWidget {
  final int idclub;
  final Future<List<Equipo>> futureequipos;
  final List<Equipo> equipos;
  const AllTeamsWidget({
    Key? key,
    required this.idclub,
    required this.equipos,
    required this.futureequipos,
  });
  @override
  AllTeamsWidgetState createState() => AllTeamsWidgetState();
}

class AllTeamsWidgetState extends ConsumerState<AllTeamsWidget> {
  late Future<List<Equipo>> _futureequipos;
  late List<Equipo> equipos;
  @override
  void initState() {
    _futureequipos = widget.futureequipos;
    equipos = widget.equipos;
    super.initState();
  }

  ThemeData theme = AppTheme().getTheme();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipos', style: theme.textTheme.titleSmall),
      ),
      body: FutureBuilder(
        future: _futureequipos,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              return RefreshIndicator(
                onRefresh: () async {},
                child: ListView.builder(
                  itemCount: equipos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(equipos[index].nombre),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {});
                  },
                ),
              );
            case ConnectionState.none:
              return const Text('none');
            case ConnectionState.active:
              return const Text('active');
          }
        },
      ),
    );
  }
}
