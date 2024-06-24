import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/views/clubEquipos/modalUserPerfil.dart';
import 'package:clubconnect/presentation/widget/Cardevento.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:clubconnect/presentation/widget/modalCarga.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers.dart';

enum Menu { eliminar, editar, terminar }

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
  Color colorCancelar = const Color.fromARGB(255, 237, 65, 65);

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
  bool deleting = false;
  late Future<String?> _futurerole;
  String role = '';
  late Future<List<Evento>?> _futureEventos;
  List<EventoFull>? eventos = [];
  final styleText = AppTheme().getTheme().textTheme;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //* VARIABLES PARA EDITAR EVENTO */
  int? eventId = 0;
  late DateTime fechaEdit;
  late TimeOfDay horaInicio;
  late TimeOfDay horaFin;
  late String tituloEdit;
  final TextEditingController controllerDescriptionEdit =
      TextEditingController();
  final TextEditingController controllerTitleEdit = TextEditingController();
  final TextEditingController controllerLugarEdit = TextEditingController();
  late List<Asistente> asistentes;
  List<int> asistentesId = [];
  late Future<List<User>> _futuremiembros;
  late List<User> miembros;

  Future<bool?> _showDialog(Widget child) async {
    final response = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: child),
    );
    return response;
  }

  Future<bool?> _showDialogDelete(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('¿Está seguro que desea eliminar el evento?'),
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
                Navigator.of(context).pop(); // Cierra el primer diálogo
                await _deleteEvent(
                    index); // Asume que 0 es el índice del evento a eliminar
              },
              child: const Text('Eliminar',
                  style: TextStyle(fontSize: 20, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(int index) async {
    // Muestra el diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return modalCarga("Elimimando Evento... ");
      },
    );
    // Realiza la operación asíncrona
    var result = await ref
        .read(clubConnectProvider)
        .deleteEvento(int.parse(eventos![index].evento.id!));
    // Cierra el diálogo de carga solo si está activo
    // ignore: use_build_context_synchronously
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();
    }
    // Actualiza el estado y maneja el resultado
    if (result) {
      setState(() {
        eventos?.removeAt(index);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    //TODO: OBTENER EL EQUIPO
    _futureEventos = ref
        .read(clubConnectProvider)
        .getEventos(widget.idequipo, EstadosEventos.activo)
        .then((value) {
      value != null ? eventos = value : eventos = null;
    });
    _futurerole = ref
        .read(clubConnectProvider)
        .getRole(ref.read(authProvider).id!, widget.idclub, widget.idequipo)
        .then((value) {
      role = value;
      print("Role: $value");
      if (role == "Administrador" || role == "Entrenador") {
        _futuremiembros = ref
            .read(clubConnectProvider)
            .getMiembrosEquipo(widget.idequipo)
            .then((value) => miembros = value);
      }
    });
  }

  Duration duration = const Duration(hours: 1, minutes: 23);
  Future<void> getEventos(String estado) async {
    eventos =
        await ref.read(clubConnectProvider).getEventos(widget.idequipo, estado);
    setState(() {});
  }

  Future<void> getMiembros() async {
    final response = await ref.read(clubConnectProvider).getMiembrosEquipo(
        widget.idequipo); // Simula un proceso de carga o actualización de datos
    setState(() {
      miembros = response;
    });
  }

  Widget buildCreateEvents() {
    return SingleChildScrollView(
      child: Column(
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      child: FilledButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            )),
                        onPressed: () async {
                          final response =
                              await _showDialog(CupertinoDatePicker(
                            use24hFormat: true,
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
                      child:
                          const Text("Hora Fin", textAlign: TextAlign.center),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      child: FilledButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            )),
                        onPressed: () async {
                          final response =
                              await _showDialog(CupertinoDatePicker(
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

                final response = await ref
                    .read(clubConnectProvider)
                    .createEvento(
                        fechas,
                        _selectedTimeInicio.format(context),
                        controllerDes.text,
                        _selectedTimeFin.format(context),
                        widget.idequipo,
                        widget.idclub,
                        controllerName.text,
                        controllerLugar.text);
                print("Response: $response");
                customToast(
                    "Evento Registrado con éxito", context, "isSuccess");
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
      ),
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
    asistentesId = [];
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
                        return Stack(children: [
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 35),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                borderRadius: BorderRadius.circular(
                                    20), // Rounded corners
                                boxShadow: const [
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
                                            Text(eventos![index].evento.estado,
                                                style: styleText.labelSmall),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          Positioned(
                              top: 20,
                              right: 0,
                              child: PopupMenuButton<Menu>(
                                //popUpAnimationStyle: _animationStyle,
                                icon: const Icon(Icons.more_vert),
                                onSelected: (Menu item) {},
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<Menu>>[
                                  PopupMenuItem<Menu>(
                                    value: Menu.eliminar,
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      title: const Text('Eliminar'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _showDialogDelete(index);
                                      },
                                    ),
                                  ),
                                  PopupMenuItem<Menu>(
                                    value: Menu.editar,
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(Icons.edit,
                                          color: Colors.yellow),
                                      title: Text('Editar'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        indexWidget = 3;
                                        setState(() {
                                          eventId = int.parse(eventos![index]
                                              .evento
                                              .id!); // eventos![index].evento.id;
                                          fechaEdit =
                                              eventos![index].evento.fecha;
                                          horaInicio =
                                              convertirStringATimeOfDay(
                                                  eventos![index]
                                                      .evento
                                                      .horaInicio);
                                          horaFin = convertirStringATimeOfDay(
                                              eventos![index].evento.horaFinal);
                                          tituloEdit =
                                              eventos![index].evento.titulo;
                                          controllerDescriptionEdit.text =
                                              eventos![index]
                                                  .evento
                                                  .descripcion;
                                          controllerTitleEdit.text =
                                              eventos![index].evento.titulo;
                                          controllerLugarEdit.text =
                                              eventos![index].evento.lugar;
                                          asistentes = eventos![index]
                                              .asistentes
                                              .map((e) => e)
                                              .toList();
                                        });
                                      },
                                    ),
                                  ),
                                  PopupMenuItem<Menu>(
                                    value: Menu.terminar,
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(Icons.done),
                                      title: eventos![index].evento.estado ==
                                              EstadosEventos.activo
                                          ? Text('Terminar')
                                          : Text('Activar'),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        final response = await ref
                                            .read(clubConnectProvider)
                                            .updateEstadoEvento(
                                                int.parse(
                                                    eventos![index].evento.id!),
                                                eventos![index].evento.estado ==
                                                        EstadosEventos.activo
                                                    ? EstadosEventos.terminado
                                                    : EstadosEventos.activo);
                                        if (response) {
                                          if (eventos![index].evento.estado ==
                                              EstadosEventos.activo) {
                                            eventos![index].evento.estado =
                                                EstadosEventos.terminado;
                                            customToast("Evento terminado",
                                                context, "isSuccess");
                                          } else {
                                            eventos![index].evento.estado =
                                                EstadosEventos.activo;
                                            customToast("Evento Activado",
                                                context, "isSuccess");
                                          }

                                          setState(() {});
                                        } else {
                                          customToast(
                                              "Error al finalizar el evento",
                                              context,
                                              "isError");
                                        }
                                      },
                                    ),
                                  ),

                                  /*IconButton(
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
                                              Navigator.of(context)
                                                  .pop(); // Cierra el primer diálogo
                                              await _deleteEvent(
                                                  index); // Asume que 0 es el índice del evento a eliminar
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
                            */

                                  /*Positioned(
                              bottom: 10,
                              right: 10,
                              child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromARGB(255, 161, 161, 41)),
                                  onPressed: () {
                                    indexWidget = 3;
                                    setState(() {
                                      eventId = int.parse(eventos![index]
                                          .evento
                                          .id!); // eventos![index].evento.id;
                                      fechaEdit = eventos![index].evento.fecha;
                                      horaInicio = convertirStringATimeOfDay(
                                          eventos![index].evento.horaInicio);
                                      horaFin = convertirStringATimeOfDay(
                                          eventos![index].evento.horaFinal);
                                      tituloEdit =
                                          eventos![index].evento.titulo;
                                      controllerDescriptionEdit.text =
                                          eventos![index].evento.descripcion;
                                      controllerTitleEdit.text =
                                          eventos![index].evento.titulo;
                                      controllerLugarEdit.text =
                                          eventos![index].evento.lugar;
                                      asistentes = eventos![index]
                                          .asistentes
                                          .map((e) => e)
                                          .toList();
                                    });
                                  }),
                            ),
                          */
                                ],
                              ))
                        ]);
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

  Widget builderEditEvent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            formInput(
                label: "Titulo",
                controller: controllerTitleEdit,
                validator: (value) => emptyOrNull(value, "titulo")),
            Text(DateFormat('dd / MM / yyyy').format(fechaEdit),
                style: styleText.bodyMedium),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: ElevatedButton.icon(
                label: Text("Cambiar Fecha", style: styleText.labelMedium),
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final response = await _showDialog(
                    CupertinoDatePicker(
                      backgroundColor: Colors.white,
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: fechaEdit,
                      onDateTimeChanged: (DateTime newDateTime) {
                        fechaEdit = newDateTime;
                      },
                    ),
                  );
                  response == null ? setState(() {}) : {};
                },
              ),
            ),
            Text(
                "${horaInicio.hour}:${horaInicio.minute}:00 - ${horaFin.hour}:${horaFin.minute}:00",
                style: styleText.bodyMedium),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton.icon(
                  label: Text("Cambiar Hora Inicio",
                      style: styleText.labelMedium,
                      textAlign: TextAlign.center),
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final response = await _showDialog(CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: DateTime(
                        2021,
                        1,
                        1,
                        horaInicio.hour,
                        horaInicio.minute,
                      ),
                      onDateTimeChanged: (DateTime newDateTime) {
                        horaInicio = TimeOfDay.fromDateTime(newDateTime);
                      },
                    ));
                    response == null ? setState(() {}) : {};
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton.icon(
                    label: Text("Cambiar Hora Final",
                        style: styleText.labelMedium,
                        textAlign: TextAlign.center),
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final response = await _showDialog(
                        CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: true,
                          initialDateTime: DateTime(
                            2021,
                            1,
                            1,
                            horaFin.hour,
                            horaFin.minute,
                          ),
                          onDateTimeChanged: (DateTime newDateTime) {
                            horaFin = TimeOfDay.fromDateTime(newDateTime);
                          },
                        ),
                      );
                      response == null ? setState(() {}) : {};
                    }),
              ),
            ]),
            formInput(
                label: "Lugar",
                controller: controllerLugarEdit,
                validator: (value) => emptyOrNull(value, "lugar")),
            formInput(
                label: "Descripción",
                maxLines: 5,
                controller: controllerDescriptionEdit,
                validator: (value) => emptyOrNull(value, "descripción")),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: asistentes.length,
                itemBuilder: (context, index) {
                  return Container(
                      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 40),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.yellow,
                      ),
                      child: ClipRect(
                          child: Dismissible(
                        key: Key(asistentes[index].id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            //    asistentes.removeAt(index);
                            asistentesId.add(int.parse(asistentes[index].id));
                            asistentes.removeAt(index);
                          });
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: CircleAvatar(
                              foregroundColor: Colors.white,
                            ),
                          ),
                          Text(
                            asistentes[index].nombre + " ",
                            //   asistentes[index].apellido1,
                            style: styleText.labelMedium,
                          ),
                        ]),
                      )));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: ElevatedButton(
                  onPressed: () async {
                    final response = await ref
                        .read(clubConnectProvider)
                        .editEvento(
                            fechaEdit.toIso8601String(),
                            horaInicio.format(context),
                            controllerDescriptionEdit.text,
                            horaFin.format(context),
                            eventId!,
                            controllerTitleEdit.text,
                            controllerLugarEdit.text,
                            asistentesId);

                    if (response == true) {
                      eventos = await ref
                          .read(clubConnectProvider)
                          .getEventos(widget.idequipo, EstadosEventos.todos);
                      indexWidget = 2;
                      // ignore: use_build_context_synchronously
                      customToast(
                          "Evento Editado con éxito", context, "isSuccess");
                      setState(() {});
                    } else {
                      // ignore: use_build_context_synchronously
                      customToast(
                          "Error al editar el evento", context, "isError");
                    }
                    //print("XXX ${asistentesId.map((e) => e).toList()}");

                    /* print("XXX Fecha: $fechaEdit");
                    print("XXX Hora Inicio: $horaInicio");
                    print("XXX Hora Fin: $horaFin");
                    print("XXX Titulo: ${controllerTitleEdit.text}");
                    print("XXX Descripción: ${controllerDescriptionEdit.text}");
                    print("XXX Asistentes: ${asistentes.length}");*/
                  },
                  child: Text("Guardar Cambios", style: styleText.labelMedium)),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMiembros() {
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
                  itemCount: miembros.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        modalUserPerfil(
                            context, miembros[index], null, null, ref);
                      },
                      child: Stack(
                        children: [
                          Card(
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
                                          imagenFromBase64(
                                              miembros[index].imagen),
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
                                    "${miembros[index].nombre} ${miembros[index].apellido1} ${miembros[index].apellido2}",
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
            );
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.active:
            return Text('active');
        }
      },
    );
  }

  Widget _getBody() {
    switch (indexWidget) {
      case 0:
        _futureEventos = ref
            .read(clubConnectProvider)
            .getEventos(widget.idequipo, EstadosEventos.activo)
            .then((value) {
          value != null ? eventos = value : eventos = null;
        });
        return builderEvents();
      case 1:
        return buildCreateEvents();
      case 2:

        /*_futureEventos = ref
            .read(clubConnectProvider)
            .getEventos(widget.idequipo, EstadosEventos.todos)
            .then((value) {
          value != null ? eventos = value : eventos = null;
        });*/
        return builderAllEvents();
      case 3:
        return builderEditEvent();
      case 4:
        return buildMiembros();
      default:
        return builderEvents();
    }
  }

  Widget _getTitle() {
    switch (indexWidget) {
      case 0:
        return const Text("Eventos");
      case 1:
        return const Text("Crear Evento");
      case 2:
        return const Text("Todos los Eventos");
      case 3:
        return const Text("Editar Evento");
      case 4:
        return const Text("Miembros");
      default:
        return const Text("Eventos");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role != "") {
      return Scaffold(
        key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
        appBar: AppBar(
          title: _getTitle(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (indexWidget == 0) {
                context.pop();
              } else {
                if (indexWidget == 3) {
                  indexWidget = 2;
                  setState(() {});
                } else {
                  indexWidget = 0;
                  setState(() {});
                }
              }
            },
          ),
          actions: (role == "Administrador" || role == "Entrenador") &&
                  (indexWidget == 0 || indexWidget == 2)
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
        drawer: (role == "Administrador" || role == "Entrenador") &&
                indexWidget != 1
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
                        setState(() {
                          indexWidget = 4;
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
        body: _getBody(),
      );
    } else {
      return FutureBuilder(
        future: _futurerole,
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
                      title: _getTitle(),
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
                    drawer: role == "Administrador" || role == "Entrenador"
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
                                          "Equipo ds",
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
                                    setState(() {
                                      indexWidget = 4;
                                    });
                                    _scaffoldKey.currentState!
                                        .closeDrawer(); // Acción cuando se presiona la opción 2 del Drawer
                                  },
                                ),
                              ],
                            ),
                          )
                        : null,
                    body: _getBody());
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
