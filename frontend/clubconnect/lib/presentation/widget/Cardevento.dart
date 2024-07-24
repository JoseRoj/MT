import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/views/clubEquipos/Clubequipos.dart';
import 'package:clubconnect/presentation/widget/userlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CardEvento extends ConsumerStatefulWidget {
  List<EventoFull?>? eventos;
  String buttonText;
  int idequipo;
  DateTime endDate;
  CardEvento({
    super.key,
    required this.eventos,
    required this.buttonText,
    required this.idequipo,
    required this.endDate,
  });

  @override
  CardEventoState createState() => CardEventoState();
}

class CardEventoState extends ConsumerState<CardEvento> {
  TextTheme styleText = AppTheme().getTheme().textTheme;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: widget.eventos!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
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
            onTap: () {
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
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
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
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    widget.eventos![index]!.asistentes.length,
                                itemBuilder: (context, index2) {
                                  return userList(
                                      name: widget.eventos![index]!
                                          .asistentes[index2].nombre,
                                      image: null);
                                },
                              ),
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
          );
        },
      ),
    );
  }
}
