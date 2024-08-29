import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/views/equipo_view/allEvents_view.dart';
import 'package:clubconnect/presentation/views/equipo_view/createEvent_view.dart';
import 'package:clubconnect/presentation/views/equipo_view/eventActive_view.dart';
import 'package:clubconnect/presentation/views/equipo_view/eventRecurrentes_view.dart';
import 'package:clubconnect/presentation/views/equipo_view/stadistic_view.dart';
import 'package:clubconnect/presentation/views/miembros/miembros_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Menu { eliminar, editar, terminar }

class EquipoSpecific extends ConsumerStatefulWidget {
  static const name = 'equipo';
  final int idclub;
  final int idequipo;
  final Equipo team;
  const EquipoSpecific({
    super.key,
    required this.idclub,
    required this.idequipo,
    required this.team,
  });

  @override
  EquipoSpecificState createState() => EquipoSpecificState();
}

class EquipoSpecificState extends ConsumerState<EquipoSpecific> {
  //*  --- VARIABLES GENERALES PARA TODAS LAS OPCIONES --- */
  late Future<void> _initializationFuture;
  MonthYear dateSelected = MonthYear(DateTime.now().month, DateTime.now().year,
      Months[DateTime.now().month - 1].mes);
  EventoFull? eventoSelected;

  String role = '';
  final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //* DECORATIONS */
  Color colorAsistir = const Color.fromARGB(255, 117, 204, 124);
  Color colorCancelar = const Color.fromARGB(255, 237, 65, 65);
  var decorationinput = (String htext) {
    return InputDecoration(
      hintText: htext,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
    );
  };
  //* --------------------------------------------------------

  //* ALL EVENTS */
  MonthYear selectedMonthYear = MonthYear(
    DateTime.now().month,
    DateTime.now().year,
    Months[DateTime.now().month - 1].mes,
  );

  DateTime? initfechaSeleccionada = DateTime.now();
  DateTime? endFechaSeleccionada = DateTime.now().add(const Duration(days: 30));
  List<EventoFull>? eventos = []; // Lista de eventos

  //* ACTIVE EVENTS */
  DateTime? fechaSeleccionada = DateTime.now().add(const Duration(days: 30));
  bool loading = false; // Indica si se está cargando información
  List<EventoFull>? eventosActivos = [];

  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  late List<User> miembros;

  //* EVENTOS RECURRENTES */
  List<ConfigEventos>? eventosRecurrentes = [];

  //* ESTADISTICAS EQUIPO */

