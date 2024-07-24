import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/modalUserPerfil.dart';
import 'package:clubconnect/presentation/views/miembros/miembroStadistic_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MiembrosEquipoWidget extends StatefulWidget {
  final int idClub;
  final Equipo equipo;
  final int idEquipo;
  final List<User> miembros;
  final String role;
  final Future<List<User>?> Function() getMiembros;
  final WidgetRef ref;
  ValueNotifier<int> indexNotifier;

  MiembrosEquipoWidget(
      {super.key,
      required this.miembros,
      required this.equipo,
      required this.role,
      required this.getMiembros,
      required this.indexNotifier,
      required this.ref,
      required this.idClub,
      required this.idEquipo});

  @override
  State<MiembrosEquipoWidget> createState() => _MiembrosEquipoWidgetState();
}

Widget body(value) {
  switch (value) {
    case 0:
      return Container();
    case 1:
      return Center();
    default:
      return Container();
  }
}

class _MiembrosEquipoWidgetState extends State<MiembrosEquipoWidget> {
  final styleText = AppTheme().getTheme().textTheme;
  late final Future<List<User>> _futuremiembros;
  List<User>? miembros = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    print("initState + ${miembros}");
    miembros = widget.miembros;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
      appBar: AppBar(
        title: const Text('Miembros'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.indexNotifier.value = 0;
          },
        ),
        actions: widget.role == "Administrador" || widget.role == "Entrenador"
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState!.openDrawer();
                  },
                ),
              ]
            : null,
      ),
      drawer: widget.role == "Administrador" || widget.role == "Entrenador"
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Equipo dsfsd",
                            style: styleText.titleSmall,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Eventos Activos', style: styleText.bodyMedium),
                    onTap: () {
                      setState(() {
                        widget.indexNotifier.value = 0;
                      });
                      _scaffoldKey.currentState!.closeDrawer();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Crear Evento', style: styleText.bodyMedium),
                    onTap: () {
                      setState(() {
                        widget.indexNotifier.value = 1;
                      });
                      _scaffoldKey.currentState!.closeDrawer();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: Text(
                      'Todos los Eventos',
                      style: styleText.bodyMedium,
                    ),
                    onTap: () {
                      setState(() {
                        widget.indexNotifier.value = 2;
                      });
                      _scaffoldKey.currentState!
                          .closeDrawer(); // Acción cuando se presiona la opción 2 del Drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(
                      'Miembros',
                      style: styleText.bodyMedium,
                    ),
                    onTap: () {
                      setState(() {
                        widget.indexNotifier.value = 4;
                      });
                      _scaffoldKey.currentState!
                          .closeDrawer(); // Acción cuando se presiona la opción 2 del Drawer
                    },
                  ),
                  // Agrega más ListTile según sea necesario
                ],
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          miembros = await widget.getMiembros();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Número de columnas
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height /
                        2), // Proporción de aspecto,
                mainAxisSpacing: 2,
                crossAxisSpacing: 3),
            itemCount: miembros!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  context.go(
                      '/home/0/club/${widget.idClub}/0/${widget.idEquipo}/${miembros![index].id}',
                      extra: {
                        'team': widget.equipo,
                        'usuario': miembros![index]
                      });
                },
                child: Stack(
                  children: [
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          miembros![index].imagen == "" ||
                                  miembros![index].imagen == null
                              ? ClipOval(
                                  child: Image.asset(
                                    'assets/nofoto.jpeg',
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              : ClipOval(
                                  child: Image.memory(
                                    imagenFromBase64(miembros![index].imagen),
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${miembros![index].nombre} ${miembros![index].apellido1} ${miembros![index].apellido2}",
                              style:
                                  AppTheme().getTheme().textTheme.labelMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
