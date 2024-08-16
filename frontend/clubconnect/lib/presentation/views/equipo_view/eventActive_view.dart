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

  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  var buttonText = "";
  bool loading = false;
  List<EventoFull>? eventosActivos = [];
  EventoFull? eventoSelected;

  List<MonthYear> proximoTresMeses = obtenerProximosTresMeses();

  @override
  void initState() {
    super.initState();
    initfechaSeleccionada = widget.fechaSeleccionada;
    eventoSelected = widget.eventoSelected;
    eventosActivos = widget.eventosActivos;
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
    print("Refresh 1o");
    return Scaffold(
      key: _scaffoldKey,
      // Asociar la GlobalKey al Scaffold
      appBar: AppBar(
        title: const Text("Eventos"),
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
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login', (Route<dynamic> route) => false);
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
                DropdownMenu<MonthYear>(
                  textStyle: styleText.labelSmall,
                  initialSelection: proximoTresMeses
                      .where((e) => e.month == widget.dateSelected.month)
                      .first,
                  controller: mesController,
                  inputDecorationTheme: InputDecorationTheme(
                      fillColor: AppTheme().getTheme().colorScheme.onSecondary,
                      labelStyle: styleText.labelSmall,
                      filled: true,
                      constraints: const BoxConstraints(maxHeight: 40),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color:
                                  AppTheme().getTheme().colorScheme.onSecondary,
                              width: 1))),
                  requestFocusOnTap: true,
                  label: const Text('Mes'),
                  onSelected: (MonthYear? value) async {
                    print("Value : $value");
                    widget.updateFechaActivosCallback(value);
                    /*DateFormat('dd / MM / yyyy')
                                            .format(fechaSeleccionada);*/
                    widget.dateSelected = value!;
                    widget.eventosActivos = await widget.getEventosCallback(
                        EstadosEventos.activo,
                        true,
                        DateTime.now(),
                        value!.month,
                        value.year);
                    setState(() {});
                  },
                  menuStyle: MenuStyle(
                    backgroundColor: WidgetStateProperty.all(
                        AppTheme().getTheme().colorScheme.surfaceContainerLow),
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  dropdownMenuEntries: proximoTresMeses
                      .map<DropdownMenuEntry<MonthYear>>((MonthYear mes) {
                    return DropdownMenuEntry<MonthYear>(
                      value: mes,
                      label: mes.nameMonth,
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0)),
                        textStyle:
                            WidgetStateProperty.all(styleText.labelSmall),
                      ),

                      //enabled: color.label != 'Grey',
                    );
                  }).toList(),
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