  /* ------------------------------------------------------------------- */

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializationData();
  }

  Future<void> _initializationData() async {
    try {
      final eventosActivosValue = await ref
          .read(clubConnectProvider)
          .getEventos(widget.idequipo, EstadosEventos.activo, DateTime.now(),
              DateTime.now().month, DateTime.now().year);

      final roleValue = await ref
          .read(clubConnectProvider)
          .getRole(ref.read(authProvider).id!, widget.idclub, widget.idequipo);
      setState(() {
        role = roleValue;
        eventosActivos = eventosActivosValue;
      });
      if (role == "Administrador" || role == "Entrenador") {
        final miembrosValue = await ref
            .read(clubConnectProvider)
            .getMiembrosEquipo(widget.idequipo);

        final eventosValue = await ref.read(clubConnectProvider).getEventos(
            widget.idequipo,
            EstadosEventos.todos,
            DateTime.now(),
            DateTime.now().month,
            DateTime.now().year);

        final eventosRecurrentesValue = await ref
            .read(clubConnectProvider)
            .getConfigEventos(widget.idequipo);
        setState(() {
          eventosRecurrentes = eventosRecurrentesValue;
          eventosActivos = eventosActivosValue;
          role = roleValue;
          miembros = miembrosValue;
          eventos = eventosValue;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Duration duration = const Duration(hours: 1, minutes: 23);

  void updateFechas(DateTime? init, DateTime? end) {
    if (init != null) {
      initfechaSeleccionada = init;
    }
    if (end != null) {
      endFechaSeleccionada = end;
    }
  }

  void updateMonthYear(MonthYear? monthYear) {
    if (monthYear != null) {
      selectedMonthYear = monthYear;
    }
  }

  void updateFechaActivos(MonthYear? fecha) {
    if (fecha != null) {
      dateSelected = fecha;
    }
  }

  void updateEventoSelected(EventoFull? evento) {
    if (evento != null) {
      eventoSelected = evento;
    }
  }

  /* 
  * params: 
    * estado = "Activo" | "Terminado" | "Cancelado" | "Todos"
    * pullRefresh = true | false
  */
  Future<List<ConfigEventos>?> getConfigEventos() async {
    final eventosRecurrentesValue =
        await ref.read(clubConnectProvider).getConfigEventos(widget.idequipo);
    eventosRecurrentes = eventosRecurrentesValue;
    return eventosRecurrentesValue;
  }

  /* 
    * params: 
      * estado = "Activo" | "Terminado" | "Cancelado" | "Todos"
      * pullRefresh = true | false
  */
  Future<List<EventoFull>?> getEventos(String estado, bool? pullRefresh,
      DateTime initDate, int month, int year) async {
    List<EventoFull>? eventsResponse;
    if (pullRefresh != null && pullRefresh) {
      loading = true;
      //setState(() {});
    }
    if (estado == EstadosEventos.todos) {
      eventsResponse = await ref.read(clubConnectProvider).getEventos(
            widget.idequipo,
            estado,
            initDate,
            month,
            year,
          );
      eventos = eventsResponse;
    } else {
      eventsResponse = await ref
          .read(clubConnectProvider)
          .getEventos(widget.idequipo, estado, initDate, month, year);
      eventosActivos = eventsResponse;
    }
    if (estado == "updateFull") {
      eventos = await ref.read(clubConnectProvider).getEventos(
            widget.idequipo,
            EstadosEventos.todos,
            initDate,
            month,
            year,
          );
      eventosActivos = await ref.read(clubConnectProvider).getEventos(
          widget.idequipo, EstadosEventos.activo, DateTime.now(), month, year);
    }
    if (pullRefresh != null && pullRefresh) {
      loading = false;
    }
    print("EventsResponse " + eventsResponse!.length.toString());
    //setState(() {});
    return eventsResponse;
  }

  //* Obtener los miembros del equipo *//
  Future<List<User>?> getMiembros() async {
    final miembrosResponse = await ref
        .read(clubConnectProvider)
        .getMiembrosEquipo(widget
            .idequipo); // Simula un proceso de carga o actualización de datos
    miembros = miembrosResponse;
    setState(() {
      miembros = miembrosResponse;
    });
    return miembrosResponse;
  }

  Widget _getBody(value) {
    switch (value) {
      case 0:
        return EventsActives(
          equipo: widget.team,
          fechaSeleccionada: fechaSeleccionada,
          dateSelected: dateSelected,
          eventoSelected: eventoSelected,
          eventosActivos: eventosActivos,
          role: role,
          idequipo: widget.idequipo,
          indexNotifier: _indexNotifier,
          updateEventoSelectedCallback: (evento) =>
              updateEventoSelected(evento),
          updateFechaActivosCallback: (fecha) => updateFechaActivos(fecha),
          getEventosCallback: (estado, pullRefresh, initDate, month, year) =>
              getEventos(estado, pullRefresh, DateTime.now(), month, year),
        );
      case 1:
        return CreateEventWidget(
          indexNotifier: _indexNotifier,
          idequipo: widget.idequipo,
          equipo: widget.team,
          idclub: widget.idclub,
          styleText: styleText,
          getEventosCallback: (estado, pullRefresh, int month, int year) =>
              getEventos(estado, pullRefresh, DateTime.now(), month, year),
        ); /*buildCreateEvents();*/
      case 2 || 3:
        return AllEventsWidget(
            indexNotifier: _indexNotifier,
            initfechaSeleccionada: initfechaSeleccionada,
            fechaSeleccionada: endFechaSeleccionada,
            role: role,
            selectedMonthYear: selectedMonthYear,
            eventos: eventos,
            idclub: widget.idclub,
            equipo: widget.team,
            idequipo: widget.idequipo,
            miembros: miembros,
            updateMonthYear: (monthYear) => updateMonthYear(monthYear),
            updateDate: (initDateSelected, endDateSelected) =>
                updateFechas(initDateSelected, endDateSelected),
            getEventosCallback: (estado, pullRefresh, initDate, month, year) =>
                getEventos(estado, pullRefresh, initDate, month, year));
      case 4:
        return MiembrosEquipoWidget(
            idClub: int.parse(widget.idclub.toString()),
            idEquipo: int.parse(widget.idequipo.toString()),
            equipo: widget.team,
            miembros: miembros,
            getMiembros: getMiembros,
            role: role,
            indexNotifier: _indexNotifier,
            ref: ref);
      case 5:
        return EventRecurrentes(
          indexNotifier: _indexNotifier,
          idEquipo: widget.idequipo,
          equipo: widget.team,
          role: role,
          idClub: widget.idclub,
          settingEventosRecurrentes: eventosRecurrentes,
          getConfigEventos: getConfigEventos,
          /*getEventosCallback: (estado, pullRefresh, int month, int year) =>
              getEventos(estado, pullRefresh, DateTime.now(), month, year),
       */
        );
      case 6:
        return StadisticTeam(
            equipo: widget.team,
            idequipo: widget.idequipo,
            indexNotifier: _indexNotifier,
            role: role);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role != "") {
      return ValueListenableBuilder(
        valueListenable: _indexNotifier,
        builder: (BuildContext context, dynamic value, Widget? child) {
          return _getBody(value);
        },
      );
    } else {
      return FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
                appBar: AppBar(
                  centerTitle: false,
                  title: Text("Eventos", style: styleText.titleSmall),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _indexNotifier.value == 0;
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
                return ValueListenableBuilder(
                  valueListenable: _indexNotifier,
                  builder:
                      (BuildContext context, dynamic value, Widget? child) {
                    return _getBody(value);
                  },
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
