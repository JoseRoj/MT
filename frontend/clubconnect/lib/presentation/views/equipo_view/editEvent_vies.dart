import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/insfrastructure/models/eventoStadistic.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/OvalImage.dart';
import 'package:clubconnect/presentation/widget/cuppertioDate.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:clubconnect/presentation/widget/modalSelect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EditEventWidget extends ConsumerStatefulWidget {
  final EventoFull evento;
  final DateTime fechaEdit;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final String? descripcionEdit;
  final List<User> miembros;
  final String? tituloEdit;
  final String? lugarEdit;

  final List<Asistente>? asistentes;
  final int? eventId;
  final int idequipo;
  final dynamic styleText;
  ValueNotifier<int> indexNotifier;
  final Future<void> Function() getEventosCallback;

  EditEventWidget({
    super.key,
    required this.evento,
    required this.fechaEdit,
    required this.horaInicio,
    required this.horaFin,
    required this.descripcionEdit,
    required this.tituloEdit,
    required this.miembros,
    required this.lugarEdit,
    required this.asistentes,
    required this.eventId,
    required this.idequipo,
    required this.styleText,
    required this.indexNotifier,
    required this.getEventosCallback,
  });

  @override
  EditEventWidgetState createState() => EditEventWidgetState();
}

class EditEventWidgetState extends ConsumerState<EditEventWidget> {
  final TextEditingController controllerDescriptionEdit =
      TextEditingController();
  final TextEditingController controllerTitleEdit = TextEditingController();
  final TextEditingController controllerLugarEdit = TextEditingController();
  late DateTime _fechaEdit;
  late String _horaInicio;
  late String _horaFin;
  late String descripcionEdit;
  late List<Asistente>? _asistentes;
  late List<int>? _asistentesId;
  final DataGridController _dataGridController = DataGridController();
  List<dynamic> miembros = [];
  late DataSource _employeeDataSource;
  late DataSource _miembrosDataSource;
  @override
  void initState() {
    super.initState();
    print("Entre EditEventWidget");
    _fechaEdit = widget.evento.evento.fecha;
    _horaInicio = widget.evento.evento.horaInicio;
    _horaFin = widget.evento.evento.horaFinal;
    _asistentes = widget.evento.asistentes;
    controllerDescriptionEdit.text = widget.evento.evento.descripcion ?? "";
    controllerTitleEdit.text = widget.evento.evento.titulo ?? "";
    controllerLugarEdit.text = widget.evento.evento.lugar ?? "";
    _employeeDataSource = DataSource(AsistentesData: _asistentes!);
    miembros = widget.miembros
        .where((element) =>
            !_employeeDataSource.doesRowExist(element.id.toString()))
        .toList();

    _miembrosDataSource = DataSource(AsistentesData: miembros);
  }

  void dispose() {
    controllerDescriptionEdit.dispose();
    controllerTitleEdit.dispose();
    controllerLugarEdit.dispose();
    _employeeDataSource._employeeData.clear();
    super.dispose();
  }

  void addMiembro(DataGridRow asistente) {
    _miembrosDataSource._employeeData.remove(asistente);
    _employeeDataSource._employeeData.add(asistente);
    _employeeDataSource.updateDataGridSource();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Evento"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              formInput(
                label: "Titulo",
                controller: controllerTitleEdit,
                validator: (value) => emptyOrNull(value, "titulo"),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.70,
                child: ElevatedButton.icon(
                  label: Text(DateFormat('dd / MM / yyyy').format(_fechaEdit),
                      style: widget.styleText.labelMedium),
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton.icon(
                    label: Text("${_horaInicio}",
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
                            convertirStringATimeOfDay(_horaFin).hour,
                            convertirStringATimeOfDay(_horaInicio).minute,
                          ),
                          onDateTimeChanged: (DateTime newDateTime) {
                            setState(() {
                              _horaInicio = TimeOfDay.fromDateTime(newDateTime)
                                  .format(context);
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
                    label: Text("${_horaFin}",
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
                              _horaFin = TimeOfDay.fromDateTime(newDateTime)
                                  .format(context);
                              print(_horaFin);
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
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SfDataGrid(
                  rowHeight: 40,
                  allowSwiping: true,
                  endSwipeActionsBuilder:
                      (BuildContext context, DataGridRow row, int rowIndex) {
                    return GestureDetector(
                        onTap: () {
                          _employeeDataSource._employeeData.removeAt(rowIndex);
                          _miembrosDataSource._employeeData.add(row);
                          _employeeDataSource.updateDataGridSource();
                        },
                        child: Container(
                            color: Colors.redAccent,
                            child: const Center(
                              child: Icon(Icons.delete),
                            )));
                  },
                  headerRowHeight: 35,
                  source: _employeeDataSource,
                  showCheckboxColumn: false,
                  controller: _dataGridController,
                  columns: [
                    GridColumn(
                      visible: false,
                      columnName: "ID",
                      label: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'id',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    GridColumn(
                      minimumWidth: MediaQuery.of(context).size.width * 0.9,
                      maximumWidth: MediaQuery.of(context).size.width * 0.9,
                      columnName: 'Miembros',
                      label: Container(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ASISTENTES',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            IconButton.filledTonal(
                                color: AppTheme().getTheme().primaryColor,
                                padding: const EdgeInsets.only(bottom: 0),
                                onPressed: () async {
                                  final response = await modalSelected(
                                      const Text("Selecciona los asistentes",
                                          style: TextStyle(fontSize: 20)),
                                      context,
                                      _miembrosDataSource,
                                      _employeeDataSource,
                                      addMiembro);
                                },
                                icon: const Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () async {
            List<int> _asistentesId = [];
            _employeeDataSource._employeeData.forEach((element) {
              bool _isInList = _asistentesId
                  .contains(int.parse(element.getCells().first.value));
              if (!_isInList) {
                _asistentesId.add(int.parse(element.getCells().first.value));
              }
            });

            print(_asistentesId);
            final response = await ref.read(clubConnectProvider).editEvento(
                _fechaEdit.toIso8601String(),
                _horaInicio,
                controllerDescriptionEdit.text,
                _horaFin,
                widget.eventId!,
                controllerTitleEdit.text,
                controllerLugarEdit.text,
                _asistentesId!);

            if (response == true) {
              await widget.getEventosCallback();
              widget.indexNotifier.value = 0;

              // ignore: use_build_context_synchronously
              customToast("Evento Editado con éxito", context, "isSuccess");
              setState(() {});
            } else {
              // ignore: use_build_context_synchronously
              customToast("Error al editar el evento", context, "isError");
            }
          }),
    );
  }
}

class DataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  DataSource({required List<dynamic> AsistentesData}) {
    _employeeData = AsistentesData.map<DataGridRow>((e) => DataGridRow(cells: [
          DataGridCell<String>(columnName: 'ID', value: e.id),
          DataGridCell<String>(
              columnName: 'Nombre',
              value: e.nombre + " " + e.apellido1 + " " + e.apellido2 ?? ""),
        ])).toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ImageOval("", null, 30, 30),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.center,
            child: Text(
              e.value.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }).toList());
  }

  void updateDataGridSource() {
    notifyListeners();
  }

  bool doesRowExist(String id) {
    return _employeeData.any((row) {
      final idCell =
          row.getCells().firstWhere((cell) => cell.columnName == 'ID');
      return idCell.value == id;
    });
  }
}
