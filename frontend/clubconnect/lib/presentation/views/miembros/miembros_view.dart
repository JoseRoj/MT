import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/views/equiposClub/modalUserPerfil.dart';
import 'package:clubconnect/presentation/views/miembros/miembroStadistic_view.dart';
import 'package:clubconnect/presentation/widget/drawerEquipo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MiembrosEquipoWidget extends ConsumerStatefulWidget {
  final int idClub;
  final Equipo equipo;
  final List<User> miembros;
  final String role;
  final Future<List<User>?> Function() getMiembros;

  MiembrosEquipoWidget({
    super.key,
    required this.miembros,
    required this.equipo,
    required this.role,
    required this.getMiembros,
    required this.idClub,
  });

  @override
  MiembrosEquipoWidgetState createState() => MiembrosEquipoWidgetState();
}

class MiembrosEquipoWidgetState extends ConsumerState<MiembrosEquipoWidget> {
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
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Miembros',
                style: styleText.titleSmall, textAlign: TextAlign.center),
            Text(
              widget.equipo.nombre,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            )
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home/0/club/${widget.idClub}/0/${widget.equipo.id}/0',
                extra: {'team': widget.equipo});
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
          ? CustomDrawer(
              equipo: widget.equipo,
              scaffoldKey: _scaffoldKey,
              idClub: widget.idClub,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          print("Refresh");
          miembros = await widget.getMiembros();
        },
        child: miembros!.isEmpty
            ? Center(
                child: ListView(
                  children: const [
                    SizedBox(
                      height: 50,
                    ),
                    Icon(Icons.group, size: 100, color: Colors.grey),
                    Center(
                      child: Text("No hay miembros",
                          style: TextStyle(fontSize: 20, color: Colors.grey)),
                    ),
                  ],
                ),
              )
            : Padding(
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
                            '/home/0/club/${widget.idClub}/0/${widget.equipo.id}/3/${miembros![index].id}',
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
                                          imagenFromBase64(
                                              miembros![index].imagen),
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                        ),
                                      ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    "${miembros![index].nombre} ${miembros![index].apellido1} ${miembros![index].apellido2}",
                                    style: AppTheme()
                                        .getTheme()
                                        .textTheme
                                        .labelMedium,
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
