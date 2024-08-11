import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/equipo.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/views/equipo_view/editEvent_vies.dart';
import 'package:clubconnect/presentation/widget/cuppertioDate.dart';
import 'package:clubconnect/presentation/widget/modalCarga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/club_provider.dart';

enum Menu { eliminar, editar, terminar }

class AllEventsWidget extends ConsumerStatefulWidget {
  final DateTime? initfechaSeleccionada;
  final DateTime? fechaSeleccionada;
  final int idclub;
  final int idequipo;
  final Equipo equipo;
  final String role;
  final List<User> miembros;
  final List<EventoFull>? eventos;
  final ValueNotifier<int> indexNotifier;
  final Function(DateTime? initDateSelected, DateTime? endDateSelected)
      updateDate;
  final Future<List<EventoFull>?> Function(
          String estado, bool? pullRefresh, DateTime initDate, DateTime endDate)
      getEventosCallback;

  const AllEventsWidget({
    Key? key,
    required this.indexNotifier,
    required this.initfechaSeleccionada,
    required this.fechaSeleccionada,
    required this.eventos,
    required this.role,
    required this.idclub,
    required this.equipo,
    required this.miembros,
    required this.idequipo,
    required this.updateDate,
    required this.getEventosCallback,
  }) : super(key: key);

  @override
  _AllEventsWidgetState createState() => _AllEventsWidgetState();
}

class _AllEventsWidgetState extends ConsumerState<AllEventsWidget> {
  Color colorAsistir = const Color.fromARGB(255, 117, 204, 124);
  Color colorCancelar = const Color.fromARGB(255, 237, 65, 65);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<EventoFull>? eventos = [];
  final styleText = AppTheme().getTheme().textTheme;
  DateTime? initfechaSeleccionada = DateTime.now();
  DateTime? fechaSeleccionada = DateTime.now().add(const Duration(days: 30));
  final ValueNotifier<int> indexWidget = ValueNotifier<int>(0);
  bool loading = false;

