import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/eventosActivos_provider.dart';
import 'package:clubconnect/presentation/screens/equipo_screen.dart';
import 'package:clubconnect/presentation/widget/asistentes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CardEvento extends ConsumerStatefulWidget {
  //List<EventoFull?>? eventos;
  int idequipo;
  MonthYear dateSelected;
  EventoFull? eventoSelected;
  DateTime endDate;
  final Function(String id) updateEventoSelectedCallback;
  /*final Future<List<EventoFull>?> Function(String estado, bool? pullRefresh,
      DateTime? initDate, int month, int year) getEventosCallback;*/
  CardEvento({
    super.key,
    required this.updateEventoSelectedCallback,

    //required this.eventos,
    required this.eventoSelected,
    required this.dateSelected,
    required this.idequipo,
    required this.endDate,
/*    required this.getEventosCallback,
    required this.updateEventoSelectedCallback,*/
  });

  @override
  CardEventoState createState() => CardEventoState();
}

class CardEventoState extends ConsumerState<CardEvento> {
  var more = false;

  //List<EventoFull?>? eventos;
  TextTheme styleText = AppTheme().getTheme().textTheme;
  @override
  void initState() {
    print("CardEventoState initState");
    // eventos = widget.eventos;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic eventos = ref.read(eventosActivosProvider);
    print("CardEventoState build ${widget.eventoSelected}");
    print("CardEvento + ${eventos.isEmpty}}");
    final theme = AppTheme().getTheme();
    return Column(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 220,
        child: eventos!.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 100, color: Colors.grey),
                    Text("No hay eventos",
                        style: TextStyle(fontSize: 20, color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: eventos!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      widget.eventoSelected = eventos![index];
                      /*widget.updateEventoSelectedCallback(
                          widget.eventos![index]!);
*/
                      /*eventoSelected =
                    widget.updateEventoSelectedCallback(eventos![index]!);*/
                      setState(() {});
                    },
                    child: Container(
                        padding: const EdgeInsets.all(1),
                        margin: index == 0
                            ? const EdgeInsets.only(
                                left: 10, bottom: 10, top: 10)
                            : const EdgeInsets.only(
                                left: 10, top: 10, bottom: 10),
                        width: 150,
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 1),
                              ),
                            ],
                            color: AppTheme().getTheme().primaryColor,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.primaryColor,
                                theme.primaryColorLight
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(children: [
                              Text(
                                "${eventos![index]!.evento.fecha.day} ${Months.where((element) => element.value == eventos![index]!.evento.fecha.month).first.mes}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                eventos![index]!.evento.titulo,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                            Column(children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.group),
                                    const SizedBox(width: 5), // Espacio
                                    Text(
                                        eventos![index]!
                                            .asistentes
                                            .length
                                            .toString(),
                                        style: styleText.labelSmall,
                                        textAlign: TextAlign.center),
                                  ]),
                              Text(
                                  "${eventos![index]!.evento.horaInicio.substring(0, 5)} - ${eventos![index]!.evento.horaFinal.substring(0, 5)}",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black)),
                            ])
                          ],
                        )),
                  );
                },
              ),
      ),
      widget.eventoSelected != null
          ? Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.6, // Ajusta según sea necesario
              ),
              child: SingleChildScrollView(
                child: event(widget.eventoSelected),
              ),
            )
          : Container(),
    ]);
  }

  Widget event(EventoFull? evento) {
    String buttonText = evento!.asistentes.where((element) {
      return int.parse(element.id) == ref.read(authProvider).id;
    }).isEmpty
        ? "Asistir"
        : "Cancelar";
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(66, 85, 85, 85), // Shadow color
              blurRadius: 10, // Blur radius
              offset: Offset(0, 4), // Shadow position
            ),
          ],
        ),
        child: Column(
          children: [
            Text(evento.evento.titulo,
                style: styleText.titleSmall, textAlign: TextAlign.center),
            Text(DateFormat('dd / MM / yyyy').format(evento.evento.fecha),
                style: styleText.labelSmall),
            Text(evento.evento.descripcion,
                style: styleText.bodyMedium, textAlign: TextAlign.center),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_pin),
                Flexible(
                  child: Text(
                    evento.evento.lugar,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            AttendeesList(asistentes: evento.asistentes),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width,
              child: FilledButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                      buttonText == "Asistir"
                          ? const Color.fromARGB(255, 117, 204, 124)
                          : const Color.fromARGB(255, 237, 65, 65)),
                ),
                onPressed: () async {
                  if (buttonText == "Cancelar") {
                    var response = await ref
                        .read(clubConnectProvider)
                        .deleteAsistencia(int.parse(evento.evento.id!),
                            ref.read(authProvider).id!);
                    if (response) {
                      buttonText = "Asistir";
                      await ref
                          .watch(eventosActivosProvider.notifier)
                          .getEventosActivos(
                              widget.idequipo,
                              DateTime.now(),
                              widget.dateSelected.month,
                              widget.dateSelected
                                  .year); /*List<EventoFull>? response =
                          await widget.getEventosCallback(
                              EstadosEventos.activo,
                              false,
                              DateTime.now(),
                              widget.dateSelected.month,
                              widget.dateSelected.year);*/
                      /*widget.eventoSelected = ref
                          .read(eventosActivosProvider)!
                          .firstWhere((element) {
                        return element.evento.id == evento.evento.id;
                      });*/
                      setState(() {
                        widget.updateEventoSelectedCallback(evento.evento.id);

                        //widget.eventos = response;
                        //eventos = response;
                      });
                      // ignore: use_build_context_synchronously
                      customToast("Asistencia cancelada con éxito", context,
                          "isSuccess");
                      setState(() {});
                    } else {
                      customToast(
                          "Error al cancelar asistencia", context, "isError");
                    }
                  } else {
                    var response = await ref
                        .read(clubConnectProvider)
                        .addAsistencia(int.parse(evento.evento.id!),
                            ref.read(authProvider).id!);
                    if (response) {
                      buttonText = "Cancelar";
                      await ref
                          .watch(eventosActivosProvider.notifier)
                          .getEventosActivos(
                              widget.idequipo,
                              DateTime.now(),
                              widget.dateSelected.month,
                              widget.dateSelected.year);
                      /*                    final response = await widget.getEventosCallback(
                          EstadosEventos.activo,
                          false,
                          DateTime.now(),
                          widget.dateSelected.month,
                          widget.dateSelected.year);
*/
                      /*final response = await ref
                          .read(clubConnectProvider)
                          .getEventos(
                              widget.idequipo,
                              EstadosEventos.activo,
                              DateTime.now(),
                              widget.dateSelected.month,
                              widget.dateSelected.year);*/
                      setState(() {
                        widget.updateEventoSelectedCallback(evento.evento.id);
                        /*widget.eventoSelected = response!.firstWhere((element) {
                          return element.evento.id == evento.evento.id;
                        });
                        widget.eventos = response;*/
                        //eventos = response;
                      });
                      // ignore: use_build_context_synchronously
                      customToast("Asistencia registrada con éxito", context,
                          "isSuccess");
                    } else {
                      customToast(
                          "Error al registrar asistencia", context, "isError");
                    }
                  }
                },
                icon: buttonText == "Asistir"
                    ? const Icon(Icons.check)
                    : const Icon(Icons.cancel),
                label: Text(buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*GestureDetector(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 35),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // Shadow color
                      blurRadius: 10, // Blur radius
                      offset: Offset(0, 4), // Shadow position
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            widget.eventos![index]!.evento.titulo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Container(
                            width: 40,
                            child: Row(children: [
                              const Icon(Icons.group),
                              SizedBox(width: 5), // Espacio
                              Text(
                                  widget.eventos![index]!.asistentes.length
                                      .toString(),
                                  style: styleText.labelSmall),
                            ])),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            DateFormat('dd / MM / yyyy')
                                .format(widget.eventos![index]!.evento.fecha),
                            style: styleText.labelSmall),
                        Text(
                            "${widget.eventos![index]!.evento.horaInicio} - ${widget.eventos![index]!.evento.horaFinal}",
                            style: styleText.labelSmall),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Lugar : ${widget.eventos![index]!.evento.lugar}",
                          style: styleText.labelSmall,
                          textAlign: TextAlign.left,
                        )
                      ],
                    )
                  ],
                )),
            onTap: () async {
              if (widget.eventos![index]!.asistentes.isEmpty) {
                widget.buttonText = "Asistir";
              } else {
                for (int i = 0;
                    i < widget.eventos![index]!.asistentes.length;
                    i++) {
                  if (int.parse(widget.eventos![index]!.asistentes[i].id) ==
                      ref.read(authProvider).id) {
                    widget.buttonText = "Cancelar";
                    break;
                  } else {
                    widget.buttonText = "Asistir";
                  }
                }
              }
              await showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  print("jojo");
                  return SingleChildScrollView(
                    child: StatefulBuilder(
                        builder: (context, StateSetter setModalState) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.eventos![index]!.evento.titulo,
                              style: styleText.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd / MM / yyyy')
                                  .format(widget.eventos![index]!.evento.fecha),
                              style: styleText.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${widget.eventos![index]!.evento.horaInicio} - ${widget.eventos![index]!.evento.horaFinal}",
                                  style: styleText.bodyMedium,
                                ),
                              ],
                            ),
                            Text(
                              "${widget.eventos![index]!.evento.lugar}",
                              style: styleText.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.eventos![index]!.evento.descripcion,
                              style: styleText.bodyMedium,
                            ),
                            widget.eventos![index]!.asistentes.isEmpty
                                ? const SizedBox()
                                : Row(
                                    children: [
                                      Text("Asistentes : ",
                                          textAlign: TextAlign.left,
                                          style: styleText.labelSmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height:
                                  150, // Ajusta la altura según sea necesario
                              child: arrayAsistentes,
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: MediaQuery.of(context).size.width,
                              child: FilledButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      widget.buttonText == "Asistir"
                                          ? const Color.fromARGB(
                                              255, 117, 204, 124)
                                          : const Color.fromARGB(
                                              255, 237, 65, 65)),
                                ),
                                onPressed: () async {
                                  if (widget.buttonText == "Cancelar") {
                                    var response = await ref
                                        .read(clubConnectProvider)
                                        .deleteAsistencia(
                                            int.parse(widget
                                                .eventos![index]!.evento.id!),
                                            ref.read(authProvider).id!);
                                    if (response) {
                                      widget.buttonText = "Asistir";
                                      widget.eventos = (await ref
                                          .read(clubConnectProvider)
                                          .getEventos(
                                              widget.idequipo,
                                              EstadosEventos.activo,
                                              DateTime.now(),
                                              widget.endDate));
                                      // ignore: use_build_context_synchronously
                                      customToast(
                                          "Asistencia cancelada con éxito",
                                          context,
                                          "isSuccess");
                                      setModalState(() {});
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    } else {
                                      customToast(
                                          "Error al cancelar asistencia",
                                          context,
                                          "isError");
                                    }
                                  } else {
                                    var response = await ref
                                        .read(clubConnectProvider)
                                        .addAsistencia(
                                            int.parse(widget
                                                .eventos![index]!.evento.id!),
                                            ref.read(authProvider).id!);
                                    if (response) {
                                      widget.buttonText = "Cancelar";
                                      widget.eventos = await ref
                                          .read(clubConnectProvider)
                                          .getEventos(
                                              widget.idequipo,
                                              EstadosEventos.activo,
                                              DateTime.now(),
                                              widget.endDate);
                                      setModalState(() {});
                                      setState(() {});
                                      // ignore: use_build_context_synchronously
                                      customToast(
                                          "Asistencia registrada con éxito",
                                          context,
                                          "isSuccess");
                                      Navigator.of(context).pop();
                                    } else {
                                      customToast(
                                          "Error al registrar asistencia",
                                          context,
                                          "isError");
                                    }
                                  }
                                },
                                icon: widget.buttonText == "Asistir"
                                    ? const Icon(Icons.check)
                                    : const Icon(Icons.cancel),
                                label: Text(widget.buttonText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              );
            },
          );*/