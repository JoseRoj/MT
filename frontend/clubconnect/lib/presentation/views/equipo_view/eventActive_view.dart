import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/widget/Cardevento.dart';
import 'package:clubconnect/presentation/widget/cuppertioDate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum Menu { eliminar, editar, terminar }

class EventsActives extends ConsumerStatefulWidget {
  final int idequipo;
  final Equipo equipo;
  DateTime? fechaSeleccionada;
  ValueNotifier<int> indexNotifier;
  String role;
  List<EventoFull>? eventosActivos;
  final Function(DateTime? fecha) updateFechaActivosCallback;
  final Future<List<EventoFull>?> Function(String estado, bool? pullRefresh,
      DateTime? initDate, DateTime? endDate) getEventosCallback;

  EventsActives(
      {super.key,
      required this.equipo,
      required this.idequipo,
      required this.fechaSeleccionada,
      required this.indexNotifier,
      required this.eventosActivos,
      required this.role,
      required this.updateFechaActivosCallback,
      required this.getEventosCallback});

  @override
  EventsActivesState createState() => EventsActivesState();
}

class EventsActivesState extends ConsumerState<EventsActives> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? initfechaSeleccionada = DateTime.now();
  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  List<EventoFull>? eventosActivos = [];
  var buttonText = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    print("initState Event");
    initfechaSeleccionada = widget.fechaSeleccionada;
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
                ],
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          eventosActivos = await widget.getEventosCallback(
              EstadosEventos.activo,
              true,
              DateTime.now(),
              initfechaSeleccionada!);
        },
        child: Stack(
          children: [
            Column(
              children: [
                GestureDetector(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.calendar_today),
                        Text(
                          "Hasta ${DateFormat('MM/dd/yyyy').format(initfechaSeleccionada!)}",
                          style: styleText.labelMedium,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    initfechaSeleccionada = await cuppertinoModal(
                        context, initfechaSeleccionada, DateTime.now(), null);
                    if (initfechaSeleccionada != null) {
                      /*setState(() {
                                      loading = true;
                                    });*/
                      widget.updateFechaActivosCallback(initfechaSeleccionada);
                      /*DateFormat('dd / MM / yyyy')
                                            .format(fechaSeleccionada);*/

                      await widget.getEventosCallback(EstadosEventos.activo,
                          true, DateTime.now(), initfechaSeleccionada!);
                      /*setState(() {
                                      loading = false;
                                    });*/
                    }
                  },
                ),
                Expanded(
                  child: CardEvento(
                    eventos: eventosActivos!,
                    buttonText: buttonText,
                    idequipo: widget.idequipo,
                    endDate: initfechaSeleccionada!,
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
      ),
    );
  }
}
