import 'dart:ui';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget.dart';
import 'package:clubconnect/presentation/widget/solicitud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class Equipos extends ConsumerStatefulWidget {
  static const name = 'club-equipo';
  final int idclub;
  const Equipos({super.key, required this.idclub});

  @override
  EquiposState createState() => EquiposState();
}

class EquiposState extends ConsumerState<Equipos> {
  final _controllerTipo = MultiSelectController();
  final tipos = [
    (id: 1, nombre: "Deportista"),
    (id: 2, nombre: "Entrenador"),
  ];
  int widgetIndex = 0;
  late Future<String?> _futurerole;
  String role = '';
  late Future<Club> _futureclub;
  late Club club;
  late Future<List<Equipo>> _futureequipos;
  late List<Equipo> equipos;
  late Future<List<Solicitud>> _futuresolicitudes;
  late List<Solicitud> solicitudes;
  late Future<List<User>> _futuremiembros;
  late List<User> miembros;

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
                    return Card(
                      child: ListTile(
                        title: Text(equipos[index].nombre),
                        trailing: Icon(Icons.arrow_forward_ios_sharp),
                        onTap: () => context.go(
                            '/home/0/club/${widget.idclub}/equipos/${equipos[index].id}'),
                      ),
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

  Widget solicitudesBuilder(_controllerEquipo) {
    return FutureBuilder(
        future: Future.wait([_futuresolicitudes, _futureequipos]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              return RefreshIndicator(
                onRefresh: () async {
                  await getSolicitud();
                },
                child: ListView.builder(
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    if (solicitudes.isEmpty) {
                      return Center(
                        child: Text("No hay solicitudes pendientes"),
                      );
                    } else {
                      print("Tamaño : ${solicitudes.length}");
                      return GestureDetector(
                        child: solicitud(solicitudes[index], context),
                        onTap: () async {
                          /*showInfoSolicitud(
                            context,
                            solicitudes[index],
                            _controllerEquipo,
                            equipos,
                            ref,
                            widget.idclub,
                            solicitudes);*/
                          final response = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    content: Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Text(
                                          "${solicitudes[index].nombre} ${solicitudes[index].apellido1} ${solicitudes[index].apellido2} ha enviado una solicitud de unión al Club el ${DateToString(solicitudes[index].fechaSolicitud) ?? ""}",
                                          style: AppTheme()
                                              .getTheme()
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                      textAlert(
                                          "Fecha de Nacimiento: ",
                                          DateToString(solicitudes[index]
                                              .fechaNacimiento)),
                                      textAlert("Genero: ",
                                          solicitudes[index].genero),
                                      textAlert(
                                          "Correo: ", solicitudes[index].email),
                                      textAlert("Teléfono: ",
                                          solicitudes[index].telefono),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.86,
                                        child: MultiSelectDropDown<dynamic>(
                                          hint: "Selecciona las categorías",
                                          inputDecoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black54,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          //showClearIcon: true,
                                          controller: _controllerEquipo,
                                          onOptionSelected: (options) {
                                            //debugPrint(options.toString());
                                          },
                                          options: equipos
                                              .map((Equipo item) => ValueItem(
                                                  label: item.nombre.toString(),
                                                  value: item.id.toString()))
                                              .toList(),
                                          selectionType: SelectionType.multi,
                                          chipConfig: const ChipConfig(
                                              wrapType: WrapType.scroll),
                                          dropdownHeight: 300,
                                          optionTextStyle:
                                              const TextStyle(fontSize: 16),
                                          selectedOptionIcon:
                                              const Icon(Icons.check_circle),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.86,
                                        child: MultiSelectDropDown(
                                          hint: "Selecciona el rol",
                                          inputDecoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black54,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          //showClearIcon: true,
                                          controller: _controllerTipo,
                                          onOptionSelected: (options) {
                                            //debugPrint(options.toString());
                                          },
                                          options: tipos
                                              .map((item) => ValueItem(
                                                    label: item.nombre,
                                                    value: item.id,
                                                  ))
                                              .toList(),

                                          selectionType: SelectionType.single,
                                          chipConfig: const ChipConfig(
                                              wrapType: WrapType.scroll),
                                          dropdownHeight: tipos.length * 50.0,
                                          optionTextStyle:
                                              const TextStyle(fontSize: 16),
                                          selectedOptionIcon:
                                              const Icon(Icons.check_circle),
                                        ),
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FilledButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.green)),
                                              onPressed: () async {
                                                if (_controllerEquipo
                                                        .selectedOptions
                                                        .isEmpty ||
                                                    _controllerTipo
                                                        .selectedOptions
                                                        .isEmpty) {
                                                  print(
                                                      "No se ha seleccionado un equipo o un rol");
                                                } else {
                                                  final response = await ref
                                                      .read(clubConnectProvider)
                                                      .acceptSolicitud(
                                                          _controllerEquipo
                                                              .selectedOptions
                                                              .map((e) =>
                                                                  e.value)
                                                              .toList(),
                                                          int.parse(
                                                              solicitudes[index]
                                                                  .id),
                                                          _controllerTipo
                                                              .selectedOptions[
                                                                  0]
                                                              .label,
                                                          widget.idclub);
                                                  if (response == true) {
                                                    solicitudes = solicitudes
                                                        .where((element) =>
                                                            element.id !=
                                                            solicitudes[index]
                                                                .id)
                                                        .toList();
                                                    //setState(() {});
                                                    return Navigator.of(context)
                                                        .pop(true);
                                                  }
                                                }
                                                // Acción cuando se presiona el botón
                                              },
                                              child: Text('Aceptar',
                                                  style: AppTheme()
                                                      .getTheme()
                                                      .textTheme
                                                      .bodyMedium),
                                            ),
                                            FilledButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        const Color.fromARGB(
                                                            255, 204, 78, 69)),
                                              ),
                                              onPressed: () async {
                                                await ref
                                                    .read(clubConnectProvider)
                                                    .updateSolicitud(
                                                        int.parse(
                                                            solicitudes[index]
                                                                .id),
                                                        widget.idclub,
                                                        "Cancelada");
                                                Navigator.of(context).pop();

                                                // Acción cuando se presiona el botón
                                              },
                                              child: Text('Rechazar',
                                                  style: AppTheme()
                                                      .getTheme()
                                                      .textTheme
                                                      .bodyMedium),
                                            ),
                                          ]),
                                    ]),
                                  );
                                }),
                              );
                            },
                          );
                          print("Resp ${response}");
                          if (response == true) {
                            print("Se aceptó la solicitud");
                            setState(() {});
                          }
                          // Acción cuando se presiona el ListTile
                        },
                      );
                    }
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

  Widget miembrosBuilder() {
    return FutureBuilder(
      future: _futuremiembros,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            print(" miembros: " + miembros.toString());
            return RefreshIndicator(
              onRefresh: () async {
                await getMiembros();
              },
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Número de columnas
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height /
                            2), // Proporción de aspecto,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 3),
                itemCount: miembros.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        miembros[index].imagen == "" ||
                                miembros[index].imagen == null
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
                                  imagenFromBase64(club.logo),
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "${miembros[index].nombre} ${miembros[index].apellido1} ${miembros[index].apellido2}",
                            style: AppTheme().getTheme().textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.active:
            return Text('active');
        }
      },
    );
  }

  List<String> items = List.generate(20, (index) => 'Item $index');

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

  Future<void> getSolicitud() async {
    final response = await ref.read(clubConnectProvider).getSolicitudes(
        widget.idclub); // Simula un proceso de carga o actualización de datos
    setState(() {
      solicitudes = response;
    });
  }

  Future<void> getMiembros() async {
    final response = await ref.read(clubConnectProvider).getMiembros(
        widget.idclub); // Simula un proceso de carga o actualización de datos
    print("Miembros : ${response.map((e) => e.nombre)}");

    setState(() {
      miembros = response;
    });
  }

  @override
  void initState() {
    print("Entre...");
    _futurerole = ref
        .read(clubConnectProvider)
        .getRole(ref.read(authProvider).id!, widget.idclub)
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
    _futureclub = ref
        .read(clubConnectProvider)
        .getClub(widget.idclub)
        .then((value) => club = value.club);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widgetIndex == 0
        ? 'Equipos'
        : widgetIndex == 1
            ? 'Miembros'
            : widgetIndex == 2
                ? 'Solicitudes'
                : 'Información del Club';
    final controllername = TextEditingController();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final MultiSelectController controllerEquipo = MultiSelectController();

    final styleText = AppTheme().getTheme().textTheme;
    final pages = <Widget>[
      //EquiposBuilder(),
      Text('Page 2'),
      Text('Page 3'),
    ];

    /*if (role.isEmpty) {
      return CircularProgressIndicator();
    }*/

    return FutureBuilder(
      future: Future.wait<dynamic?>([_futurerole, _futureclub]),
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
                    GoRouter.of(context).go('/home/0');
                  },
                ),
                actions: role == "Administrador"
                    ? <Widget>[
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                      ]
                    : null,
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error');
            } else {
              return Scaffold(
                key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
                appBar: AppBar(
                  title: widgetIndex == 0
                      ? const Text('Equipos')
                      : widgetIndex == 1
                          ? const Text('Miembros')
                          : widgetIndex == 2
                              ? const Text('Solicitudes')
                              : const Text('Información del Club'),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      GoRouter.of(context).go('/home/0');
                    },
                  ),
                  actions: role == "Administrador"
                      ? <Widget>[
                          IconButton(
                            icon: Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                        ]
                      : null,
                ),
                drawer: role == "Administrador"
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
                                  club.logo == "" || club.logo == null
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      club.nombre,
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
                              title: Text('Crear Equipo',
                                  style: styleText.bodyMedium),
                              onTap: () {
                                _scaffoldKey.currentState!.closeDrawer();
                                _showCreateTeamModal(
                                    context,
                                    controllername,
                                    (value) => emptyOrNull(value, "nombre"),
                                    addEquipo);

                                // Acción cuando se presiona la opción 1 del Drawer
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.list),
                              title: Text(
                                'Todos los equipos',
                                style: styleText.bodyMedium,
                              ),
                              onTap: () {
                                setState(() {
                                  widgetIndex = 0;
                                });
                                // Acción cuando se presiona la opción 2 del Drawer
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.groups_3),
                              title: Text(
                                'Todos los Miembros',
                                style: styleText.bodyMedium,
                              ),
                              onTap: () {
                                setState(() {
                                  widgetIndex = 1;
                                });
                                // Acción cuando se presiona la opción 2 del Drawer
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.notification_add),
                              title: Text('Solicitudes',
                                  style: AppTheme()
                                      .getTheme()
                                      .textTheme
                                      .bodyMedium),
                              onTap: () {
                                setState(() {
                                  widgetIndex = 2;
                                });
                                // Acción cuando se presiona la opción 2 del Drawer
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.info),
                              title: Text(
                                'Información del Club',
                                style: styleText.bodyMedium,
                              ),
                              onTap: () {
                                // Acción cuando se presiona la opción 2 del Drawer
                              },
                            ),
                            // Agrega más ListTile según sea necesario
                          ],
                        ),
                      )
                    : null,
                body: widgetIndex == 0
                    ? equiposBuilder()
                    : widgetIndex == 1
                        ? miembrosBuilder()
                        : solicitudesBuilder(controllerEquipo),
              );
              //pages[widgetIndex],
            }
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.active:
            return Text('active');
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

void showInfoSolicitud(
    BuildContext context,
    Solicitud solicitud,
    MultiSelectController _controllerEquipo,
    List<Equipo> equipos,
    WidgetRef ref,
    int idClub,
    List<Solicitud> solicitudes) {
  final _controllerTipo = MultiSelectController();
  final tipos = [
    (id: 1, nombre: "Deportista"),
    (id: 2, nombre: "Entrenador"),
  ];
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
