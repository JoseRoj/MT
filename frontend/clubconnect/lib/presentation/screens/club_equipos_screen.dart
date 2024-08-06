import 'dart:typed_data';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/userTeam.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/drawer_view/all_miembros_view.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/drawer_view/all_teams_view.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/drawer_view/informacion_club_view.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/drawer_view/solicitudes_view.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClubEquipos extends ConsumerStatefulWidget {
  static const name = 'club-equipo';
  final int idclub;
  final int pageIndex;
  const ClubEquipos({super.key, required this.idclub, required this.pageIndex});

  @override
  ClubEquiposState createState() => ClubEquiposState();
}

enum Menu { eliminar, perfil }

class ClubEquiposState extends ConsumerState<ClubEquipos> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final styleText = AppTheme().getTheme().textTheme;
  final controllername = TextEditingController();
  String role = '';
  late ClubEspecifico? club;
  late List<Equipo> equipos;
  late List<Solicitud> solicitudes;
  late List<UserTeam> miembros;

  // * --- * INFORMACION CLUB * --- * //
  Set<Marker> markers = {};
  Uint8List? logoClub;
  late Future<void> _initializationFuture;

  Future<ClubEspecifico> fetchClub() async {
    final clubData = await ref.read(clubConnectProvider).getClub(widget.idclub);
    logoClub = imagenFromBase64(clubData.club.logo);
    return clubData;
  }

  var viewRoutes = <Widget>[];
  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  //* Inicializacion principal **/
  Future<void> _initializeData() async {
    try {
      final roleValue = await ref
          .read(clubConnectProvider)
          .getRole(ref.read(authProvider).id!, widget.idclub, null);
      final clubValue = await fetchClub();
      setState(() {
        club = clubValue;
        role = roleValue;
      });
      if (roleValue == "Administrador") {
        final equiposValue =
            await ref.read(clubConnectProvider).getEquipos(widget.idclub);
        final solicitudesValue =
            await ref.read(clubConnectProvider).getSolicitudes(widget.idclub);
        final miembrosValue =
            await ref.read(clubConnectProvider).getMiembros(widget.idclub);
        setState(() {
          equipos = equiposValue;
          solicitudes = solicitudesValue;
          miembros = miembrosValue;
          viewRoutes = [
            Teams(
              idclub: widget.idclub,
              equipos: equipos,
              role: roleValue,
            ),
            AllMiembrosWidget(
              idclub: widget.idclub,
              club: club!.club,
              miembros: miembros,
              equipos: equipos,
            ),
            SolicitudesWidget(
              idclub: widget.idclub,
              solicitudes: solicitudes,
              equipos: equipos,
            ),
            InformacionClubWidget(club: club)
            //FavoritesView(),
          ];
        });
      } else {
        final equiposValue = await ref
            .read(clubConnectProvider)
            .getEquiposUser(ref.read(authProvider).id!, widget.idclub);

        setState(() {
          equipos = equiposValue;
          viewRoutes = [
            Teams(
              idclub: widget.idclub,
              equipos: equipos,
              role: roleValue,
            ),
            Container(),
          ];
        });
      }
    } catch (error) {
      // Maneja el error si ocurre
      print("Error: $error");
    }
  }

  Future<bool> addEquipo(String name) async {
    Equipo equipo = Equipo(nombre: name, idClub: widget.idclub.toString());
    final response = await ref.read(clubConnectProvider).addEquipo(equipo);
    final responseEquipo = await ref.read(clubConnectProvider).getEquipos(
        widget.idclub); // Simula un proceso de carga o actualización de datos
    equipos = responseEquipo;
    if (response == false) {
      return false;
    } else {
      setState(() {
        equipos.add(equipo);
      });
      return true;
    }
    // Simula un proceso de carga o actualización de datos
  }

  void updateClub() async {
    club = await fetchClub();
  }

  //* DRAWER
  Widget? drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: [
                club!.club.logo == "" || club!.club.logo == null
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
                          logoClub!,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                      ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    club!.club.nombre,
                    style: styleText.titleSmall,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: Text('Crear Equipo', style: styleText.bodyMedium),
            onTap: () {
              _scaffoldKey.currentState!.closeDrawer();
              _showCreateTeamModal(context, controllername,
                  (value) => emptyOrNull(value, "nombre"), addEquipo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text(
              'Todos los equipos',
              style: styleText.bodyMedium,
            ),
            onTap: () {
              _scaffoldKey.currentState!.closeDrawer();
              context.go('/home/0/club/${widget.idclub}/0');
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups_3),
            title: Text(
              'Todos los Miembros',
              style: styleText.bodyMedium,
            ),
            onTap: () {
              _scaffoldKey.currentState!.closeDrawer();
              context.go('/home/0/club/${widget.idclub}/1');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: Text('Solicitudes',
                style: AppTheme().getTheme().textTheme.bodyMedium),
            onTap: () {
              _scaffoldKey.currentState!.closeDrawer();
              context.go('/home/0/club/${widget.idclub}/2');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              'Información del Club',
              style: styleText.bodyMedium,
            ),
            onTap: () {
              _scaffoldKey.currentState!.closeDrawer();
              context.go('/home/0/club/${widget.idclub}/3');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.pageIndex == 0
        ? 'Equipos'
        : widget.pageIndex == 1
            ? 'Miembros'
            : widget.pageIndex == 2
                ? 'Solicitudes'
                : 'Información del Club';

    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(title,
                    style: AppTheme().getTheme().textTheme.titleSmall),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          case ConnectionState.done:
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                centerTitle: false,
                title: Text(title,
                    style: AppTheme().getTheme().textTheme.titleSmall),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    widget.pageIndex == 0
                        ? context.go('/home/0')
                        : context.go('/home/0/club/${widget.idclub}/0');
                  },
                ),
                actions: role == "Administrador"
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
              drawer: drawer(),
              body: IndexedStack(
                index: widget.pageIndex,
                children: viewRoutes,
              ),
            );

          case ConnectionState.none:
            return const Text('none');
          case ConnectionState.active:
            return const Text('active');
        }
      },
    );
  }
}

void _showCreateTeamModal(
    BuildContext context,
    TextEditingController controllername,
    String? Function(String?) validator,
    Future<bool> Function(String) addEquipo) {
  final appTheme = AppTheme().getTheme();
  final keyForm = GlobalKey<FormState>();
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Crear Equipo',
              style: appTheme.textTheme.bodyLarge,
            ),
            Form(
              key: keyForm,
              child: formInput(
                  label: "Nombre",
                  controller: controllername,
                  validator: validator),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyForm.currentState!.validate()) {
                  addEquipo(controllername
                      .text); // Acción cuando se presiona el botón
                  Navigator.pop(context);
                }
                // Acción cuando se presiona el botón
              },
              child: Text('Crear', style: appTheme.textTheme.bodyMedium),
            ),
          ],
        ),
      );
    },
  );
}

Widget textAlert(String label, String value) {
  return Row(
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      Text(value),
    ],
  );
}
