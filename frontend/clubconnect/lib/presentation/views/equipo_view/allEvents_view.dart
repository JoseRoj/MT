import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/equipo.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/insfrastructure/models/eventoStadistic.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/views/equipo_view/editEvent_vies.dart';
import 'package:clubconnect/presentation/widget/asistentes.dart';
import 'package:clubconnect/presentation/widget/drawerEquipo.dart';
import 'package:clubconnect/presentation/widget/inputMonthOrYear.dart';
import 'package:clubconnect/presentation/widget/loadingScreens/loadingAllEvents.dart';
import 'package:clubconnect/presentation/widget/modalCarga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/club_provider.dart';

enum Menu { eliminar, editar, terminar }

// ignore: must_be_immutable
class AllEventsWidget extends ConsumerStatefulWidget {
  final DateTime? initfechaSeleccionada;
  final DateTime? fechaSeleccionada;
  //MonthYear selectedMonthYear;
  final int idClub;
  final Equipo equipo;
  final String role;
  final List<User> miembros;
  //List<EventoFull>? eventos;

/*  final Function(MonthYear monthYear) updateMonthYear;
  final Function(DateTime? initDateSelected, DateTime? endDateSelected)
      updateDate;
  final Future<List<EventoFull>?> Function(String estado, bool? pullRefresh,
      DateTime initDate, int month, int year) getEventosCallback;*/

  AllEventsWidget({
    super.key,
    required this.initfechaSeleccionada,
    required this.fechaSeleccionada,
    //required this.selectedMonthYear,
    //required this.eventos,
    required this.role,
    required this.idClub,
    required this.equipo,
    required this.miembros,
    /*required this.updateMonthYear,
    required this.updateDate,
    required this.getEventosCallback,*/
  });

  @override
  AllEventsWidgetState createState() => AllEventsWidgetState();
}

class AllEventsWidgetState extends ConsumerState<AllEventsWidget> {
  Color colorAsistir = const Color.fromARGB(255, 117, 204, 124);
  Color colorCancelar = const Color.fromARGB(255, 237, 65, 65);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final styleText = AppTheme().getTheme().textTheme;
  DateTime? initfechaSeleccionada = DateTime.now();
  DateTime? fechaSeleccionada = DateTime.now().add(const Duration(days: 30));
  final ValueNotifier<int> indexWidget = ValueNotifier<int>(0);
  bool loading = false;

  //* VARIABLES DE ALL EVENTOS *//
  late Future<void> futureInit;
  List<EventoFull> allEventos = [];
  MonthYear monthYear = MonthYear(DateTime.now().month, DateTime.now().year,
      Months[DateTime.now().month - 1].mes);

  //* VARIABLES AL SELECCIONAR EVENTO PARA PODER EDITAR */
  int? eventId = 0;
  DateTime? fechaEdit;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  String? tituloEdit;
  String? descripcionEdit;
  String? lugarEdit;
  List<Asistente>? asistentes;
  bool isLoading = false;

  //* ------------------ Funciones -----------------
  void selectedMonthYear(int selectedItem) {
    setState(() {
      Meses selectedMonth = Months[selectedItem];
      monthYear =
          MonthYear(selectedMonth.value, monthYear.year, selectedMonth.mes);
    });
  }

