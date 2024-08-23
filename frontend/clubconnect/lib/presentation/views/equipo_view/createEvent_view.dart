import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models/equipo.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateEventWidget extends ConsumerStatefulWidget {
  final ValueNotifier<int> indexNotifier;
  final int idequipo;
  final Equipo equipo;
  final int idclub;
  final dynamic styleText;
  final Future<void> Function(
      String estado, bool? pullRefresh, int month, int year) getEventosCallback;

  CreateEventWidget({
    super.key,
    required this.indexNotifier,
    required this.equipo,
    required this.idequipo,
    required this.idclub,
    required this.styleText,
    required this.getEventosCallback,
  });

  @override
  CreateEventWidgetState createState() => CreateEventWidgetState();
}

class CreateEventWidgetState extends ConsumerState<CreateEventWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDes = TextEditingController();
  final TextEditingController controllerLugar = TextEditingController();
  List<DateTime?> _dates = [];
  TimeOfDay? _selectedTimeInicio;
  TimeOfDay? _selectedTimeFin;

  ThemeData style = AppTheme().getTheme();

  Future<bool?> _showDialog(Widget child) async {
    final response = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: child),
    );
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crear Evento", style: style.textTheme.titleSmall),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.indexNotifier.value = 0;
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.multi,
              ),
              value: _dates,
              onValueChanged: (dates) => setState(() {
                _dates = dates;
              }),
            ),
            const Text(
              "Horario Inicio & Término",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton.icon(
                  label: Text(
                      _selectedTimeInicio != null
                          ? _selectedTimeInicio!.format(context)
                          : "",
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                  icon: const Icon(Icons.access_time, size: 12),
                  onPressed: () async {
                    if (_selectedTimeInicio == null) {
                      _selectedTimeInicio = TimeOfDay.now();
                      setState(() {});
                    }
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (context) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        height: 150,
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            initialDateTime: _selectedTimeInicio != null
                                ? dateTimeWithHourSpecific(_selectedTimeInicio!)
                                : DateTime.now(),
                            onDateTimeChanged: (DateTime newDateTime) {
                              _selectedTimeInicio =
                                  TimeOfDay.fromDateTime(newDateTime);
                              setState(() {});
                              (() {});
                              /*setState(() {
                                    _horaFin = TimeOfDay.fromDateTime(newDateTime)
                                        .format(context);
                                    print(_horaFin);*/
                            }),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton.icon(
                  label: Text(
                      _selectedTimeFin != null
                          ? _selectedTimeFin!.format(context)
                          : "",
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                  icon: const Icon(Icons.access_time, size: 12),
                  onPressed: () async {
                    if (_selectedTimeFin == null) {
                      _selectedTimeFin = TimeOfDay.now();
                      setState(() {});
                    }
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (context) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        height: 150,
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            initialDateTime: _selectedTimeFin != null
                                ? dateTimeWithHourSpecific(_selectedTimeFin!)
                                : DateTime.now(),
                            onDateTimeChanged: (DateTime newDateTime) {
                              _selectedTimeFin =
                                  TimeOfDay.fromDateTime(newDateTime);
                              setState(() {});
                              /*setState(() {
                                    _horaFin = TimeOfDay.fromDateTime(newDateTime)
                                        .format(context);
                                    print(_horaFin);*/
                            }),
                      ),
                    );
                  },
                ),
              ),
            ]),
            /*Container(
                        width: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text(
                          "Hora Inicio  ",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        child: FilledButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              )),
                          onPressed: () async {
                            final response = await _showDialog(
                              CupertinoDatePicker(
                                use24hFormat: true,
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: selectTimeInicio
                                    ? DateTime(
                                        2021,
                                        1,
                                        1,
                                        _selectedTimeInicio.hour,
                                        _selectedTimeInicio.minute)
                                    : DateTime.now(),
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setState(() {
                                    _selectedTimeInicio =
                                        TimeOfDay.fromDateTime(newDateTime);
                                    selectTimeInicio = true;
                                  });
                                },
                              ),
                            );
                            if (response == null) {
                              setState(() {});
                            }
                          },
                          child: selectTimeInicio
                              ? Text(_selectedTimeInicio.format(context))
                              : const Text("Hora"),
                        ),
                      ),*/

            /*Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child:
                            const Text("Hora Fin", textAlign: TextAlign.center),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        child: FilledButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              )),
                          onPressed: () async {
                            final response = await _showDialog(
                              CupertinoDatePicker(
                                use24hFormat: true,
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: selectTimeFin
                                    ? DateTime(
                                        2021,
                                        1,
                                        1,
                                        _selectedTimeFin.hour,
                                        _selectedTimeFin.minute)
                                    : DateTime.now(),
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setState(() {
                                    _selectedTimeFin =
                                        TimeOfDay.fromDateTime(newDateTime);
                                    selectTimeFin = true;
                                  });
                                },
                              ),
                            );
                            if (response == null) {
                              setState(() {});
                            }
                          },
                          child: selectTimeFin
                              ? Text("${_selectedTimeFin.format(context)}")
                              : const Text("Hora"),
                        ),
                      ),
                    ],
                  ),
                )
              */

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    formInput(
                        label: "Nombre Evento",
                        controller: controllerName,
                        validator: (value) => emptyOrNull(value, "nombre")),
                    formInput(
                        label: "Descripción del evento",
                        controller: controllerDes,
                        maxLines: 3,
                        validator: (value) =>
                            emptyOrNull(value, "descripción")),
                    formInput(
                        label: "Lugar Evento",
                        controller: controllerLugar,
                        validator: (value) => emptyOrNull(value, "lugar")),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              label: Text("Crear Evento", style: widget.styleText.labelMedium),
              icon: const Icon(Icons.add),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_dates.isEmpty) {
                    customToast("Seleccione una fecha", context, "isError");
                    return;
                  }
                  if (_selectedTimeInicio == null || _selectedTimeFin == null) {
                    customToast("Seleccione una hora", context, "isError");
                    return;
                  }
                  final fechas =
                      _dates.map((e) => e!.toIso8601String()).toList();

                  final response = await ref
                      .read(clubConnectProvider)
                      .createEvento(
                          fechas,
                          _selectedTimeInicio!.format(context),
                          controllerDes.text,
                          _selectedTimeFin!.format(context),
                          widget.idequipo,
                          widget.idclub,
                          controllerName.text,
                          controllerLugar.text);

                  if (response == true) {
                    customToast(
                        "Evento Registrado con éxito", context, "isSuccess");
                    await widget.getEventosCallback(EstadosEventos.todos, true,
                        DateTime.now().month, DateTime.now().year);
                  } else {
                    customToast(
                        "Error al registrar evento", context, "isError");
                  }
                  setState(() {
                    widget.indexNotifier.value = 0;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
