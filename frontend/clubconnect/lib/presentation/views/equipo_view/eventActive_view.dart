import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/domain/repositories/club_repository.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/eventosActivos_provider.dart';
import 'package:clubconnect/presentation/widget/Cardevento.dart';
import 'package:clubconnect/presentation/widget/cuppertioDate.dart';
import 'package:clubconnect/presentation/widget/drawerEquipo.dart';
import 'package:clubconnect/presentation/widget/loadingScreens/loadingActiveEvents.dart';
import 'package:clubconnect/presentation/widget/loadingScreens/loadingStadisctic.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

enum Menu { eliminar, editar, terminar }

class EventsActives extends ConsumerStatefulWidget {
  final Equipo equipo;
  final int idClub;
  String role;

  /*final Function(MonthYear? fecha) updateFechaActivosCallback;
  final Function(EventoFull evento) updateEventoSelectedCallback;
  final Future<List<EventoFull>?> Function(String estado, bool? pullRefresh,
      DateTime? initDate, int month, int year) getEventosCallback;
*/
  EventsActives({
    super.key,
    required this.equipo,
    required this.idClub,
/*      required this.dateSelected,
      this.eventoSelected,
      required this.fechaSeleccionada,*/
    required this.role,
    /*required this.updateEventoSelectedCallback,
      required this.updateFechaActivosCallback,
      required this.getEventosCallback*/
  });

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
  bool isLoading = false;
  late Future<void> futureInit;
  List<EventoFull>? eventosActivos = [];

  DateTime? fechaSeleccionada;
  EventoFull? eventoSelected;
  MonthYear dateSelected = MonthYear(DateTime.now().month, DateTime.now().year,
      Months[DateTime.now().month - 1].mes);
  List<MonthYear> proximoTresMeses = obtenerProximosTresMeses();

  @override
  void initState() {
    futureInit = initData();
    super.initState();

    /*eventosActivos = widget.eventosActivos;
    widget
        .getEventosCallback(EstadosEventos.activo, true, DateTime.now(),
            widget.dateSelected.month, widget.dateSelected.year)
        .then((value) {
      widget.eventosActivos = value;
      setState(() {});
    });*/
  }

  // Iniciar data necesaria
  Future<void> initData() async {
    await ref.read(eventosActivosProvider.notifier).getEventosActivos(
        int.parse(widget.equipo.id!),
        DateTime.now(),
        DateTime.now().month,
        DateTime.now().year);
    //eventosActivos = await ref.read(eventosActivosProvider);
    setState(() {});
  }

  Duration duration = const Duration(hours: 1, minutes: 23);

  void updateEventoSelectedCallback(String id) {
    //eventosActivos = ref.watch(eventosActivosProvider);

    eventoSelected = ref.watch(eventosActivosProvider)!.firstWhere((element) {
      return element.evento.id == id;
    });
    setState(() {});
  }

  void changeOption(MonthYear newValue) async {
    setState(() {
      isLoading = true;
    });
    try {
      dateSelected = newValue;
      await ref.watch(eventosActivosProvider.notifier).getEventosActivos(
          int.parse(widget.equipo.id!),
          DateTime.now(),
          newValue.month,
          newValue.year);
      eventoSelected = null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    //widget.eventoSelected = null;
  }

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
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
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
              : <Widget>[
                  IconButton(
                    icon: const Icon(Icons.stacked_bar_chart_outlined),
                    onPressed: () {
                      context.go(
                          '/home/0/club/${widget.idClub}/0/${widget.equipo.id}/0/${ref.watch(authProvider).id}',
                          extra: {
                            'team': widget.equipo,
                            'usuario': ref
                                .watch(authProvider)
                                .usuario, //ef.watch(authProvider)
                          });
                    },
                  ),
                ]),
      drawer: widget.role == "Administrador" || widget.role == "Entrenador"
          ? CustomDrawer(
              equipo: widget.equipo,
              idClub: widget.idClub,
              scaffoldKey: _scaffoldKey)
          : null,
      body: FutureBuilder(
          future: futureInit,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('none');
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
                return Text('active');
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 150,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppTheme()
                                    .getTheme()
                                    .colorScheme
                                    .onSecondary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      AppTheme().getTheme().colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<MonthYear>(
                                  value: proximoTresMeses
                                      .where(
                                          (e) => e.month == dateSelected.month)
                                      .first,
                                  onChanged: (MonthYear? newValue) async {
                                    if (newValue != null &&
                                        dateSelected != newValue) {
                                      changeOption(newValue);
                                      /*widget
                                          .updateFechaActivosCallback(newValue);
                                      */
                                    }
                                  },
                                  items: proximoTresMeses
                                      .map<DropdownMenuItem<MonthYear>>(
                                          (MonthYear mes) {
                                    return DropdownMenuItem<MonthYear>(
                                      value: mes,
                                      child: Text(mes.nameMonth,
                                          style: styleText.labelSmall),
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
                                eventoSelected = null;

                                /*widget.updateFechaActivosCallback(
                                initfechaSeleccionada);*/
                                /*DateFormat('dd / MM / yyyy')
                                              .format(fechaSeleccionada);*/
                                await ref
                                    .watch(eventosActivosProvider.notifier)
                                    .getEventosActivos(
                                        int.parse(widget.equipo.id!),
                                        DateTime.now(),
                                        dateSelected.month,
                                        dateSelected.year);

                                setState(() {});
                                /*setState(() {
                                        isLoading = false;
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
                      isLoading
                          ? Container(
                              height: 250,
                              child: const LoadingScreenActiveEvents())
                          : CardEvento(
                              //eventos: eventosActivos,
/*                        getEventosCallback: widget.getEventosCallback,*/
                              updateEventoSelectedCallback:
                                  updateEventoSelectedCallback,
                              dateSelected: dateSelected,
                              rol: widget.role,
                              eventoSelected: eventoSelected,
                              idequipo: int.parse(widget.equipo.id!),
                              endDate: initfechaSeleccionada!,
                            )
                    ],
                  );
                }
            }
          }),
      /*isLoading
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
