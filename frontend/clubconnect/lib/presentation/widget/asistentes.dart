import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/insfrastructure/models/evento.dart';
import 'package:clubconnect/presentation/widget/userlist.dart';
import 'package:flutter/material.dart';

class AttendeesList extends StatefulWidget {
  final List<Asistente> asistentes;
  const AttendeesList({required this.asistentes});

  @override
  State<AttendeesList> createState() => _AttendeesListState();
}

class _AttendeesListState extends State<AttendeesList> {
  var styleText = AppTheme().getTheme().textTheme;
  bool more = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people),
                  const SizedBox(width: 10),
                  Text("Asistentes",
                      style: AppTheme().getTheme().textTheme.titleSmall),
                ],
              ),
              widget.asistentes.length <= 4
                  ? const SizedBox()
                  : TextButton.icon(
                      onPressed: () {
                        setState(() {
                          more = !more;
                        });
                      },
                      label: more == false
                          ? Text("Ver más", style: styleText.labelSmall)
                          : Text("Ver menos", style: styleText.labelSmall),
                      icon: more == false
                          ? const Icon(Icons.arrow_drop_down)
                          : const Icon(Icons.arrow_drop_up),
                    ),
            ],
          ),
        ),
        more
            ? SingleChildScrollView(
                child: Flexible(
                  child: Wrap(
                    children: widget.asistentes.map((e) {
                      return userList(
                        name: e.nombre,
                        image: e.imagen,
                      );
                    }).toList(),
                  ),
                ),
              )
            : Container(
                height: 80,
                child: SingleChildScrollView(
                  child: Wrap(
                    children: widget.asistentes.take(4).map((e) {
                      return userList(
                        name: e.nombre,
                        image: e.imagen,
                      );
                    }).toList(),
                  ),
                ),
              ),
      ],
    );
  }
}
