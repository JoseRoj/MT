/*import 'dart:typed_data';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/userTeam.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/drawer_view/all_miembros_view.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/drawer_view/informacion_club_view.dart';
import 'package:clubconnect/presentation/views/club_equipos_view/drawer_view/solicitudes_view.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../widget/modalCarga.dart';

class Equipos extends ConsumerStatefulWidget {
  static const name = 'club-equipo';
  final int idclub;
  const Equipos({super.key, required this.idclub});

  @override
  EquiposState createState() => EquiposState();
}

enum Menu { eliminar, perfil }

class EquiposState extends ConsumerState<Equipos> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MultiSelectController controllerEquipo = MultiSelectController();
  final styleText = AppTheme().getTheme().textTheme;
  final controllername = TextEditingController();

  final _controllerTipo = MultiSelectController();
  final tipos = [
    (id: 1, nombre: "Deportista"),
    (id: 2, nombre: "Entrenador"),
  ];
  final ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);
  late Future<String?> _futurerole;
  String role = '';
  late Future<ClubEspecifico> _futureclub;
  late ClubEspecifico? club;

  late Future<List<Equipo>> _futureequipos;
  late List<Equipo> equipos;

  late Future<List<Solicitud>> _futuresolicitudes;
  late List<Solicitud> solicitudes;

  late Future<List<UserTeam>> _futuremiembros;
  late List<UserTeam> miembros;

  // * --- * INFORMACION CLUB * --- * //
  Set<Marker> markers = {};
  Uint8List? logoClub;

  Future<ClubEspecifico> fetchClub() async {
    final clubData = await ref.read(clubConnectProvider).getClub(widget.idclub);
    logoClub = imagenFromBase64(clubData.club.logo);
    return clubData;
  }

  @override
  void initState() {
    _futurerole = ref
        .read(clubConnectProvider)
        .getRole(ref.read(authProvider).id!, widget.idclub, null)
        .then(
      (value) {
        role = value;
        if (value == "Administrador") {
          _futureequipos = ref
              .read(clubConnectProvider)
              .getEquipos(widget.idclub)
              .then((value) => equipos = value);
          _futuresolicitudes = ref
              .read(clubConnectProvider)
              .getSolicitudes(widget.idclub)
              .then((value) => solicitudes = value);
          _futuremiembros = ref
              .read(clubConnectProvider)
              .getMiembros(widget.idclub)
              .then((value) => miembros = value);
        } else {
          _futureequipos = ref
              .read(clubConnectProvider)
              .getEquiposUser(ref.read(authProvider).id!, widget.idclub)
              .then((value) => equipos = value);
        }
      },
    );
    _futureclub = fetchClub().then((value) => club = value);

    super.initState();
  }

  Future<bool> _expulsarmiembro(int idmiembro, int idclub, int index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return modalCarga("Expulsando Miembro del Club...");
      },
    );
    var result = await ref
        .read(clubConnectProvider)
        .deleteMiembroClub(idmiembro, idclub);
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (result) {
      miembros.removeAt(index);
      setState(() {});
      customToast("Se ha explusado del club", context, "isSuccess");
    } else {
      customToast("Error al eliminar del club", context, "isError");
    }
    return result;
  }

  Widget equiposBuilder() {
    return FutureBuilder(
        future: _futureequipos,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              return RefreshIndicator(
                onRefresh: () async {
                  await getEquipos();
                },
                child: ListView.builder(
                  itemCount: equipos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(equipos[index].nombre),
                      trailing: Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => context.go(
                          '/home/0/club/${widget.idclub}/equipos/${equipos[index].id}'),
                    );
                  },
                ),
              );
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.active:
              return Text('active');
          }
        });
  }

  Future<void> getEquipos() async {
    final response = await ref.read(clubConnectProvider).getEquipos(
        widget.idclub); // Simula un proceso de carga o actualización de datos
    setState(() {
      equipos = response;
    });
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
        //equipos.add(equipo);
      });
      return true;
    }
    // Simula un proceso de carga o actualización de datos
  }

  Future<List<Solicitud>> getSolicitud() async {
    final response = await ref.read(clubConnectProvider).getSolicitudes(
        widget.idclub); // Simula un proceso de carga o actualización de datos
    setState(() {
      solicitudes = response;
    });
    return response;
  }

  Future<List<UserTeam>> getMiembros() async {
    final response = await ref.read(clubConnectProvider).getMiembros(
        widget.idclub); // Simula un proceso de carga o actualización de datos
    miembros = response;
    return response;
  }

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
                logoClub == "" || logoClub == null
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
            leading: Icon(Icons.group_add),
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
              setState(() {
                indexNotifier.value = 0;
              });
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
              setState(() {
                indexNotifier.value = 1;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.notification_add),
            title: Text('Solicitudes',
                style: AppTheme().getTheme().textTheme.bodyMedium),
            onTap: () {
              _scaffoldKey.currentState!.closeDrawer();
              setState(() {
                indexNotifier.value = 2;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              'Información del Club',
              style: styleText.bodyMedium,
            ),
            onTap: () {
              _scaffoldKey.currentState!.closeDrawer();
              setState(() {
                /*markers.add(Marker(
                  markerId: MarkerId('1'),
                  position: locationSelected ?? LatLng(0, 0),
                ));*/
                indexNotifier.value = 3;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _getBody(value) {
    switch (value) {
      case 0:
        return equiposBuilder();
      case 1:
        return AllMiembrosWidget(
          idclub: widget.idclub,
          club: club!.club,
          miembros: miembros,
          futuremiembros: _futuremiembros,
          equipos: equipos,
          futurerole: _futurerole,
          role: role,
          indexNotifier: indexNotifier,
          expulsarmiembro: _expulsarmiembro,
          getmiembrosCallBack: () => getMiembros(),
        );
      case 2:
        return SolicitudesWidget(
            idclub: widget.idclub,
            futuresolicitudes: _futuresolicitudes,
            solicitudes: solicitudes,
            equipos: equipos,
            futureequipos: _futureequipos,
            solicitudesCallBack: () => getSolicitud());
      case 3:
        return InformacionClubWidget(futureclub: _futureclub, club: club);
      default:
        return equiposBuilder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = indexNotifier.value == 0
        ? 'Equipos'
        : indexNotifier.value == 1
            ? 'Miembros'
            : indexNotifier.value == 2
                ? 'Solicitudes'
                : 'Información del Club';

    final pages = <Widget>[
      //EquiposBuilder(),
      Text('Page 2'),
      Text('Page 3'),
    ];

    /*if (role.isEmpty) {
      return CircularProgressIndicator();
    }*/
    if (role != "") {
      return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                indexNotifier.value == 0
                    ? context.go('/home/0')
                    : setState(() {
                        indexNotifier.value = 0;
                      });
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
            title: Text(title),
          ),
          drawer: drawer(),
          body: ValueListenableBuilder(
              valueListenable: indexNotifier,
              builder: (BuildContext context, int value, Widget? child) =>
                  _getBody(value)));
    } else {
      return FutureBuilder(
        future: Future.wait<dynamic>([_futurerole, _futureclub]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
                appBar: AppBar(
                  title: Text(title),
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
                key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
                appBar: AppBar(
                  title: Text(title),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      indexNotifier.value == 0
                          ? context.go('/home/0')
                          : setState(
                              () {
                                indexNotifier.value = 0;
                              },
                            );
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                    ),
                  ],
                ),
                drawer: drawer(),
                body: ValueListenableBuilder(
                  valueListenable: indexNotifier,
                  builder: (context, int value, Widget? child) {
                    return _getBody(value);
                  },
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                  print("name" + controllername.text);
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
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      Text(value),
    ],
  );
}
*/