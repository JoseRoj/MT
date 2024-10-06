import 'package:clubconnect/config/router/app_router.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/drawerEquipo.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:clubconnect/presentation/widget/modalDelete.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../insfrastructure/models.dart';

class EventRecurrentes extends ConsumerStatefulWidget {
  final Equipo equipo;
  final int idClub;
  final String role;
  List<ConfigEventos>? settingEventosRecurrentes;
  final Future<List<ConfigEventos>?> Function() getConfigEventos;

  EventRecurrentes({
    super.key,
    required this.equipo,
    required this.role,
    required this.idClub,
    this.settingEventosRecurrentes,
    required this.getConfigEventos,
  });

  @override
  EventRecurrentesState createState() => EventRecurrentesState();
}

class EventRecurrentesState extends ConsumerState<EventRecurrentes> {
  ThemeData theme = AppTheme().getTheme();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final keyForm = GlobalKey<FormState>();
  final TextEditingController controllerDescriptionEdit =
      TextEditingController();
  final TextEditingController controllerTitleEdit = TextEditingController();
  final TextEditingController controllerLugarEdit = TextEditingController();
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  String? selectedDay;
  DateTime? dateInitial;
  DateTime? dateEnd;
  final styleText = AppTheme().getTheme().textTheme;

  @override
  void initState() {
    super.initState();
  }

  void clearValues() {
    dateEnd = null;
    dateInitial = null;
    horaFin = null;
    horaInicio = null;
    selectedDay = null;
    controllerDescriptionEdit.clear();
    controllerTitleEdit.clear();
    controllerLugarEdit.clear();
  }

