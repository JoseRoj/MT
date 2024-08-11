import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
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
  final Future<void> Function(String estado, bool? pullRefresh)
      getEventosCallback;

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
  TimeOfDay _selectedTimeInicio = TimeOfDay.now();
  TimeOfDay _selectedTimeFin = TimeOfDay.now();
  bool selectTimeInicio = false;
  bool selectTimeFin = false;

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
        title: const Text("Crear Evento"),
        centerTitle: true,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
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
                      ),
                    ],
                  ),
                ),
                Container(
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
              ],
            ),
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
                  if (!selectTimeInicio || !selectTimeFin) {
                    customToast("Seleccione una hora", context, "isError");
                    return;
                  }
                  final fechas =
                      _dates.map((e) => e!.toIso8601String()).toList();

                  final response = await ref
                      .read(clubConnectProvider)
                      .createEvento(
                          fechas,
                          _selectedTimeInicio.format(context),
                          controllerDes.text,
                          _selectedTimeFin.format(context),
                          widget.idequipo,
                          widget.idclub,
                          controllerName.text,
                          controllerLugar.text);

                  if (response == true) {
                    customToast(
                        "Evento Registrado con éxito", context, "isSuccess");
                    await widget.getEventosCallback(EstadosEventos.todos, true);
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
