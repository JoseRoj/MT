import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/equipo.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/views/equipo_view/editEvent_vies.dart';
import 'package:clubconnect/presentation/views/equipo_view/eventActive_view.dart';
import 'package:clubconnect/presentation/widget/asistentes.dart';
import 'package:clubconnect/presentation/widget/modalCarga.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/club_provider.dart';

enum Menu { eliminar, editar, terminar }

class AllEventsWidget extends ConsumerStatefulWidget {
  final DateTime? initfechaSeleccionada;
  final DateTime? fechaSeleccionada;
  MonthYear selectedMonthYear;
  final int idclub;
  final int idequipo;
  final Equipo equipo;
  final String role;
  final List<User> miembros;
  final List<EventoFull>? eventos;
  final ValueNotifier<int> indexNotifier;
  final Function(MonthYear monthYear) updateMonthYear;
  final Function(DateTime? initDateSelected, DateTime? endDateSelected)
      updateDate;
  final Future<List<EventoFull>?> Function(String estado, bool? pullRefresh,
      DateTime initDate, int month, int year) getEventosCallback;

  AllEventsWidget({
    super.key,
    required this.indexNotifier,
    required this.initfechaSeleccionada,
    required this.fechaSeleccionada,
    required this.selectedMonthYear,
    required this.eventos,
    required this.role,
    required this.idclub,
    required this.equipo,
    required this.miembros,
    required this.idequipo,
    required this.updateMonthYear,
    required this.updateDate,
    required this.getEventosCallback,
  });

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
    super.initState();
    eventos = widget.eventos;
    print("Entre");
    initfechaSeleccionada = widget.initfechaSeleccionada;
    fechaSeleccionada = widget.fechaSeleccionada;
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<int> years = List.generate(3, (index) => DateTime.now().year + index);

  Future<List<EventoFull>?> getEventos(
      String estado, bool? pullRefresh, DateTime? endDate) async {
    List<EventoFull>? eventsResponse;
    if (pullRefresh != null && pullRefresh) {
      loading = true;
      setState(() {});
    }
    eventos = await widget.getEventosCallback(
        estado, pullRefresh, initfechaSeleccionada!, 8, 2024);

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
    Color colorprimary = AppTheme().getTheme().colorScheme.primary;
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
                    decoration: BoxDecoration(
                      color: colorprimary,
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
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: Text(
                      'Cerrar Sesión',
                      style: styleText.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login', (Route<dynamic> route) => false);
                    },
                  )
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
        eventos = await widget.getEventosCallback(
            EstadosEventos.todos,
            true,
            initfechaSeleccionada!,
            widget.selectedMonthYear.month,
            widget.selectedMonthYear.year);
        setState(() {});
      },
      child: Stack(
        children: [
          Column(
            children: [
              Container(
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
                    inputFecha(
                        120, widget.selectedMonthYear.nameMonth, "month"),
                    const SizedBox(width: 20, child: Text(" - ")),
                    inputFecha(
                        80, widget.selectedMonthYear.year.toString(), "year"),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: () async {
                        eventos = await widget.getEventosCallback(
                            EstadosEventos.todos,
                            true,
                            initfechaSeleccionada!,
                            widget.selectedMonthYear.month,
                            widget.selectedMonthYear.year);
                        widget.updateMonthYear(widget.selectedMonthYear);
                        setState(() {});
                      },
                      icon: Icon(Icons.search),
                    ),
                  ],
                ),
              ),

              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
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
                            8,
                            2024);
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
                            8,
                            2024);
                        setState(() {
                          loading = false;
                        });
                      }
                    },
                  ),
                ],
              ),*/
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

  Widget inputFecha(double width, String date, String value) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              height: 200,
              child: value == "month"
                  ? CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 30,
                      // This sets the initial item.
                      scrollController: FixedExtentScrollController(
                        initialItem: widget.selectedMonthYear.month - 1,
                      ),
                      // This is called when selected item is changed.
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          Meses selectedMonth = Months[selectedItem];
                          widget.selectedMonthYear = MonthYear(
                              selectedMonth.value,
                              widget.selectedMonthYear.year,
                              selectedMonth.mes);
                        });
                      },
                      children:
                          List<Widget>.generate(Months.length, (int index) {
                        return Center(child: Text(Months[index].mes));
                      }),
                    )
                  : CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 30,
                      // This sets the initial item.
                      scrollController: FixedExtentScrollController(
                          initialItem: widget.selectedMonthYear.year -
                              DateTime.now().year),
                      // This is called when selected item is changed.
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          widget.selectedMonthYear = MonthYear(
                              widget.selectedMonthYear.month,
                              years[selectedItem],
                              widget.selectedMonthYear.nameMonth);
                        });
                      },
                      children:
                          List<Widget>.generate(years.length, (int index) {
                        return Center(child: Text(years[index].toString()));
                      }),
                    )),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          date,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildEventCard(int index) {
    ThemeData theme = AppTheme().getTheme();
    return GestureDetector(
      onTap: () => modalEventDetails(eventos![index]),
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
                          "${widget.eventos![index].evento.fecha.day} ${Months.where((element) => element.value == widget.eventos![index]!.evento.fecha.month).first.mes} ${widget.eventos![index]!.evento.fecha.year}",
                          style: styleText.displayMedium,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 1),
                      Container(
                        child: Text("${eventos![index].evento.titulo} ",
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
                              "Asistentes: ${eventos![index].asistentes.length}",
                              style: styleText.labelSmall),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.circle,
                            size: 15,
                            color:
                                eventos![index].evento.estado.toLowerCase() ==
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
                              evento: eventos![index],
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
                              getEventosCallback: (estado, pullRefresh,
                                      endDate) =>
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
                    title:
                        eventos![index].evento.estado == EstadosEventos.activo
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
        .deleteEvento(int.parse(eventos![index].evento.id!));
    // Cierra el diálogo de carga solo si está activo
    // ignore: use_build_context_synchronously

    // Actualiza el estado y maneja el resultado
    if (result) {
      await widget.getEventosCallback(
          "updateFull", true, initfechaSeleccionada!, 8, 2024);
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