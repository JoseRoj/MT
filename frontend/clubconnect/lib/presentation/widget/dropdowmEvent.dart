import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/widget/userlist.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DropdownButtonEventSpecific extends StatefulWidget {
  final List<Evento>? eventoFilter;
  Evento? selectedEvent;

  DropdownButtonEventSpecific({
    super.key,
    required this.eventoFilter,
    this.selectedEvent,
  });

  @override
  _DropdownButtonEventSpecificState createState() =>
      _DropdownButtonEventSpecificState();
}

class _DropdownButtonEventSpecificState
    extends State<DropdownButtonEventSpecific> {
  Evento? selectedEvent;

  @override
  void initState() {
    print(widget.eventoFilter);
    super.initState();
    selectedEvent = widget.selectedEvent;
  }

  bool selectedExist() {
    return widget.eventoFilter!.any((evento) => evento.id == selectedEvent!.id);
  }

  @override
  Widget build(BuildContext context) {
    print("Evento filtered" + widget.selectedEvent!.fecha.toIso8601String());

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme().getTheme().colorScheme.onSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme().getTheme().colorScheme.primary,
              width: 1,
            ),
          ),
          child: selectedEvent != null
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<Evento>(
                    menuMaxHeight: 300,
                    value: widget.selectedEvent,
                    onChanged: (Evento? option) {
                      setState(() {
                        widget.selectedEvent = option;
                      });
                    },
                    items: widget.eventoFilter!
                        .map<DropdownMenuItem<Evento>>((Evento option) {
                      return DropdownMenuItem<Evento>(
                        value: option,
                        child: Center(
                          child: Text(
                              "${option.titulo} (${(DateFormat('dd/MM/yyyy').format(option.fecha))})",
                              style:
                                  AppTheme().getTheme().textTheme.labelSmall),
                        ),
                      );
                    }).toList(),
                    style: AppTheme().getTheme().textTheme.labelSmall,
                    isExpanded: true,
                  ),
                )
              : Container(),
        ),
        infoEvent(),
      ],
    );
  }

  Widget infoEvent() {
    return Container(
      /* decoration: BoxDecoration(
          color: AppTheme().getTheme().primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),*/
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            widget.selectedEvent!.titulo,
            style: AppTheme().getTheme().textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            DateFormat('dd / MM / yyyy').format(widget.selectedEvent!.fecha),
            style: AppTheme().getTheme().textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            "${widget.selectedEvent!.pctasistencia?.toStringAsFixed(2) ?? '0.00'}% Asistencia",
            style: AppTheme().getTheme().textTheme.bodySmall,
          ),
          const Text("Asistentes"),
          SingleChildScrollView(
            child: Wrap(
              children: widget.selectedEvent!.asistentes!.map((e) {
                return userList(
                  name: e.nombre,
                  image: e.imagen,
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
