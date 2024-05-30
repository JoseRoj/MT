import 'dart:async';
import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../insfrastructure/models.dart';

class EventoView extends ConsumerStatefulWidget {
  static const name = 'evento-screen';
  final int idevento;

  EventoView({super.key, required this.idevento});

  @override
  EventoViewState createState() => EventoViewState();
}

class EventoViewState extends ConsumerState<EventoView> {
  late Future<Evento?> _futureEvento;
  Evento? evento;

  @override
  void initState() {
    super.initState();
    _futureEvento = ref
        .read(clubConnectProvider)
        .getEvento(widget.idevento)
        .then((value) => evento = value);
  }

  /*void obtenerDatosClub() async {
    // Obtener el proveedor del club
    try {
      // Llama a la función getClub para obtener los datos del club
      club = await ref.read(clubConnectProvider).getClub(widget.id);
      // Aquí puedes manejar los datos del club obtenidos
      print('Nombre del club: ${club.club.nombre}');
      print('Descripción del club: ${club.club.descripcion}');
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir al obtener los datos del club
      print('Error al obtener los datos del club: $e');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTheme().getTheme().textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: FutureBuilder(
        future: _futureEvento,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return Column(
                children: [
                  Center(
                      child: Text(evento!.titulo, style: textStyle.titleSmall)),
                  Text(evento!.descripcion),
                ],
              );
            default:
              return Center(child: Text('Estado no soportado'));
          }
        },
      ),
    );
  }
}
