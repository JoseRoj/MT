import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/eventoStadistic.dart';
import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/widget/Cardevento.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:clubconnect/presentation/widget/drawerEquipo.dart';
import 'package:clubconnect/presentation/widget/dropdowmEvent.dart';
import 'package:clubconnect/presentation/widget/inputMonthOrYear.dart';
import 'package:clubconnect/presentation/widget/loadingScreens/loadingStadisctic.dart';
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
  final Equipo equipo;
  final int idClub;
  ValueNotifier<int> indexNotifier;
  String role;

  StadisticTeam({
    super.key,
    required this.equipo,
    required this.idClub,
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
  DateTime dateInitial = DateTime.now();
  DateTime? dateEnd = DateTime.now().add(const Duration(days: 50));
  final FocusNode _focusNode = FocusNode();
  final styleText = AppTheme().getTheme().textTheme; // Estilo de texto
  bool isLoading = false;

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

  void filterEventsBy(String id, dynamic test) {
    if (test!.eventos.isEmpty) {
      selectedEvent == null;
      eventoFilter = [];
    } else {
      if (id == "0") {
        eventoFilter = test!.eventos;
        selectedEvent = test!.eventos[0];
      } else {
        eventoFilter = test!.eventos.where((evento) {
          return evento.idConfig != null && evento.idConfig == id;
        }).toList();
        selectedEvent = eventoFilter![0];
      }
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

  late AnimationController _controller;
  late Animation<double> _animation;

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
            ? CustomDrawer(
                equipo: widget.equipo,
                idClub: widget.idClub,
                scaffoldKey: _scaffoldKey)
            : null,
        body: isLoading
            ? Column(
                children: [selectedDates(), const LoadingScreen()],
              )
            : test != null
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        selectedDates(),
                        test!.eventos.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: Center(
                                  child: Text(
                                      "No hay eventos para generar estadísticas"),
                                ),
                              )
                            : Column(children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    print(
                                        "Asistentes : ${test!.userList.length}");
                                    bottonList();
                                    //setState(() {});
                                  },
                                  label: Text("Lista de Asistencia Total",
                                      style: AppTheme()
                                          .getTheme()
                                          .textTheme
                                          .labelSmall),
                                  icon: const Icon(Icons.list_alt),
                                ),
                                selectedEvent != null
                                    ? Column(
                                        children: [
                                          dropdownButtonAllOrRecurrent(),
                                          const SizedBox(height: 5),
                                          grafico(),
                                          DropdownButtonEventSpecific(
                                              eventoFilter: eventoFilter,
                                              selectedEvent: selectedEvent),
                                        ],
                                      )
                                    : Container()
                              ])
                      ],
                    ),
                  )
                : selectedDates());
  }

  void bottonList() async {
    await showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                // Título del modal
                Text('Lista de Asistencias',
                    style: AppTheme()
                        .getTheme()
                        .textTheme
                        .titleSmall // Estilo del título
                    ),
                const SizedBox(
                    height: 20), // Espacio entre el título y la lista
                // Lista de usuarios
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true, // Ajusta la lista al contenido
                    itemCount: test!.userList.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              test!.userList[index].nombrecompleto,
                              style: AppTheme().getTheme().textTheme.bodyMedium,
                            ),
                          ),
                          Text(test!.userList[index].totalAsistencias)
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget selectedDates() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InputFechaWidget(
            width: 110,
            date: dateInitial,
            value: "date",
            type: "Init",
            updateDate: selectedDate),
        const SizedBox(width: 10),
        InputFechaWidget(
            width: 110,
            date: dateEnd,
            value: "date",
            type: "End",
            updateDate: selectedDate),
        IconButton.filled(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            final x = await ref.read(clubConnectProvider).getEventoStadistic(
                dateInitial,
                dateEnd!,
                int.parse(widget.equipo.id!),
                widget.idClub);
            test = x;
            options = [Option(name: 'Todos', value: '0')];
            if (x.eventos.isNotEmpty) {
              test!.recurrentes
                  .map((config) => {
                        options!
                            .add(Option(name: config.titulo, value: config.id))
                      })
                  .toList();
              selected = options![0];

              eventoFilter = test!.eventos;
              selectedEvent = test!.eventos[0];
            } else {
              if (test!.eventos.isEmpty) {
                selectedEvent == null;
              }
            }
            setState(() {
              isLoading = false;
            });
          },
          icon: const Icon(Icons.search),
        ),
      ],
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
              filterEventsBy(option.value, test);
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
}
