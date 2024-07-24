import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/cuppertioDate.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditEventWidget extends StatefulWidget {
  final DateTime fechaEdit;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final String? descripcionEdit;
  final String? tituloEdit;
  final String? lugarEdit;

  final List<Asistente>? asistentes;
  final List<int>? asistentesId;
  final int? eventId;
  final WidgetRef ref;
  final int idequipo;
  final dynamic styleText;
  ValueNotifier<int> indexNotifier;
  final Future<void> Function(String estado, bool? pullRefresh,
      DateTime? initDate, DateTime? endDate) getEventosCallback;

  EditEventWidget({
    required this.fechaEdit,
    required this.horaInicio,
    required this.horaFin,
    required this.descripcionEdit,
    required this.tituloEdit,
    required this.lugarEdit,
    required this.asistentes,
    required this.asistentesId,
    required this.eventId,
    required this.ref,
    required this.idequipo,
    required this.styleText,
    required this.indexNotifier,
    required this.getEventosCallback,
  });

  @override
  _EditEventWidgetState createState() => _EditEventWidgetState();
}

class _EditEventWidgetState extends State<EditEventWidget> {
  final TextEditingController controllerDescriptionEdit =
      TextEditingController();
  final TextEditingController controllerTitleEdit = TextEditingController();
  final TextEditingController controllerLugarEdit = TextEditingController();
  late DateTime _fechaEdit;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  late String descripcionEdit;
  late List<Asistente>? _asistentes;
  late List<int>? _asistentesId;

  @override
  void initState() {
    super.initState();
    _fechaEdit = widget.fechaEdit;
    _horaInicio = widget.horaInicio;
    _horaFin = widget.horaFin;
    _asistentes = widget.asistentes;
    _asistentesId = widget.asistentesId;
    controllerDescriptionEdit.text = widget.descripcionEdit ?? "";
    controllerTitleEdit.text = widget.tituloEdit ?? "";
    controllerLugarEdit.text = widget.lugarEdit ?? "";
  }

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            formInput(
              label: "Titulo",
              controller: controllerTitleEdit,
              validator: (value) => emptyOrNull(value, "titulo"),
            ),
            const SizedBox(height: 10),
            Text(DateFormat('dd / MM / yyyy').format(_fechaEdit),
                style: widget.styleText.bodyMedium),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: ElevatedButton.icon(
                label:
                    Text("Cambiar Fecha", style: widget.styleText.labelMedium),
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final dateResponse = await cuppertinoModal(
                      context,
                      _fechaEdit,
                      DateTime.now().subtract(const Duration(hours: 0)),
                      DateTime.now().add(const Duration(days: 365)));
                  if (dateResponse != null) {
                    setState(() {
                      _fechaEdit = dateResponse;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
                "${_horaInicio.hour}:${_horaInicio.minute}:00 - ${_horaFin.hour}:${_horaFin.minute}:00",
                style: widget.styleText.bodyMedium),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton.icon(
                  label: Text("Hora Inicio",
                      style: widget.styleText.labelMedium,
                      textAlign: TextAlign.center),
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final response = await _showDialog(
                      CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: DateTime(
                          2021,
                          1,
                          1,
                          _horaInicio.hour,
                          _horaInicio.minute,
                        ),
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() {
                            _horaInicio = TimeOfDay.fromDateTime(newDateTime);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton.icon(
                  label: Text("Hora Fin",
                      style: widget.styleText.labelMedium,
                      textAlign: TextAlign.center),
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final response = await _showDialog(
                      CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: _fechaEdit,
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() {
                            _horaFin = TimeOfDay.fromDateTime(newDateTime);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ]),
            formInput(
              label: "Lugar",
              controller: controllerLugarEdit,
              validator: (value) => emptyOrNull(value, "lugar"),
            ),
            formInput(
              label: "Descripción",
              maxLines: 3,
              controller: controllerDescriptionEdit,
              validator: (value) => emptyOrNull(value, "descripción"),
            ),
            Center(
              child: Text("Asistentes", style: widget.styleText.titleSmall),
            ),
            Container(
              padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _asistentes?.length ?? 0,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.yellow,
                    ),
                    child: ClipRect(
                      child: Dismissible(
                        key: Key(_asistentes![index].id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            _asistentesId!
                                .add(int.parse(_asistentes![index].id));
                            _asistentes!.removeAt(index);
                            // ! TODO : ELIMINAR DE LA BASE DE DATOS
                          });
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              child: CircleAvatar(
                                foregroundColor: Colors.white,
                              ),
                            ),
                            Text(
                              _asistentes![index].nombre + " ",
                              //   asistentes[index].apellido1,
                              style: widget.styleText.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: () async {
                  final response = await widget.ref
                      .read(clubConnectProvider)
                      .editEvento(
                          _fechaEdit.toIso8601String(),
                          _horaInicio.format(context),
                          controllerDescriptionEdit.text,
                          _horaFin.format(context),
                          widget.eventId!,
                          controllerTitleEdit.text,
                          controllerLugarEdit.text,
                          _asistentesId!);

                  if (response == true) {
                    await widget.getEventosCallback(
                        EstadosEventos.todos,
                        true,
                        DateTime.now(),
                        DateTime.now().add(const Duration(days: 365)));
                    widget.indexNotifier.value = 0;

                    // ignore: use_build_context_synchronously
                    customToast(
                        "Evento Editado con éxito", context, "isSuccess");
                    setState(() {});
                  } else {
                    // ignore: use_build_context_synchronously
                    customToast(
                        "Error al editar el evento", context, "isError");
                  }
                },
                child: Text("Guardar Cambios",
                    style: widget.styleText.labelMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