  //* VARIABLES AL SELECCIONAR EVENTO PARA PODER EDITAR */
  int? eventId = 0;
  DateTime? fechaEdit;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  String? tituloEdit;
  String? descripcionEdit;
  String? lugarEdit;
  List<Asistente>? asistentes;
  //* ------------------------------------------------------
  @override
  void initState() {
    print("object");
    super.initState();
    eventos = widget.eventos;
    initfechaSeleccionada = widget.initfechaSeleccionada;
    fechaSeleccionada = widget.fechaSeleccionada;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<EventoFull>?> getEventos(
      String estado, bool? pullRefresh, DateTime? endDate) async {
    List<EventoFull>? eventsResponse;
    if (pullRefresh != null && pullRefresh) {
      loading = true;
      setState(() {});
    }
    eventos = await widget.getEventosCallback(
        estado, pullRefresh, initfechaSeleccionada!, endDate!);

    if (pullRefresh != null && pullRefresh) {
      loading = false;
    }
    setState(() {});
    return eventsResponse;
  }

  Widget _getbody(value) {
    switch (value) {
      case 0:
        return builderAllEvents();
      case 1:
        return Container();
      /*EditEventWidget(
            fechaEdit: fechaEdit!,
            horaInicio: horaInicio!,
            horaFin: horaFin!,
            tituloEdit: tituloEdit,
            descripcionEdit: descripcionEdit,
            lugarEdit: lugarEdit,
            asistentes: asistentes,
            asistentesId: asistentesId,
            eventId: eventId,
            idequipo: widget.idequipo,
            styleText: styleText,
            indexNotifier: indexWidget,
            getEventosCallback: (estado, pullRefresh, endDate) =>
                getEventos(estado, pullRefresh, endDate));*/
      default:
        return const Center(
            child: Text("No tienes permisos para ver los eventos"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
      appBar: AppBar(
        title: Text("Todos los Eventos"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.indexNotifier.value = 0;
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
                            widget.equipo.nombre,
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
                        _scaffoldKey.currentState!.closeDrawer();
                      });
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
      body: builderAllEvents(),
    );
  }

  Widget builderAllEvents() {
    return RefreshIndicator(
      onRefresh: () async {
        eventos = await widget.getEventosCallback(EstadosEventos.todos, true,
            initfechaSeleccionada!, fechaSeleccionada!);
      },
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.calendar_today),
                          Text(
                            DateFormat('MM/dd/yyyy')
                                .format(initfechaSeleccionada!),
                            style: styleText.labelMedium,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var selectedDate = await cuppertinoModal(
                        context,
                        initfechaSeleccionada,
                        DateTime(2021, 1, 1),
                        fechaSeleccionada,
                      );
                      if (selectedDate != null) {
                        setState(() {
                          loading = true;
                        });
                        initfechaSeleccionada = selectedDate;
                        eventos = await widget.getEventosCallback(
                            EstadosEventos.todos,
                            true,
                            initfechaSeleccionada!,
                            fechaSeleccionada!);
                        widget.updateDate(initfechaSeleccionada, null);

                        setState(() {
                          loading = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(child: Text(" - ")),
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.calendar_today),
                          Text(
                            DateFormat('MM/dd/yyyy').format(fechaSeleccionada!),
                            style: styleText.labelMedium,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var selectedDate = await cuppertinoModal(
                        context,
                        fechaSeleccionada,
                        initfechaSeleccionada,
                        null,
                      );
                      if (selectedDate != null) {
                        setState(() {
                          loading = true;
                        });
                        fechaSeleccionada = selectedDate;
                        widget.updateDate(null, fechaSeleccionada);
                        eventos = await widget.getEventosCallback(
                            EstadosEventos.todos,
                            true,
                            initfechaSeleccionada!,
                            fechaSeleccionada!);
                        setState(() {
                          loading = false;
                        });
                      }

                      /*DateFormat('dd / MM / yyyy')
                                                .format(fechaSeleccionada);*/
                      /*await getEventos(EstadosEventos.activo, true);*/
                    },
                  ),
                ],
              ),
              // Your date selection widgets here
              Expanded(
                child: ListView.builder(
                  itemCount: eventos!.length,
                  itemBuilder: (context, index) {
                    return buildEventCard(index);
                  },
                ),
              ),
            ],
          ),
          loading
              ? Positioned(
                  top: 20,
                  right: MediaQuery.of(context).size.width / 2 - 15,
                  child: const CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buildEventCard(int index) {
    return Stack(children: [
      Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 35),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(20), // Rounded corners
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(eventos![index].evento.titulo,
                          style: styleText.displayMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    Row(
                      children: [
                        Text(
                            DateFormat('dd / MM / yyyy')
                                .format(eventos![index].evento.fecha),
                            style: styleText.labelSmall),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.circle,
                          size: 15,
                          color: eventos![index].evento.estado.toLowerCase() ==
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
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                value: Menu.eliminar,
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: const Text('Eliminar'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    confirmDeleteEvent(index);
                  },
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.editar,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.edit, color: Colors.yellow),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    //indexWidget.value = 1;
                    setState(() {
                      eventId = int.parse(eventos![index]
                          .evento
                          .id!); // eventos![index].evento.id;
                      fechaEdit = eventos![index].evento.fecha;
                      horaInicio = convertirStringATimeOfDay(
                          eventos![index].evento.horaInicio);
                      horaFin = convertirStringATimeOfDay(
                          eventos![index].evento.horaFinal);
                      tituloEdit = eventos![index].evento.titulo;
                      descripcionEdit = eventos![index].evento.descripcion;
                      tituloEdit = eventos![index].evento.titulo;
                      lugarEdit = eventos![index].evento.lugar;
                      asistentes =
                          eventos![index].asistentes.map((e) => e).toList();
                      widget.indexNotifier.value = 3;
                    });
                    MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => EditEventWidget(
                            fechaEdit: fechaEdit!,
                            horaInicio: horaInicio!,
                            horaFin: horaFin!,
                            tituloEdit: tituloEdit,
                            descripcionEdit: descripcionEdit,
                            lugarEdit: lugarEdit,
                            asistentes: asistentes,
                            eventId: eventId,
                            idequipo: widget.idequipo,
                            miembros: widget.miembros,
                            styleText: styleText,
                            indexNotifier: indexWidget,
                            getEventosCallback:
                                (estado, pullRefresh, endDate) =>
                                    getEventos(estado, pullRefresh, endDate)));
                    Navigator.of(context).push(route);
                  },
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.terminar,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.done),
                  title: eventos![index].evento.estado == EstadosEventos.activo
                      ? const Text('Terminar')
                      : const Text('Activar'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final response = await ref
                        .read(clubConnectProvider)
                        .updateEstadoEvento(
                            int.parse(eventos![index].evento.id!),
                            eventos![index].evento.estado ==
                                    EstadosEventos.activo
                                ? EstadosEventos.terminado
                                : EstadosEventos.activo);
                    if (response) {
                      if (eventos![index].evento.estado ==
                          EstadosEventos.activo) {
                        eventos![index].evento.estado =
                            EstadosEventos.terminado;
                        customToast("Evento terminado", context, "isSuccess");
                      } else {
                        eventos![index].evento.estado = EstadosEventos.activo;
                        customToast("Evento Activado", context, "isSuccess");
                      }

                      setState(() {});
                    } else {
                      // ignore: use_build_context_synchronously
                      customToast(
                          "Error al finalizar el evento", context, "isError");
                    }
                  },
                ),
              ),
            ],
          ))
    ]);
  }

  void confirmDeleteEvent(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar evento'),
          content: Text('¿Está seguro que desea eliminar este evento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteEvent(index);
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void deleteEvent(int index) async {
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

    // Actualiza el estado y maneja el resultado
    if (result) {
      await widget.getEventosCallback(
          "updateFull", true, initfechaSeleccionada!, fechaSeleccionada!);
      eventos?.removeAt(index);

      setState(() {});
    }
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();
    }
    // Implement your delete event logic here
  }

  void updateEventStatus(EventoFull evento) async {
    // Implement your update event status logic here
  }
}
