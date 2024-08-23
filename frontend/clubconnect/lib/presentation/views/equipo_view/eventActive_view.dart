import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/domain/repositories/club_repository.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/Cardevento.dart';
import 'package:clubconnect/presentation/widget/cuppertioDate.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

enum Menu { eliminar, editar, terminar }

final List<Meses> Months = <Meses>[
  Meses("Enero", 1),
  Meses("Febrero", 2),
  Meses("Marzo", 3),
  Meses("Abril", 4),
  Meses("Mayo", 5),
  Meses("Junio", 6),
  Meses("Julio", 7),
  Meses("Agosto", 8),
  Meses("Septiembre", 9),
  Meses("Octubre", 10),
  Meses("Noviembre", 11),
  Meses("Diciembre", 12),
];

class Meses {
  Meses(this.mes, this.value);
  final String mes;
  final int value;
}

class EventsActives extends ConsumerStatefulWidget {
  final int idequipo;
  final Equipo equipo;
  DateTime? fechaSeleccionada;
  EventoFull? eventoSelected;
  MonthYear dateSelected;
  ValueNotifier<int> indexNotifier;
  String role;
  List<EventoFull>? eventosActivos;
  final Function(MonthYear? fecha) updateFechaActivosCallback;
  final Function(EventoFull evento) updateEventoSelectedCallback;
  final Future<List<EventoFull>?> Function(String estado, bool? pullRefresh,
      DateTime? initDate, int month, int year) getEventosCallback;

  EventsActives(
      {super.key,
      required this.equipo,
      required this.idequipo,
      required this.dateSelected,
      this.eventoSelected,
      required this.fechaSeleccionada,
      required this.indexNotifier,
      required this.eventosActivos,
      required this.role,
      required this.updateEventoSelectedCallback,
      required this.updateFechaActivosCallback,
      required this.getEventosCallback});

  @override
  EventsActivesState createState() => EventsActivesState();
}

List<MonthYear> obtenerProximosTresMeses() {
  DateTime ahora = DateTime.now();
  int mesActual = ahora.month;
  int anoActual = ahora.year;

  List<MonthYear> mesesFuturos = [];

  // Añadir los próximos 3 meses
  for (int i = 0; i < 6; i++) {
    int mes = mesActual + i;
    int ano = anoActual;

    if (mes > 12) {
      mes -= 12;
      ano += 1;
    }

    String nombreMes = Months.firstWhere((m) => m.value == mes).mes;
    mesesFuturos.add(MonthYear(mes, ano, nombreMes));
  }

  return mesesFuturos;
}

class EventsActivesState extends ConsumerState<EventsActives> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? initfechaSeleccionada = DateTime.now();
  TextEditingController mesController = TextEditingController(
      text: Months.where((e) => e.value == DateTime.now().month).first.mes);

  final FocusNode _focusNode = FocusNode();

  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  var buttonText = "";
  bool loading = false;
  List<EventoFull>? eventosActivos = [];

  List<MonthYear> proximoTresMeses = obtenerProximosTresMeses();

  @override
  void initState() {
    super.initState();
    initfechaSeleccionada = widget.fechaSeleccionada;
    eventosActivos = widget.eventosActivos;
    widget
        .getEventosCallback(EstadosEventos.activo, true, DateTime.now(),
            widget.dateSelected.month, widget.dateSelected.year)
        .then((value) {
      widget.eventosActivos = value;
      setState(() {});
    });
    widget.eventoSelected = null;
  }

  Duration duration = const Duration(hours: 1, minutes: 23);

  /* 
    * params: 
      * estado = "Activo" | "Terminado" | "Cancelado" | "Todos"
      * pullRefresh = true | false
  */

  /* Vista de Todos los Eventos Activos */

/* Vista de los miembros del equipo */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Asociar la GlobalKey al Scaffold
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eventos ',
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
            context.pop();
          },
        ),
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
                      color: AppTheme().getTheme().primaryColor,
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
                      });
                      _scaffoldKey.currentState!.closeDrawer();
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
                      _scaffoldKey.currentState!.closeDrawer();
                      setState(() {
                        widget.indexNotifier.value = 4;
                      });
                      // Acción cuando se presiona la opción 2 del Drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_repeat_rounded),
                    title: Text(
                      'Config Eventos Recurrentes',
                      style: styleText.bodyMedium,
                    ),
                    onTap: () {
                      _scaffoldKey.currentState!.closeDrawer();
                      setState(() {
                        widget.indexNotifier.value = 5;
                      });
                    },
                  )
                ],
              ),
            )
          : null,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme().getTheme().colorScheme.onSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme().getTheme().colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MonthYear>(
                      value: proximoTresMeses
                          .where((e) => e.month == widget.dateSelected.month)
                          .first,
                      onChanged: (MonthYear? newValue) async {
                        if (newValue != null &&
                            widget.dateSelected != newValue) {
                          widget.updateFechaActivosCallback(newValue);
                          widget.dateSelected = newValue;
                          widget.eventosActivos =
                              await widget.getEventosCallback(
                                  EstadosEventos.activo,
                                  true,
                                  DateTime.now(),
                                  newValue.month,
                                  newValue.year);
                          widget.eventoSelected = null;
                          setState(() {});
                        }
                      },
                      items: proximoTresMeses
                          .map<DropdownMenuItem<MonthYear>>((MonthYear mes) {
                        return DropdownMenuItem<MonthYear>(
                          value: mes,
                          child:
                              Text(mes.nameMonth, style: styleText.labelSmall),
                        );
                      }).toList(),
                      style: styleText.labelSmall,
                      isExpanded:
                          true, // Para que ocupe todo el ancho del container
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    widget.eventoSelected = null;

                    /*widget.updateFechaActivosCallback(
                              initfechaSeleccionada);*/
                    /*DateFormat('dd / MM / yyyy')
                                            .format(fechaSeleccionada);*/
                    widget.eventosActivos = await widget.getEventosCallback(
                        EstadosEventos.activo,
                        true,
                        DateTime.now(),
                        widget.dateSelected.month,
                        widget.dateSelected.year);

                    setState(() {});
                    /*setState(() {
                                      loading = false;
                                    });*/
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.refresh),
                      Text(
                        "Actualizar",
                        style: styleText.labelMedium,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          CardEvento(
            eventos: widget.eventosActivos,
            getEventosCallback: widget.getEventosCallback,
            updateEventoSelectedCallback: widget.updateEventoSelectedCallback,
            dateSelected: widget.dateSelected,
            eventoSelected: widget.eventoSelected,
            idequipo: widget.idequipo,
            endDate: initfechaSeleccionada!,
          ),
        ],
      ),
      /*loading
                ? Positioned(
                    top: 20,
                    right: MediaQuery.of(context).size.width / 2 - 15,
                    child: const CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  )
                : Container(),*/
    );
  }
}