  //* ------------------------------------------------------
  @override
  void initState() {
    futureInit = initData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initData() async {
    allEventos = await ref.read(clubConnectProvider).getEventos(
        int.parse(widget.equipo.id!),
        EstadosEventos.todos,
        DateTime.now(),
        DateTime.now().month,
        DateTime.now().year);
  }

  //** -------------- FUNCIONES ------------ **/
  Future<void> getAllEvents() async {
    try {
      setState(() {
        isLoading = true;
      });
      allEventos = await ref.read(clubConnectProvider).getEventos(
          int.parse(widget.equipo.id!),
          EstadosEventos.todos,
          DateTime.now(),
          monthYear.month,
          monthYear.year);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /*Future<List<EventoFull>?> getEventos(
      String estado, bool? pullRefresh, DateTime? endDate) async {
    List<EventoFull>? eventsResponse;
    if (pullRefresh != null && pullRefresh) {
      loading = true;
      setState(() {});
    }
    widget.eventos = await widget.getEventosCallback(
        estado, pullRefresh, initfechaSeleccionada!, 8, 2024);

    if (pullRefresh != null && pullRefresh) {
      loading = false;
    }
    setState(() {});
    return eventsResponse;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asociar la GlobalKey al Scaffold
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Todos los Eventos',
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
      body: FutureBuilder(
        future: futureInit,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );

            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Text('Error');
              } else {
                return isLoading
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            selectedDate(),
                            const LoadingScreenAllEvents()
                          ],
                        ),
                      )
                    : builderAllEvents();
              }
            case ConnectionState.none:
              return const Text('none');
            case ConnectionState.active:
              return const Text('active');
          }
        },
      ),
    );
  }

  Widget selectedDate() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InputFechaWidget(
              width: 120,
              date: monthYear,
              value: "month",
              onMonthYearChanged: selectedMonthYear),
          const SizedBox(width: 10),
          InputFechaWidget(
              width: 100,
              date: monthYear,
              value: "year",
              onMonthYearChanged: selectedMonthYear),
          IconButton.filled(
            onPressed: () async {
              await getAllEvents();
              setState(() {});
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget builderAllEvents() {
    return RefreshIndicator(
      onRefresh: () async {
        await getAllEvents();

        setState(() {});
      },
      child: Stack(
        children: [
          Column(
            children: [
              selectedDate(),
              // Your date selection widgets here
              allEventos.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 100, color: Colors.grey),
                            Text("No hay eventos ",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: allEventos.length,
                        itemBuilder: (context, index) {
                          return buildEventCard(index);
                        },
                      ),
                    )
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
    ThemeData theme = AppTheme().getTheme();
    return GestureDetector(
      onTap: () => modalEventDetails(allEventos[index]),
      child: Stack(children: [
        Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 35),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            constraints: const BoxConstraints(
              minWidth: 100, // Tamaño mínimo en ancho
              maxWidth:
                  double.infinity, // Tamaño máximo en ancho (autoajustable)
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  Color.fromARGB(255, 255, 255, 255)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // Background color
              borderRadius: BorderRadius.circular(20), // Rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, // Shadow color
                  blurRadius: 10, // Blur radius
                  offset: Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                          "${allEventos[index].evento.fecha.day} ${Months.where((element) => element.value == allEventos[index].evento.fecha.month).first.mes} ${allEventos[index].evento.fecha.year}",
                          style: styleText.displayMedium,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 1),
                      Container(
                        child: Text("${allEventos[index].evento.titulo} ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.group),
                          const SizedBox(width: 10),
                          Text(
                              "Asistentes: ${allEventos[index].asistentes.length}",
                              style: styleText.labelSmall),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.circle,
                            size: 15,
                            color:
                                allEventos[index].evento.estado.toLowerCase() ==
                                        "activo"
                                    ? colorAsistir
                                    : colorCancelar,
                          ),
                          const SizedBox(width: 5),
                          Text(allEventos[index].evento.estado,
                              style: styleText.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )),
        Positioned(
            top: 10,
            right: 20,
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
                        var evento = allEventos[index];
                        eventId =
                            int.parse(evento.evento.id!); // evento.evento.id;
                        fechaEdit = evento.evento.fecha;
                        horaInicio =
                            convertirStringATimeOfDay(evento.evento.horaInicio);
                        horaFin =
                            convertirStringATimeOfDay(evento.evento.horaFinal);
                        tituloEdit = evento.evento.titulo;
                        descripcionEdit = evento.evento.descripcion;
                        tituloEdit = evento.evento.titulo;
                        lugarEdit = evento.evento.lugar;
                        asistentes = evento.asistentes.map((e) => e).toList();
                        // widget.indexNotifier.value = 3;
                      });
                      MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => EditEventWidget(
                          evento: allEventos[index],
                          fechaEdit: fechaEdit!,
                          horaInicio: horaInicio!,
                          horaFin: horaFin!,
                          tituloEdit: tituloEdit,
                          descripcionEdit: descripcionEdit,
                          lugarEdit: lugarEdit,
                          asistentes: asistentes,
                          eventId: eventId,
                          idequipo: int.parse(widget.equipo.id!),
                          miembros: widget.miembros,
                          styleText: styleText,
                          indexNotifier: indexWidget,
                          getEventosCallback: getAllEvents,
                        ),
                      );
                      Navigator.of(context).push(route);
                    },
                  ),
                ),
                PopupMenuItem<Menu>(
                  value: Menu.terminar,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.done),
                    title:
                        allEventos[index].evento.estado == EstadosEventos.activo
                            ? const Text('Terminar')
                            : const Text('Activar'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final response = await ref
                          .read(clubConnectProvider)
                          .updateEstadoEvento(
                              int.parse(allEventos[index].evento.id!),
                              allEventos[index].evento.estado ==
                                      EstadosEventos.activo
                                  ? EstadosEventos.terminado
                                  : EstadosEventos.activo);
                      if (response) {
                        if (allEventos[index].evento.estado ==
                            EstadosEventos.activo) {
                          allEventos[index].evento.estado =
                              EstadosEventos.terminado;
                          customToast("Evento terminado", context, "isSuccess");
                        } else {
                          allEventos[index].evento.estado =
                              EstadosEventos.activo;
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
      ]),
    );
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
        .deleteEvento(int.parse(allEventos[index].evento.id));
    // Cierra el diálogo de carga solo si está activo
    // ignore: use_build_context_synchronously

    // Actualiza el estado y maneja el resultado
    if (result) {
      getAllEvents();
/*      await widget.getEventosCallback(
          "updateFull", true, initfechaSeleccionada!, 8, 2024);
      widget.eventos?.removeAt(index);
*/
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

  void modalEventDetails(EventoFull evento) {
    Widget Asistentes = AttendeesList(asistentes: evento.asistentes);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled:
          true, // Permite que el modal se expanda para contenido grande
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 500,
            ),
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    evento.evento.titulo,
                    style: styleText.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('dd / MM / yyyy').format(evento.evento.fecha),
                  ),
                  Text(
                      "${evento.evento.horaInicio.substring(0, 5)} - ${evento.evento.horaFinal.substring(0, 5)}",
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black)),
                  Text(
                    evento.evento.descripcion,
                    style: styleText.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on),
                      Flexible(
                        child: Text(
                          evento.evento.lugar,
                          style: styleText.bodyMedium,
                          maxLines: 2, // Limita el texto a 2 líneas
                          overflow: TextOverflow
                              .ellipsis, // Añade "..." si el texto es demasiado largo para el espacio disponible
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 15,
                        color: evento.evento.estado.toLowerCase() == "activo"
                            ? colorAsistir
                            : colorCancelar,
                      ),
                      const SizedBox(width: 5),
                      Text(evento.evento.estado, style: styleText.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Asistentes,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
/*
 Stack(children: [
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
 */
