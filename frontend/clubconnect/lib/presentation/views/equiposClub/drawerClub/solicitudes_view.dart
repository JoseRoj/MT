import 'dart:ui';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/solicitud.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/widget/solicitud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class SolicitudesWidget extends ConsumerStatefulWidget {
  static const String name = 'SolicitudesWidget';
  final int idclub;
  late List<Solicitud> solicitudes;
  late List<Equipo> equipos;

  /*late Future<List<Equipo>> futureequipos;
  late List<Equipo> equipos;
  late Future<List<Solicitud>> futuresolicitudes;
  late List<Solicitud> solicitudes;
  final Future<List<Solicitud>> Function() solicitudesCallBack;*/
  SolicitudesWidget({
    Key? key,
    required this.idclub,
    required this.solicitudes,
    required this.equipos,

    /*required this.futuresolicitudes,
    required this.solicitudes,
    required this.equipos,
    required this.futureequipos,
    required this.solicitudesCallBack,*/
  }) : super(key: key);

  @override
  _SolicitudesWidgetState createState() => _SolicitudesWidgetState();
}

class _SolicitudesWidgetState extends ConsumerState<SolicitudesWidget> {
  final _controllerTipo = MultiSelectController();
  final MultiSelectController _controllerEquipo = MultiSelectController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Solicitud> solicitudes;
  late List<Equipo> equipos;
  final tipos = [
    (id: 1, nombre: "Deportista"),
    (id: 2, nombre: "Entrenador"),
  ];

  @override
  void initState() {
    solicitudes = widget.solicitudes;
    equipos = widget.equipos;
    super.initState();
  }

  Future<List<Solicitud>> getSolicitud() async {
    final response = await ref.read(clubConnectProvider).getSolicitudes(
        widget.idclub); // Simula un proceso de carga o actualización de datos
    print("solicitudes" + response.toString());
    setState(() {
      solicitudes = response;
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    print("Solicitudes: ${solicitudes.length}");
    /*return FutureBuilder(
        future: Future.wait([_futuresolicitudes, _futureequipos]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:*/

    return RefreshIndicator(
      onRefresh: () async {
        solicitudes = await getSolicitud();
        setState(() {});
      },
      child: solicitudes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 100, color: Colors.grey),
                  Text("No hay solicitudes ",
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: solicitudes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: solicitud(solicitudes[index], context),
                  onTap: () async {
                    /*showInfoSolicitud(
                            context,
                            solicitudes[index],
                            _controllerEquipo,
                            equipos,
                            ref,
                            widget.idclub,
                            solicitudes);*/
                    final response = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              content: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                    "${solicitudes[index].nombre} ${solicitudes[index].apellido1} ${solicitudes[index].apellido2} ha enviado una solicitud de unión al Club el ${DateToString(solicitudes[index].fechaSolicitud) ?? ""}",
                                    style: AppTheme()
                                        .getTheme()
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ),
                                textAlert(
                                    "Fecha de Nacimiento: ",
                                    DateToString(
                                        solicitudes[index].fechaNacimiento)),
                                textAlert(
                                    "Genero: ", solicitudes[index].genero),
                                textAlert("Correo: ", solicitudes[index].email),
                                textAlert(
                                    "Teléfono: ", solicitudes[index].telefono),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  child: MultiSelectDropDown<dynamic>(
                                    hint: "Selecciona las categorías",
                                    inputDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black54,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    //showClearIcon: true,
                                    controller: _controllerEquipo,
                                    onOptionSelected: (options) {
                                      //debugPrint(options.toString());
                                    },
                                    options: equipos
                                        .map((Equipo item) => ValueItem(
                                            label: item.nombre.toString(),
                                            value: item.id.toString()))
                                        .toList(),
                                    selectionType: SelectionType.multi,
                                    chipConfig: const ChipConfig(
                                        wrapType: WrapType.scroll),
                                    dropdownHeight: 300,
                                    optionTextStyle:
                                        const TextStyle(fontSize: 16),
                                    selectedOptionIcon:
                                        const Icon(Icons.check_circle),
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  child: MultiSelectDropDown(
                                    hint: "Selecciona el rol",
                                    inputDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black54,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    //showClearIcon: true,
                                    controller: _controllerTipo,
                                    onOptionSelected: (options) {
                                      //debugPrint(options.toString());
                                    },
                                    options: tipos
                                        .map((item) => ValueItem(
                                              label: item.nombre,
                                              value: item.id,
                                            ))
                                        .toList(),

                                    selectionType: SelectionType.single,
                                    chipConfig: const ChipConfig(
                                        wrapType: WrapType.scroll),
                                    dropdownHeight: tipos.length * 50.0,
                                    optionTextStyle:
                                        const TextStyle(fontSize: 16),
                                    selectedOptionIcon:
                                        const Icon(Icons.check_circle),
                                  ),
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FilledButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.green)),
                                        onPressed: () async {
                                          if (_controllerEquipo!
                                                  .selectedOptions.isEmpty ||
                                              _controllerTipo
                                                  .selectedOptions.isEmpty) {
                                            print(
                                                "No se ha seleccionado un equipo o un rol");
                                          } else {
                                            final response = await ref
                                                .read(clubConnectProvider)
                                                .acceptSolicitud(
                                                    _controllerEquipo
                                                        .selectedOptions
                                                        .map((e) => e.value)
                                                        .toList(),
                                                    int.parse(
                                                        solicitudes[index].id),
                                                    _controllerTipo
                                                        .selectedOptions[0]
                                                        .label,
                                                    widget.idclub);
                                            if (response == true) {
                                              solicitudes = solicitudes
                                                  .where((element) =>
                                                      element.id !=
                                                      solicitudes[index].id)
                                                  .toList();
                                              //setState(() {});
                                              return Navigator.of(context)
                                                  .pop(true);
                                            }
                                          }
                                          // Acción cuando se presiona el botón
                                        },
                                        child: Text('Aceptar',
                                            style: AppTheme()
                                                .getTheme()
                                                .textTheme
                                                .bodyMedium),
                                      ),
                                      FilledButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 204, 78, 69)),
                                        ),
                                        onPressed: () async {
                                          await ref
                                              .read(clubConnectProvider)
                                              .updateSolicitud(
                                                  int.parse(
                                                      solicitudes[index].id),
                                                  widget.idclub,
                                                  "Cancelada");
                                          Navigator.of(context).pop();

                                          // Acción cuando se presiona el botón
                                        },
                                        child: Text('Rechazar',
                                            style: AppTheme()
                                                .getTheme()
                                                .textTheme
                                                .bodyMedium),
                                      ),
                                    ]),
                              ]),
                            );
                          }),
                        );
                      },
                    );
                    print("Resp ${response}");
                    if (response == true) {
                      print("Se aceptó la solicitud");
                      setState(() {});
                    }
                    // Acción cuando se presiona el ListTile
                  },
                );
              },
            ),
    );
    /*case ConnectionState.none:
              return const Text('none');
            case ConnectionState.active:
              return const Text('active');
          }
        });*/
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