  Future<void> deleteConfiguracion(String? id) async {
    await ref.watch(clubConnectProvider).deleteConfigEvento(int.parse(id!));
    widget.settingEventosRecurrentes = await widget.getConfigEventos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("Settigns : ${widget.settingEventosRecurrentes}");
    return Scaffold(
      key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eventos Recurrentes',
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
              context.go(
                  '/home/0/club/${widget.idClub}/0/${widget.equipo.id}/0',
                  extra: {'team': widget.equipo});
            }),
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
      body: widget.settingEventosRecurrentes!.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 100, color: Colors.grey),
                  Text("No hay eventos recurrentes",
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget.settingEventosRecurrentes!.length,
              itemBuilder: (BuildContext context, int index) {
                return cardEventoRecurrente(
                    widget.settingEventosRecurrentes![index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await modalRecurrentEvent("CREATE", null);
          print("Result : $result");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget cardEventoRecurrente(ConfigEventos? evento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 20,
                alignment: Alignment.center,
                child: TextButton.icon(
                    onPressed: () async {
                      controllerDescriptionEdit.text = evento!.descripcion;
                      controllerTitleEdit.text = evento.titulo;
                      controllerLugarEdit.text = evento.lugar;
                      dateInitial = evento.fechaInicio;
                      dateEnd = evento.fechaFinal;
                      horaInicio = TimeOfDay(
                          hour: int.parse(evento.horaInicio.split(":")[0]),
                          minute: int.parse(evento.horaInicio.split(":")[1]));
                      horaFin = TimeOfDay(
                          hour: int.parse(evento.horaFinal.split(":")[0]),
                          minute: int.parse(evento.horaFinal.split(":")[1]));
                      selectedDay = evento.diaRepetible == 0
                          ? daysOfWeek[6]
                          : daysOfWeek[evento.diaRepetible - 1];

                      final result =
                          await modalRecurrentEvent("UPDATE", evento.id);
                      clearValues();
                    },
                    label: const Text("Editar",
                        style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 128, 115, 0))),
                    icon: const Icon(Icons.edit,
                        size: 13, color: Color.fromARGB(255, 128, 115, 0))),
              ),
              Container(
                alignment: Alignment.center,
                height: 20,
                child: TextButton.icon(
                    onPressed: () async {
                      final response = await modalDelete(context,
                          "¿Desea eliminar esta configuración, se eliminarán todos los eventos que aún están activos?");
                      response == true
                          ? await deleteConfiguracion(evento!.id)
                          : null;
                    },
                    label: const Text("Eliminar",
                        style: TextStyle(fontSize: 13, color: Colors.red)),
                    icon: const Icon(
                      Icons.delete_forever,
                      size: 13,
                      color: Colors.red,
                    )),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.surfaceContainerLow
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  evento!.titulo,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  evento.descripcion,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                evento.diaRepetible != 0
                    ? Text("Día : ${daysOfWeek[evento.diaRepetible - 1]}")
                    : Text("Día : ${daysOfWeek[6]}"),
                Text("Horario : ${evento.horaInicio} - ${evento.horaFinal}"),
                Text("Lugar : ${evento.lugar}"),
                Text(
                    "Desde : ${DateFormat('dd/MM/yyyy').format(evento.fechaInicio)}  - Hasta ${DateFormat('dd/MM/yyyy').format(evento.fechaFinal)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> modalRecurrentEvent(String type, String? idConfig) async {
    var decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color.fromARGB(255, 165, 165, 165)),
    );
    bool? result = await showModalBottomSheet<bool>(
      context: context,

      // Esto permite que el modal se expanda según su contenido

      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: keyForm,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type == "CREATE"
                            ? "Crear Evento Recurrente"
                            : "Editar Evento Recurrente",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      formInput(
                        label: "Titulo",
                        controller: controllerTitleEdit,
                        validator: (value) => emptyOrNull(value, "descripción"),
                      ),
                      formInput(
                          label: "Descripción",
                          controller: controllerDescriptionEdit,
                          validator: (value) =>
                              emptyOrNull(value, "descripción")),
                      const Text(
                        "Fecha Inicio & Término",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.40,
                            child: ElevatedButton.icon(
                              label: Text(
                                  dateInitial != null
                                      ? DateFormat('dd / MM / yyyy')
                                          .format(dateInitial!)
                                      : "",
                                  style: const TextStyle(fontSize: 12)),
                              icon: const Icon(
                                Icons.calendar_today,
                                size: 10,
                              ),
                              onPressed: () async {
                                if (dateInitial == null) {
                                  setModalState(() {
                                    dateInitial = DateTime.now();
                                  });
                                }
                                await showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    height: 300,
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.date,
                                      backgroundColor: Colors.white,
                                      initialDateTime:
                                          dateInitial ?? DateTime.now(),
                                      onDateTimeChanged: (DateTime value) {
                                        dateInitial =
                                            DateTime.parse(value.toString());
                                        setModalState(() {
                                          dateInitial = dateInitial;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          //* Fecha Final
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.40,
                            child: ElevatedButton.icon(
                              label: Text(
                                  dateEnd != null
                                      ? DateFormat('dd / MM / yyyy')
                                          .format(dateEnd!)
                                      : "",
                                  style: const TextStyle(fontSize: 12)),
                              icon: const Icon(
                                Icons.calendar_today,
                                size: 10,
                              ),
                              onPressed: () async {
                                if (dateEnd == null) {
                                  if (dateInitial != null) {
                                    dateEnd = dateInitial;
                                  }
                                  setModalState(() {});
                                }

                                await showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    height: 300,
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.date,
                                      backgroundColor: Colors.white,
                                      initialDateTime:
                                          dateEnd ?? DateTime.now(),
                                      onDateTimeChanged: (DateTime value) {
                                        dateEnd =
                                            DateTime.parse(value.toString());
                                        setModalState(() {
                                          dateEnd = dateEnd;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        "Horario Inicio & Término",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ElevatedButton.icon(
                                label: Text(
                                    horaInicio != null
                                        ? horaInicio!.format(context)
                                        : "",
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center),
                                icon: const Icon(Icons.access_time, size: 12),
                                onPressed: () async {
                                  if (horaInicio == null) {
                                    setModalState(() {
                                      horaInicio = TimeOfDay.now();
                                    });
                                  }
                                  await showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      height: 150,
                                      child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.time,
                                          use24hFormat: true,
                                          initialDateTime: horaInicio != null
                                              ? dateTimeWithHourSpecific(
                                                  horaInicio!)
                                              : DateTime.now(),
                                          onDateTimeChanged:
                                              (DateTime newDateTime) {
                                            horaInicio = TimeOfDay.fromDateTime(
                                                newDateTime);
                                            setModalState(() {
                                              horaInicio = horaInicio;
                                            });
                                            /*setState(() {
                                    _horaFin = TimeOfDay.fromDateTime(newDateTime)
                                        .format(context);
                                    print(_horaFin);*/
                                          }),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ElevatedButton.icon(
                                label: Text(
                                    horaFin != null
                                        ? horaFin!.format(context)
                                        : "",
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center),
                                icon: const Icon(Icons.access_time, size: 12),
                                onPressed: () async {
                                  if (horaFin == null) {
                                    setModalState(() {
                                      horaFin = TimeOfDay.now();
                                    });
                                  }
                                  await showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      height: 150,
                                      child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.time,
                                          use24hFormat: true,
                                          initialDateTime: horaFin != null
                                              ? dateTimeWithHourSpecific(
                                                  horaFin!)
                                              : DateTime.now(),
                                          onDateTimeChanged:
                                              (DateTime newDateTime) {
                                            horaFin = TimeOfDay.fromDateTime(
                                                newDateTime);
                                            setModalState(() {
                                              horaFin = horaFin;
                                            });
                                            /*setState(() {
                                    _horaFin = TimeOfDay.fromDateTime(newDateTime)
                                        .format(context);
                                    print(_horaFin);*/
                                          }),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ]),
                      formInput(
                        label: "Lugar",
                        controller: controllerLugarEdit,
                        validator: (value) => emptyOrNull(value, "lugar"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Repetir Cada"),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: decoration,
                            child: DropdownButton<String>(
                              hint: selectedDay == null
                                  ? const Text("")
                                  : Text(
                                      selectedDay!,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                              value: selectedDay,
                              onChanged: (String? newValue) {
                                setModalState(() {
                                  selectedDay = newValue;
                                });
                              },
                              items: daysOfWeek.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              dropdownColor: Colors
                                  .white, // Cambia el color de fondo del menú desplegable
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors
                                      .black), // Cambia el icono y su color
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      16), // Cambia el estilo del texto seleccionado
                              underline: Container(
                                height: 0,
                                color: Colors
                                    .transparent, // Cambia el color de la línea inferior
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            if (keyForm.currentState!.validate()) {
                              if (dateEnd == null || dateInitial == null) {
                                customToast(
                                    "Debes seleccionar una fecha de inicio y término",
                                    context,
                                    "isError");

                                return;
                              }
                              if (dateEnd!.isBefore(dateInitial!)) {
                                customToast(
                                    "La fecha de término no puede ser menor a la inicial",
                                    context,
                                    "isError");
                                return;
                              }
                              ConfigEventos configEvento = ConfigEventos(
                                fechaInicio: dateInitial!,
                                fechaFinal: dateEnd!,
                                horaInicio: horaInicio!.format(context),
                                horaFinal: horaFin!.format(context),
                                idEquipo: widget.equipo.id!,
                                descripcion: controllerDescriptionEdit.text,
                                lugar: controllerLugarEdit.text,
                                diaRepetible:
                                    daysOfWeek.indexOf(selectedDay!) == 6
                                        ? 0
                                        : daysOfWeek.indexOf(selectedDay!) + 1,
                                titulo: controllerTitleEdit.text,
                              );

                              var response;

                              if (type == "CREATE") {
                                response = await ref
                                    .watch(clubConnectProvider)
                                    .createConfigEvento(configEvento);
                              } else {
                                configEvento.id = idConfig;
                                response = await ref
                                    .watch(clubConnectProvider)
                                    .editConfigEvento(configEvento);
                              }

                              print(response);
                              if (response.statusCode == 201 ||
                                  response.statusCode == 200) {
                                clearValues();
                                customToast(response.data["message"].toString(),
                                    context, "isSuccess");
                                widget.settingEventosRecurrentes =
                                    await widget.getConfigEventos();
                                setState(() {});

                                Navigator.pop(context, true);
                              } else {
                                customToast(response["data"].message, context,
                                    "isError");
                              }
                              setModalState(() {
                                dateEnd = dateEnd;
                                dateInitial = dateInitial;
                              });
                            }
                          },
                          label: Text(
                              type == "CREATE"
                                  ? "Guardar Evento Concurrente"
                                  : "Editar Evento Concurrente",
                              style: TextStyle(fontSize: 12)),
                          icon: const Icon(Icons.save, size: 12))
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    return null;
  }
}
