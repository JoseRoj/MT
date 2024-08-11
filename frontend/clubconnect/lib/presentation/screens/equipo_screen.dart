import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/views/equipo_view/allEvents_view.dart';
import 'package:clubconnect/presentation/views/equipo_view/createEvent_view.dart';
import 'package:clubconnect/presentation/views/equipo_view/eventActive_view.dart';
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
  DateTime? initfechaSeleccionada = DateTime.now();
  DateTime? endFechaSeleccionada = DateTime.now().add(const Duration(days: 30));
  List<EventoFull>? eventos = []; // Lista de eventos

  //* ACTIVE EVENTS */
  DateTime? fechaSeleccionada = DateTime.now().add(const Duration(days: 30));
  bool loading = false; // Indica si se está cargando información
  List<EventoFull>? eventosActivos = [];

  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  late List<User> miembros;

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
              fechaSeleccionada!);

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
            fechaSeleccionada!);
        print("Eventos: ${eventosValue!.length}");
        setState(() {
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

  void updateFechaActivos(DateTime? fecha) {
    if (fecha != null) {
      fechaSeleccionada = fecha;
    }
  }

  /* 
    * params: 
      * estado = "Activo" | "Terminado" | "Cancelado" | "Todos"
      * pullRefresh = true | false
  */
  Future<List<EventoFull>?> getEventos(String estado, bool? pullRefresh,
      DateTime initDate, DateTime endDate) async {
    print("Refresh 2");

    List<EventoFull>? eventsResponse;
    if (pullRefresh != null && pullRefresh) {
      loading = true;
      //setState(() {});
    }
    estado == EstadosEventos.todos
        ? (
            eventsResponse = await ref.read(clubConnectProvider).getEventos(
                  widget.idequipo,
                  estado,
                  initDate,
                  endDate,
                ),
            eventos = eventsResponse
          )
        : (
            eventsResponse = await ref
                .read(clubConnectProvider)
                .getEventos(widget.idequipo, estado, initDate, endDate),
            eventosActivos = eventsResponse
          );
    if (estado == "updateFull") {
      eventos = await ref.read(clubConnectProvider).getEventos(
            widget.idequipo,
            EstadosEventos.todos,
            initDate,
            endDate,
          );
      eventosActivos = await ref.read(clubConnectProvider).getEventos(
          widget.idequipo, EstadosEventos.activo, DateTime.now(), endDate);
    }
    if (pullRefresh != null && pullRefresh) {
      loading = false;
    }
    print("Eventos: ${eventos!.length}");
    print("Eventos Activos: ${eventosActivos!.length}");
    setState(() {});
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
          eventosActivos: eventosActivos,
          role: role,
          idequipo: widget.idequipo,
          indexNotifier: _indexNotifier,
          updateFechaActivosCallback: (fecha) => updateFechaActivos(fecha),
          getEventosCallback: (estado, pullRefresh, initDate, endDate) =>
              getEventos(estado, pullRefresh, DateTime.now(), endDate!),
        );
      case 1:
        return CreateEventWidget(
          indexNotifier: _indexNotifier,
          idequipo: widget.idequipo,
          equipo: widget.team,
          idclub: widget.idclub,
          styleText: styleText,
          getEventosCallback: (estado, pullRefresh) => getEventos(
              estado, pullRefresh, DateTime.now(), fechaSeleccionada!),
        ); /*buildCreateEvents();*/
      case 2 || 3:
        return AllEventsWidget(
            indexNotifier: _indexNotifier,
            initfechaSeleccionada: initfechaSeleccionada,
            fechaSeleccionada: endFechaSeleccionada,
            role: role,
            eventos: eventos,
            idclub: widget.idclub,
            equipo: widget.team,
            idequipo: widget.idequipo,
            miembros: miembros,
            updateDate: (initDateSelected, endDateSelected) =>
                updateFechas(initDateSelected, endDateSelected),
            getEventosCallback: (estado, pullRefresh, initDate, endDate) =>
                getEventos(estado, pullRefresh, initDate, endDate));
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
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Refresh");

    print("Index: ${fechaSeleccionada}");
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
                  title: const Text("Eventos"),
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
