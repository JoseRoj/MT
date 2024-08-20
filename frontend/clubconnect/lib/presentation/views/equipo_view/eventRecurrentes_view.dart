import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/globales.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/helpers/validator.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventRecurrentes extends ConsumerStatefulWidget {
  const EventRecurrentes({super.key});

  @override
  EventRecurrentesState createState() => EventRecurrentesState();
}

class EventRecurrentesState extends ConsumerState<EventRecurrentes> {
  ThemeData theme = AppTheme().getTheme();
  final keyForm = GlobalKey<FormState>();
  final TextEditingController controllerDescriptionEdit =
      TextEditingController();
  final TextEditingController controllerTitleEdit = TextEditingController();
  final TextEditingController controllerLugarEdit = TextEditingController();
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  String? selectedDay;
  DateTime? dateInitial;
  DateTime? dateEnd;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Recurrentes'),
      ),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton.icon(
              onPressed: () {
                modalCreateRecurrentEvent();
              },
              label: Text('Crear Evento Recurrente',
                  style: theme.textTheme.labelSmall),
              icon: const Icon(Icons.add),
            )
          ]),
          cardEventoRecurrente(),
        ],
      ),
    );
  }

  Widget cardEventoRecurrente() {
    print("Holaaaa");
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.surfaceContainerLow
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Titulo",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            "Descripción : ",
            style: theme.textTheme.bodyMedium,
          ),
          Text("Cada Martes desde las 10:00 hasta las 12:00"),
          Text("Lugar : Gancha el rosario"),
          Text("Fecha"),
        ],
      ),
    );
  }

  void modalCreateRecurrentEvent() {
    var decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Color.fromARGB(255, 165, 165, 165)),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Esto permite que el modal se expanda según su contenido

      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: keyForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Crear Evento Recurrente",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    formInput(
                      label: "Titulo",
                      controller: controllerTitleEdit,
                      validator: (value) => emptyOrNull(value, "descripción"),
                    ),
                    formInput(
                        label: "Descripción",
                        controller: controllerDescriptionEdit,
                        validator: (value) =>
                            emptyOrNull(value, "descripción")),
                    const Text(
                      "Fecha Inicio & Término",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
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
                                height: 300,
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  backgroundColor: Colors.white,
                                  maximumDate: DateTime.now(),
                                  initialDateTime: DateTime(2003, 3, 10),
                                  onDateTimeChanged: (DateTime value) {
                                    DateTime fecha =
                                        DateTime.parse(value.toString());
                                  },
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.40,
                            child: ElevatedButton.icon(
                              label: Text(
                                  dateInitial != null
                                      ? DateFormat('dd / MM / yyyy')
                                          .format(dateInitial!)
                                      : "",
                                  style: const TextStyle(fontSize: 12)),
                              icon: const Icon(
                                Icons.calendar_today,
                                size: 10,
                              ),
                              onPressed: () async {
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
                                    height: 300,
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.date,
                                      backgroundColor: Colors.white,
                                      maximumDate: DateTime.now(),
                                      initialDateTime: DateTime(2003, 3, 10),
                                      onDateTimeChanged: (DateTime value) {
                                        dateInitial =
                                            DateTime.parse(value.toString());
                                        setModalState(() {
                                          dateInitial = dateInitial;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        //* Fecha Final
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.40,
                          child: ElevatedButton.icon(
                            label: Text(
                                dateEnd != null
                                    ? DateFormat('dd / MM / yyyy')
                                        .format(dateEnd!)
                                    : "",
                                style: const TextStyle(fontSize: 12)),
                            icon: const Icon(
                              Icons.calendar_today,
                              size: 10,
                            ),
                            onPressed: () async {
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
                                  height: 300,
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    backgroundColor: Colors.white,
                                    maximumDate: DateTime.now(),
                                    initialDateTime: DateTime(2003, 3, 10),
                                    onDateTimeChanged: (DateTime value) {
                                      dateEnd =
                                          DateTime.parse(value.toString());
                                      setModalState(() {
                                        dateEnd = dateEnd;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "Horario Inicio & Término",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ElevatedButton.icon(
                              label: Text(
                                  horaInicio != null
                                      ? horaInicio!.format(context)
                                      : "",
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center),
                              icon: const Icon(Icons.access_time, size: 12),
                              onPressed: () async {
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
                                        initialDateTime: DateTime.now(),
                                        onDateTimeChanged:
                                            (DateTime newDateTime) {
                                          horaInicio = TimeOfDay.fromDateTime(
                                              newDateTime);
                                          setModalState(() {
                                            horaInicio = horaInicio;
                                          });
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
                                  horaFin != null
                                      ? horaFin!.format(context)
                                      : "",
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center),
                              icon: const Icon(Icons.access_time, size: 12),
                              onPressed: () async {
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
                                        initialDateTime: DateTime.now(),
                                        onDateTimeChanged:
                                            (DateTime newDateTime) {
                                          horaFin = TimeOfDay.fromDateTime(
                                              newDateTime);
                                          setModalState(() {
                                            horaFin = horaFin;
                                          });
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
                    formInput(
                      label: "Lugar",
                      controller: controllerLugarEdit,
                      validator: (value) => emptyOrNull(value, "lugar"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Repetir Cada"),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: decoration,
                          child: DropdownButton<String>(
                            hint: selectedDay == null
                                ? Text("")
                                : Text(
                                    selectedDay!,
                                    style: TextStyle(color: Colors.black),
                                  ),
                            value: selectedDay,
                            onChanged: (String? newValue) {
                              setModalState(() {
                                selectedDay = newValue;
                              });
                            },
                            items: daysOfWeek
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            dropdownColor: Colors
                                .white, // Cambia el color de fondo del menú desplegable
                            icon: Icon(Icons.arrow_drop_down,
                                color:
                                    Colors.black), // Cambia el icono y su color
                            style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    16), // Cambia el estilo del texto seleccionado
                            underline: Container(
                              height: 0,
                              color: Colors
                                  .transparent, // Cambia el color de la línea inferior
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          if (keyForm.currentState!.validate()) {
                            if (dateEnd == null || dateInitial == null) {
                              customToast(
                                  "Debes seleccionar una fecha de inicio y término",
                                  context,
                                  "isError");

                              return;
                            }
                            if (dateEnd!.isBefore(dateInitial!)) {
                              customToast(
                                  "La fecha de término no puede ser menor a la inicial",
                                  context,
                                  "isError");
                              return;
                            }

                            dateEnd = null;
                            dateInitial = null;
                            horaFin = null;
                            horaInicio = null;
                            selectedDay = null;
                            controllerDescriptionEdit.clear();
                            controllerTitleEdit.clear();
                            controllerLugarEdit.clear();

                            setModalState(() {
                              dateEnd = dateEnd;
                              dateInitial = dateInitial;
                            });
                          }
                          print(controllerTitleEdit.text);
                          print(controllerDescriptionEdit.text);
                          print(controllerLugarEdit.text);
                          print(selectedDay);
                        },
                        label: Text("Guardar Evento Concurrente",
                            style: const TextStyle(fontSize: 12)),
                        icon: Icon(Icons.save, size: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
