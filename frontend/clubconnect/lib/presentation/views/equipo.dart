import 'dart:math';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/widget/Cardevento.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:clubconnect/presentation/widget/modalDelete.dart';
import 'package:clubconnect/presentation/widget/userlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers.dart';

class Equipo extends ConsumerStatefulWidget {
  static const name = 'equipo';
  final int idclub;
  final int idequipo;
  const Equipo({
    super.key,
    required this.idclub,
    required this.idequipo,
  });

  @override
  EquipoState createState() => EquipoState();
}

class EquipoState extends ConsumerState<Equipo> {
  var buttonText = "";
  Color colorAsistir = const Color.fromARGB(255, 117, 204, 124);
  Color colorCancelar = Color.fromARGB(255, 237, 65, 65);

  int indexWidget = 0;
  bool selectTimeInicio = false;
  bool selectTimeFin = false;
  TimeOfDay _selectedTimeInicio = TimeOfDay.now();
  TimeOfDay _selectedTimeFin = TimeOfDay.now();
  final controllerName = TextEditingController();
  final controllerLugar = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final controllerDes = TextEditingController();

  var decorationinput = (String htext) {
    return InputDecoration(
      hintText: htext,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      contentPadding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
    );
  };
  List<DateTime?> _dates = [];
  late Future<String?> _futurerole;
  String role = '';
  late Future<List<Evento>?> _futureEventos;
  List<EventoFull>? eventos = [];
  final styleText = AppTheme().getTheme().textTheme;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool?> _showDialog(Widget child) async {
    final response = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The bottom margin is provided to align the popup above the system
          // navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
          child: child),
    );
    return response;
  }

  @override
  void initState() {
    super.initState();
    _futureEventos = ref
        .read(clubConnectProvider)
        .getEventos(widget.idequipo, EstadosEventos.activo)
        .then((value) {
      value != null ? eventos = value : eventos = null;
    });
    _futurerole = ref
        .read(clubConnectProvider)
        .getRole(ref.read(authProvider).id!, widget.idclub)
        .then((value) {
      role = value;
      if (value == "Administrador") {}
    });
  }

  Duration duration = const Duration(hours: 1, minutes: 23);
  Future<void> getEventos(String estado) async {
    eventos =
        await ref.read(clubConnectProvider).getEventos(widget.idequipo, estado);
    setState(() {});
  }

  Widget buildCreateEvents() {
    return Column(
      children: [
        CalendarDatePicker2(
          config: CalendarDatePicker2Config(
            calendarType: CalendarDatePicker2Type.multi,
          ),
          value: _dates,
          onValueChanged: (dates) => {
            _dates = dates,
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      "Hora Inicio  ",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          textStyle: MaterialStateProperty.all(const TextStyle(
                              color: Colors.white, fontSize: 16)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          )),
                      onPressed: () async {
                        final response = await _showDialog(CupertinoDatePicker(
                          use24hFormat: false,
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: selectTimeFin
                              ? DateTime(2021, 1, 1, _selectedTimeInicio.hour,
                                  _selectedTimeInicio.minute)
                              : DateTime.now(),
                          onDateTimeChanged: (DateTime newDateTime) {
                            _selectedTimeInicio =
                                TimeOfDay.fromDateTime(newDateTime);
                            selectTimeInicio = true;
                          },
                        ));
                        print("Response: $response");
                        response == null
                            ? {
                                setState(() {}),
                                //setState(() {
                                //selectTimeInicio = true;
                                //})
                              }
                            : {};
                      },
                      child: selectTimeInicio
                          ? Text(_selectedTimeInicio.format(context))
                          : const Text("Hora"),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text("Hora Fin", textAlign: TextAlign.center),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          textStyle: MaterialStateProperty.all(const TextStyle(
                              color: Colors.white, fontSize: 16)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          )),
                      onPressed: () async {
                        final response = await _showDialog(CupertinoDatePicker(
                          use24hFormat: true,
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: selectTimeFin
                              ? DateTime(2021, 1, 1, _selectedTimeFin.hour,
                                  _selectedTimeFin.minute)
                              : DateTime.now(),
                          onDateTimeChanged: (DateTime newDateTime) {
                            _selectedTimeFin =
                                TimeOfDay.fromDateTime(newDateTime);
                            selectTimeFin = true;
                          },
                        ));
                        print("Response: $response");
                        response == null
                            ? {
                                setState(() {}),
                                //setState(() {
                                //selectTime = true;
                                //})
                              }
                            : {};
                      },
                      child: selectTimeFin
                          ? Text("${_selectedTimeFin.format(context)}"
                              // "${_selectedTimeFin.hour}:${_selectedTimeFin.minute < 10 ? "0${_selectedTimeFin.minute}" : "${_selectedTimeFin.minute}"} ${_selectedTimeFin.period == DayPeriod.am ? "AM" : "PM"}"
                              )
                          : const Text("Hora"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                formInput(
                    label: "Nombre Evento",
                    controller: controllerName,
                    validator: (value) => emptyOrNull(value, "nombre")),
                formInput(
                    label: "Descripción del evento",
                    controller: controllerDes,
                    maxLines: 3,
                    validator: (value) => emptyOrNull(value, "descripción")),
                formInput(
                    label: "Lugar Evento",
                    controller: controllerLugar,
                    validator: (value) => emptyOrNull(value, "lugar")),
              ],
            ),
          ),
        ),
        ElevatedButton.icon(
          label: Text("Crear Evento", style: styleText.labelMedium),
          icon: const Icon(Icons.add),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (_dates.isEmpty) {
                customToast("Seleccione una fecha", context, "isError");
                return;
              }
              if (!selectTimeInicio || !selectTimeFin) {
                customToast("Seleccione una hora", context, "isError");
                return;
              }
              final fechas = _dates.map((e) => e!.toIso8601String()).toList();

              final response = await ref.read(clubConnectProvider).createEvento(
                  fechas,
                  _selectedTimeInicio.format(context),
                  controllerDes.text,
                  _selectedTimeFin.format(context),
                  widget.idequipo,
                  controllerName.text);
              print("Response: $response");
              customToast("Evento Registrado con éxito", context, "isSuccess");
              eventos = await ref
                  .read(clubConnectProvider)
                  .getEventos(widget.idequipo, EstadosEventos.activo);

              indexWidget = 0;
              setState(() {});
              return;
            }
          },
        ),
      ],
    );
  }

  Widget builderEvents() {
    return FutureBuilder(
        future: _futureEventos,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Ha ocurrido un error al cargar los eventos'));
              } else {
                return RefreshIndicator(
                    onRefresh: () async {
                      await getEventos(EstadosEventos.activo);
                    },
                    child: CardEvento(
                        eventos: eventos,
                        buttonText: buttonText,
                        idequipo: widget.idequipo));
              }

            case ConnectionState.none:
              return const Text('none');
            case ConnectionState.active:
              return const Text('active');
          }
        });
  }

  Widget builderAllEvents() {
    return FutureBuilder(
        future: _futureEventos,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Ha ocurrido un error al cargar los eventos'),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    await getEventos(EstadosEventos.todos);
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: eventos!.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 35),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white, // Background color
                                  borderRadius: BorderRadius.circular(
                                      20), // Rounded corners
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26, // Shadow color
                                      blurRadius: 10, // Blur radius
                                      offset: Offset(0, 4), // Shadow position
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey, // Border color
                                    width: 1, // Border width
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                                eventos![index].evento.titulo,
                                                style: styleText.titleSmall,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  DateFormat('dd / MM / yyyy')
                                                      .format(eventos![index]
                                                          .evento
                                                          .fecha),
                                                  style: styleText.labelSmall),
                                              const SizedBox(width: 10),
                                              Icon(
                                                Icons.circle,
                                                size: 15,
                                                color: eventos![index]
                                                            .evento
                                                            .estado
                                                            .toLowerCase() ==
                                                        "activo"
                                                    ? colorAsistir
                                                    : colorCancelar,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                  eventos![index].evento.estado,
                                                  style: styleText.labelSmall),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                            Positioned(
                              top: 0,
                              right: 10,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: const Text(
                                            '¿Está seguro que desea eliminar el evento?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              //  TODO: ELIMINAR DE LA BASE DE DATOS
                                              eventos?.removeAt(index);
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Eliminar',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromARGB(255, 161, 161, 41)),
                                  onPressed: () {}),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }
            case ConnectionState.none:
              return const Text('none');
            case ConnectionState.active:
              return const Text('active');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if (role != "") {
      return Scaffold(
        key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
        appBar: AppBar(
          title: indexWidget == 0
              ? const Text("Eventos")
              : indexWidget == 1
                  ? const Text("Crear Evento")
                  : const Text("Todos los Eventos"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (indexWidget == 0) {
                context.pop();
              } else {
                indexWidget = 0;
                setState(() {});
              }
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
                      title:
                          Text('Eventos Activos', style: styleText.bodyMedium),
                      onTap: () {
                        setState(() {
                          indexWidget = 0;
                        });
                        _scaffoldKey.currentState!.closeDrawer();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('Crear Evento', style: styleText.bodyMedium),
                      onTap: () {
                        setState(() {
                          indexWidget = 1;
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
                          indexWidget = 2;
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
                        // Acción cuando se presiona la opción 2 del Drawer
                      },
                    ),
                    // Agrega más ListTile según sea necesario
                  ],
                ),
              )
            : null,
        body: indexWidget == 0
            ? builderEvents()
            : indexWidget == 1
                ? buildCreateEvents()
                : builderAllEvents(),
      );
    } else {
      return FutureBuilder(
        future: Future.wait<dynamic?>([_futurerole]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
                appBar: AppBar(
                  title: const Text("Eventos"),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      indexWidget == 0;
                      setState(() {});
                    },
                  ),
                  actions: role == "Administrador" || role == "Entrenador"
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
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Text('Error');
              } else {
                return Scaffold(
                  key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
                  appBar: AppBar(
                    title: indexWidget == 0
                        ? const Text("Eventos")
                        : indexWidget == 1
                            ? const Text("Crear Evento")
                            : const Text("Todos los Eventos"),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (indexWidget == 0) {
                          context.pop();
                        } else {
                          indexWidget = 0;
                          setState(() {});
                        }
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
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
                                title: Text('Eventos Activos',
                                    style: styleText.bodyMedium),
                                onTap: () {
                                  setState(() {
                                    indexWidget = 0;
                                  });
                                  _scaffoldKey.currentState!.closeDrawer();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: Text('Crear Evento',
                                    style: styleText.bodyMedium),
                                onTap: () {
                                  setState(() {
                                    indexWidget = 1;
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
                                    indexWidget = 2;
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
                                  // Acción cuando se presiona la opción 2 del Drawer
                                },
                              ),
                              // Agrega más ListTile según sea necesario
                            ],
                          ),
                        )
                      : null,
                  body: indexWidget == 0
                      ? builderEvents()
                      : indexWidget == 1
                          ? buildCreateEvents()
                          : builderAllEvents(),
                );
              }
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
