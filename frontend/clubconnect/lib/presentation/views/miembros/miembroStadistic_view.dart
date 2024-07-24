import 'dart:typed_data';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UserStadistic extends StatefulWidget {
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
  State<UserStadistic> createState() => _UserStadisticState();
}

class _UserStadisticState extends State<UserStadistic> {
  Uint8List? imageUser;
  TextTheme styleText = AppTheme().getTheme().textTheme;
  List<SalesData> data = [
    SalesData('Agos', 12, 30),
    SalesData('Sept', 15, 20),
    SalesData('Oct', 30, 20),
    SalesData('Nov', 6.4, 19),
    SalesData('Dic', 14, 49)
  ];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    imageUser = imagenFromBase64(widget.usuario.imagen);

    _tooltip = TooltipBehavior(enable: true);

    super.initState();
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
      body: Column(children: [
        Row(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ImageOval(widget.usuario.imagen, imageUser, 70, 70)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${widget.usuario.nombre} ${widget.usuario.apellido1} ${widget.usuario.apellido2}",
                    style: styleText.labelMedium),
                Text("Deportista ", style: styleText.labelSmall),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        SizedBox(
          width: 300,
          height: 250,
          child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(
                //title: AxisTitle(text: 'Mes'),
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: const NumericAxis(title: AxisTitle(text: 'Evento')),
              // Chart title
              title: const ChartTitle(
                  text: 'Asistencia Eventos Ultimos 6 meses',
                  textStyle: TextStyle(fontSize: 10)),
              // Enable legend
              legend: const Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: _tooltip,
              series: <CartesianSeries>[
                StackedColumnSeries<SalesData, String>(
                    name: 'Asistencias',
                    dataLabelMapper: (datum, index) =>
                        datum.countParticipations.toString(),
                    groupName: 'Participaciones',
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: false, showCumulativeValues: true),
                    dataSource: data,
                    xValueMapper: (SalesData data, _) => data.month,
                    yValueMapper: (SalesData data, _) =>
                        data.countParticipations),
                StackedColumnSeries<SalesData, String>(
                    name: 'Eventos Totales',
                    groupName: 'Total',
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true, showCumulativeValues: true),
                    dataSource: data,
                    xValueMapper: (SalesData data, _) => data.month,
                    yValueMapper: (SalesData data, _) => data.total)
              ]),
        )
      ]),
    );
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

class SalesData {
  SalesData(this.month, this.countParticipations, this.total);
  final String month;
  final double countParticipations;
  final double total;
}
