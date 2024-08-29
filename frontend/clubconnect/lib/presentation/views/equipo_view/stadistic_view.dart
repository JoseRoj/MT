import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/eventoStadistic.dart';
import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/widget/Cardevento.dart';
import 'package:clubconnect/presentation/widget/inputMonthOrYear.dart';
import 'package:clubconnect/presentation/widget/userlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.x, this.y, this.titulo);
  final DateTime x;
  final double y;
  final String titulo;
}

enum Menu { eliminar, editar, terminar }

class StadisticTeam extends ConsumerStatefulWidget {
  final int idequipo;
  final Equipo equipo;
  ValueNotifier<int> indexNotifier;
  String role;

  StadisticTeam({
    super.key,
    required this.equipo,
    required this.idequipo,
    required this.indexNotifier,
    required this.role,
  });

  @override
  StadisticTeamState createState() => StadisticTeamState();
}

class Option {
  final String name;
  final String value;

  Option({required this.name, required this.value});
}

class StadisticTeamState extends ConsumerState<StadisticTeam> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? dateInitial;
  DateTime? dateEnd;
  final FocusNode _focusNode = FocusNode();
  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  bool loading = false;

  EventoStadistic? test;
  List<Evento>? eventoFilter;
  List<Option>? options;
  List<String> timeOptions = ['Individual', 'Semanal', 'Mensual', 'Anual'];
  Option? selected;
  String selectedTime = 'Individual';
  Evento? selectedEvent;

  //* ------------------ Funciones -----------------
  void selectedDate(DateTime dateSelected, String type) {
    if (type == "Init") {
      dateInitial = dateSelected;
    } else {
      dateEnd = dateSelected;
    }
    setState(() {});
  }

  void filterEventsBy(String id) {
    if (id == "0") {
      eventoFilter = test!.eventos;
    } else {
      eventoFilter = test!.eventos.where((evento) {
        return evento.idConfig != null && evento.idConfig == id;
      }).toList();
      selectedEvent = eventoFilter![0];
    }
  }

  List<Map<String, DateTime>> getWeeksInRange(
      DateTime startDate, DateTime endDate) {
    List<Map<String, DateTime>> weeks = [];
    bool flagInitial = true;
    DateTime currentStartDate = startDate;
    while (currentStartDate.isBefore(endDate)) {
      // Obtener el día de la semana (1: lunes, 7: domingo)
      int currentDayOfWeek = currentStartDate.weekday;

      // Calcular el comienzo de la semana (lunes)
      DateTime startOfWeek;

      if (flagInitial) {
        startOfWeek = startDate;
        flagInitial = false;
      } else {
        startOfWeek =
            currentStartDate.subtract(Duration(days: currentDayOfWeek - 1));
      }

      // Calcular el final de la semana (domingo)
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Ajustar el final de la semana si excede la fecha de fin
      if (endOfWeek.isAfter(endDate)) {
        endOfWeek = endDate;
      }

      // Añadir el par de fechas a la lista
      weeks.add({
        'start': startOfWeek,
        'end': endOfWeek,
      });

      // Mover al comienzo de la siguiente semana
      currentStartDate = endOfWeek.add(const Duration(days: 1));
    }
    for (var week in weeks) {
      print(
          'Comienzo de la semana: ${DateFormat('yyyy-MM-dd').format(week['start']!)}');
      print(
          'Final de la semana: ${DateFormat('yyyy-MM-dd').format(week['end']!)}');
    }

    return weeks;
  }

  @override
  void initState() {
    super.initState();
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
    if (test == null) {
      return Scaffold(
        key: _scaffoldKey,
        // Asociar la GlobalKey al Scaffold
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estadísticas ',
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
              : null,
        ),
        drawer: widget.role == "Administrador" || widget.role == "Entrenador"
            ? drawer()
            : null,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InputFechaWidget(
                    width: 110,
                    date: dateInitial ?? DateTime.now(),
                    value: "date",
                    type: "Init",
                    updateDate: selectedDate),
                const SizedBox(width: 10),
                InputFechaWidget(
                    width: 110,
                    date: dateEnd ?? DateTime.now(),
                    value: "date",
                    type: "End",
                    updateDate: selectedDate),
                IconButton.filled(
                  onPressed: () async {
                    final x = await ref
                        .read(clubConnectProvider)
                        .getEventoStadistic(dateInitial!, dateEnd!, 88, 110);
                    test = x;
                    selectedEvent = x.eventos[0];
                    options = [Option(name: 'Todos', value: '0')];
                    test!.recurrentes
                        .map((config) => {
                              options!.add(
                                  Option(name: config.titulo, value: config.id))
                            })
                        .toList();
                    selected = options![0];
                    filterEventsBy("0");
                    setState(() {});
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        // Asociar la GlobalKey al Scaffold
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estadísticas ',
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
              : null,
        ),
        drawer: widget.role == "Administrador" || widget.role == "Entrenador"
            ? drawer()
            : null,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InputFechaWidget(
                      width: 110,
                      date: dateInitial ?? DateTime.now(),
                      value: "date",
                      type: "Init",
                      updateDate: selectedDate),
                  const SizedBox(width: 10),
                  InputFechaWidget(
                      width: 110,
                      date: dateEnd ?? DateTime.now(),
                      value: "date",
                      type: "End",
                      updateDate: selectedDate),
                  IconButton.filled(
                    onPressed: () async {
                      final x = await ref
                          .read(clubConnectProvider)
                          .getEventoStadistic(dateInitial!, dateEnd!, 88, 110);
                      test = x;
                      selectedEvent = x.eventos[0];
                      options = [Option(name: 'Todos', value: '0')];
                      test!.recurrentes
                          .map((config) => {
                                options!.add(Option(
                                    name: config.titulo, value: config.id))
                              })
                          .toList();
                      selected = options![0];
                      setState(() {});
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                label: Text("Lista de Asistencia Total",
                    style: AppTheme().getTheme().textTheme.labelSmall),
                icon: const Icon(Icons.list_alt),
              ),
              dropdownButtonAllOrRecurrent(),
              const SizedBox(height: 5),
              dropdownButtonTime(),
              grafico(),
              dropdownButtonEventSpecific(),
              infoEvent()
            ],
          ),
        ));
  }

  Widget drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
    );
  }

  Widget grafico() {
    final List<ChartData> chartData = eventoFilter!.map((event) {
      return ChartData(
          event.fecha, event.asistentes!.length.toDouble(), event.titulo);
    }).toList();

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 250,
      child: SfCartesianChart(
        primaryXAxis: const DateTimeAxis(
          // Permite el desplazamiento horizontal
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          intervalType: DateTimeIntervalType.days,
          majorGridLines: MajorGridLines(width: 0),
        ),
        series: <CartesianSeries<ChartData, DateTime>>[
          LineSeries<ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ChartData data, int index) => data.x,
            yValueMapper: (ChartData data, int index) => data.y,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            final ChartData chartData = data as ChartData;
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme().getTheme().primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chartData.titulo,
                      style: const TextStyle(color: Colors.white, fontSize: 8)),
                  Text(
                      'Fecha: ${DateFormat('dd / MM / yyyy').format(chartData.x)}',
                      style: const TextStyle(color: Colors.white, fontSize: 8)),
                  Text('Asistentes: ${chartData.y.toInt()}',
                      style: const TextStyle(color: Colors.white, fontSize: 8)),
                ],
              ),
            );
          },
        ),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true, // Habilita el desplazamiento horizontal
          enableDoubleTapZooming: true, // Habilita el zoom con doble toque
          zoomMode:
              ZoomMode.x, // Habilita el zoom y desplazamiento solo en el eje X
        ),
      ),
      /*SfCartesianChart(
          enableAxisAnimation: true,
          primaryXAxis: CategoryAxis(
            // Permite el desplazamiento en el eje X
            isVisible: true,
            autoScrollingDelta:
                10, // Cantidad de categorías visibles antes de que se active el scroll
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true, // Habilita el desplazamiento o panning
          ), // Cambia el eje X a un eje de categorías
          series: <CartesianSeries<ChartData, DateTime>>[
            // Renders column chart
            LineSeries<ChartData, DateTime>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              markerSettings: MarkerSettings(isVisible: true),
              dataLabelSettings: DataLabelSettings(
                isVisible: false,
                // Custom data label format
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            // Custom tooltip for showing event details
            tooltipPosition: TooltipPosition.pointer,
            format: 'point.x : point.y\nEvent: point.eventName',
            header: '',
            textStyle: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),*/
    );
  }

  Widget dropdownButtonAllOrRecurrent() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme().getTheme().colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme().getTheme().colorScheme.primary,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Option>(
          menuMaxHeight: 300,
          value: selected,
          onChanged: (Option? option) {
            if (option != null) {
              filterEventsBy(option.value);

              setState(() {
                selected = option;
              });
            }
          },
          items: options!.map<DropdownMenuItem<Option>>((Option option) {
            return DropdownMenuItem<Option>(
              value: option,
              child:
                  Center(child: Text(option.name, style: styleText.labelSmall)),
            );
          }).toList(),
          style: styleText.labelSmall,
          isExpanded: true, // Para que ocupe todo el ancho del container
        ),
      ),
    );
  }

  Widget dropdownButtonTime() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme().getTheme().colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme().getTheme().colorScheme.primary,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          menuMaxHeight: 300,
          value: selectedTime,
          onChanged: (String? option) {
            if (option != null) {
              setState(() {
                getWeeksInRange(dateInitial!, dateEnd!);
                selectedTime = option;
              });
            }
          },
          items: timeOptions.map<DropdownMenuItem<String>>((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Center(child: Text(option, style: styleText.labelSmall)),
            );
          }).toList(),
          style: styleText.labelSmall,
          isExpanded: true, // Para que ocupe todo el ancho del container
        ),
      ),
    );
  }

  Widget dropdownButtonEventSpecific() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme().getTheme().colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme().getTheme().colorScheme.primary,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Evento>(
          menuMaxHeight: 300,
          value: selectedEvent,
          onChanged: (Evento? option) {
            if (option != null) {
              setState(() {
                selectedEvent = option;
              });
            }
          },
          items: eventoFilter!.map<DropdownMenuItem<Evento>>((Evento option) {
            return DropdownMenuItem<Evento>(
              value: option,
              child: Center(
                  child: Text(
                      "${option.titulo} (${(DateFormat('dd/MM/yyyy').format(option.fecha))})",
                      style: styleText.labelSmall)),
            );
          }).toList(),
          style: styleText.labelSmall,
          isExpanded: true, // Para que ocupe todo el ancho del container
        ),
      ),
    );
  }

  Widget infoEvent() {
    return Column(
      children: [
        Text(selectedEvent!.titulo),
        const Text("90 % Asistencia"),
        const Text("Asistentes"),
        SingleChildScrollView(
          child: Wrap(
            children: selectedEvent!.asistentes!.map((e) {
              return userList(
                name: e.nombre,
                image: e.imagen,
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
