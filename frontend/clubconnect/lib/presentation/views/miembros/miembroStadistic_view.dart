import 'dart:typed_data';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/monthStadistic.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UserStadistic extends ConsumerStatefulWidget {
  static const String name = 'UserStadistic';
  final int idclub;
  final int idequipo;
  final int iduser;
  final User usuario;
  const UserStadistic(
      {super.key,
      required this.idclub,
      required this.idequipo,
      required this.iduser,
      required this.usuario});

  @override
  UserStadisticState createState() => UserStadisticState();
}

class UserStadisticState extends ConsumerState<UserStadistic> {
  final FocusNode _focusNode1 = FocusNode();

  void _unfocusAll(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  Uint8List? imageUser;
  TextTheme styleText = AppTheme().getTheme().textTheme;
  late List<PieData> data;
  late TooltipBehavior _tooltip;
  late Future<void> _futuremonthStadistic;
  late List<MonthStadisticUser> monthStadistic;
  final TextEditingController mesController = TextEditingController();
  late MonthStadisticUser selected;
  @override
  void initState() {
    super.initState();

    _futuremonthStadistic = _getMonthStadisticUser();
    imageUser = imagenFromBase64(widget.usuario.imagen);
    _tooltip = TooltipBehavior(enable: true);
  }

  Future<void> _getMonthStadisticUser() async {
    print("Holanda");
    try {
      final stats = await ref
          .read(clubConnectProvider)
          .getMonthStadisticUser(widget.iduser, widget.idequipo);
      print("Holanda" + stats.toString());

      if (stats.length != 0) {
        data = <PieData>[
          PieData(Colors.lightGreen, stats.first.participation, 'Asistido'),
          PieData(
              Colors.red,
              stats.first.totalEventos - stats.first.participation,
              'No Asistido'),
        ];
      }
      setState(() {
        monthStadistic = stats;
        selected = stats.first;
      });
    } catch (e) {
      print(e);
    }
  }

  void updatePieChart() {
    selected = monthStadistic
        .where((element) => element.mes == mesController.text)
        .first;
    data = <PieData>[
      PieData(Colors.lightGreen, selected.participation, 'Asistido'),
      PieData(Colors.red, selected.totalEventos - selected.participation,
          'No Asistido'),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Estadisticas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: GestureDetector(
          onTap: () {
            _unfocusAll(context);
          },
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: _futuremonthStadistic,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ImageOval(
                                  widget.usuario.imagen, imageUser, 70, 70)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${widget.usuario.nombre} ${widget.usuario.apellido1} ${widget.usuario.apellido2}",
                                  style: styleText.labelMedium),
                              Text("Deportista ", style: styleText.labelMedium),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textAlert("Fecha Nacimiento : ",
                                DateToString(widget.usuario.fechaNacimiento)),
                            textAlert("Género : ", widget.usuario.genero),
                            textAlert("Correo : ", widget.usuario.email),
                            textAlert("Teléfono : ", widget.usuario.telefono),
                          ],
                        ),
                      ),
                      monthStadistic.isEmpty
                          ? Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: const Text(
                                    'No existen registros de asistencia en los últimos 6 meses',
                                    textAlign: TextAlign.center),
                              ),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  width: 300,
                                  height: 250,
                                  child: SfCartesianChart(
                                    primaryXAxis: const CategoryAxis(
                                      //title: AxisTitle(text: 'Mes'),
                                      majorGridLines: MajorGridLines(width: 0),
                                    ),
                                    primaryYAxis: const NumericAxis(
                                        title: AxisTitle(text: 'Evento')),
                                    // Chart title
                                    title: const ChartTitle(
                                        text:
                                            'Asistencia Eventos Ultimos 6 meses',
                                        textStyle: TextStyle(fontSize: 10)),
                                    // Enable legend
                                    legend: const Legend(isVisible: true),
                                    // Enable tooltip
                                    tooltipBehavior: _tooltip,
                                    series: <CartesianSeries>[
                                      StackedColumnSeries<MonthStadisticUser,
                                              String>(
                                          name: 'Asistencias',
                                          dataLabelMapper: (datum, index) =>
                                              datum.participation.toString(),
                                          groupName: 'Participaciones',
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                                  isVisible: false,
                                                  showCumulativeValues: true),
                                          dataSource: monthStadistic,
                                          xValueMapper:
                                              (MonthStadisticUser data, _) =>
                                                  data.mes,
                                          yValueMapper:
                                              (MonthStadisticUser data, _) =>
                                                  data.participation),
                                      StackedColumnSeries<MonthStadisticUser,
                                              String>(
                                          name: 'Eventos Totales',
                                          groupName: 'Total',
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                                  isVisible: true,
                                                  showCumulativeValues: true),
                                          dataSource: monthStadistic,
                                          xValueMapper:
                                              (MonthStadisticUser data, _) =>
                                                  data.mes,
                                          yValueMapper:
                                              (MonthStadisticUser data, _) =>
                                                  data.totalEventos),
                                    ],
                                  ),
                                ),
                                DropdownMenu<MonthStadisticUser>(
                                  textStyle: styleText.labelSmall,
                                  initialSelection: monthStadistic[0],
                                  controller: mesController,
                                  inputDecorationTheme: InputDecorationTheme(
                                      fillColor: AppTheme()
                                          .getTheme()
                                          .colorScheme
                                          .onSecondary,
                                      labelStyle: styleText.labelSmall,
                                      filled: true,
                                      constraints:
                                          BoxConstraints(maxHeight: 40),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: AppTheme()
                                                  .getTheme()
                                                  .colorScheme
                                                  .onSecondary,
                                              width: 1))),
                                  requestFocusOnTap: true,
                                  label: const Text('Mes'),
                                  onSelected: (MonthStadisticUser? color) {
                                    setState(() {
                                      updatePieChart();
                                    });
                                  },
                                  menuStyle: MenuStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        AppTheme()
                                            .getTheme()
                                            .colorScheme
                                            .surfaceContainerLow),
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  dropdownMenuEntries: monthStadistic.map<
                                          DropdownMenuEntry<
                                              MonthStadisticUser>>(
                                      (MonthStadisticUser mes) {
                                    return DropdownMenuEntry<
                                        MonthStadisticUser>(
                                      value: mes,
                                      label: mes.mes,
                                      style: ButtonStyle(
                                        padding: WidgetStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0)),
                                        textStyle: WidgetStateProperty.all(
                                            styleText.labelSmall),
                                      ),

                                      //enabled: color.label != 'Grey',
                                    );
                                  }).toList(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 100,
                                      child: SfCircularChart(
                                        tooltipBehavior: _tooltip,
                                        series: <CircularSeries>[
                                          // Render pie chart

                                          PieSeries<PieData, String>(
                                            dataSource: data,
                                            pointColorMapper:
                                                (PieData data, _) => data.color,
                                            xValueMapper: (PieData data, _) =>
                                                data.label,
                                            yValueMapper: (PieData data, _) =>
                                                data.x,
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppTheme()
                                            .getTheme()
                                            .colorScheme
                                            .surfaceContainerHigh,
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                          'La asistencia ha sido mejor o igual al ${selected.percentile}%',
                                          style: styleText.labelSmall,
                                          overflow: TextOverflow.visible),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  );
                }
              },
            ),
          ),
        ));
  }
}

Widget textAlert(String label, String value) {
  return Row(
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      Text(value),
    ],
  );
}

class PieData {
  PieData(this.color, this.x, this.label);
  final Color color;
  final int x;
  final String label;
}
