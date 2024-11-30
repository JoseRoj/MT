import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/presentation/screens/public_events.dart';
import 'package:clubconnect/presentation/views/equiposClub/drawerClub/eventosPublicos/eventos_public_create.dart';
import 'package:clubconnect/presentation/views/equiposClub/drawerClub/eventosPublicos/eventos_publicos_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventosPublicosWidget extends ConsumerStatefulWidget {
  final ClubEspecifico? club;

  const EventosPublicosWidget({
    super.key,
    required this.club,
  });

  @override
  EventosPublicosWidgetState createState() => EventosPublicosWidgetState();
}

class EventosPublicosWidgetState extends ConsumerState<EventosPublicosWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> videoPosts = [
    {
      'estado': "Activo",
      'club': "Club Mewlen Angol",
      'fecha_evento': "2024-08-15T00:00:00.000Z",
      'url':
          'https://marketplace.canva.com/EAGGE1BZbhA/1/0/1131w/canva-cartel-vertical-moderno-para-promoci%C3%B3n-de-festival-musical-amarillo-SOF81hXuW50.jpg',
      'fecha_publicacion': "2024-08-15T00:00:00.000Z",
    },
    {
      'estado': "Finalizado",
      'club': "EMVA",
      'fecha_evento': "2024-08-15T00:00:00.000Z",
      'url':
          'https://marketplace.canva.com/EAGGE1BZbhA/1/0/1131w/canva-cartel-vertical-moderno-para-promoci%C3%B3n-de-festival-musical-amarillo-SOF81hXuW50.jpg',
      'fecha_publicacion': "2024-08-15T00:00:00.000Z"
    },
    {
      'estado': "Activo",
      'club': "Tralkan",
      'fecha_evento': "2024-08-15T00:00:00.000Z",
      'url':
          'https://marketplace.canva.com/EAGGE1BZbhA/1/0/1131w/canva-cartel-vertical-moderno-para-promoci%C3%B3n-de-festival-musical-amarillo-SOF81hXuW50.jpg',
      'fecha_publicacion': "2024-08-15T00:00:00.000Z"
    },
    {
      'estado': "Activo",
      'club': "Llufken",
      'fecha_evento': "2024-08-15T00:00:00.000Z",
      'url':
          'https://marketplace.canva.com/EAGGE1BZbhA/1/0/1131w/canva-cartel-vertical-moderno-para-promoci%C3%B3n-de-festival-musical-amarillo-SOF81hXuW50.jpg',
      'fecha_publicacion': "2024-08-15T00:00:00.000Z"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: videoPosts.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventPublicEdit(
                      video: LocalVideoModel.fromJson(videoPosts[1])),
                ),
              );
            },
            child: Image.network(
                'https://instagram.fccp3-1.fna.fbcdn.net/v/t51.29350-15/435621030_889264159666636_3458351929489774934_n.webp?stp=dst-jpg_e35&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xMDgweDEwODAuc2RyLmYyOTM1MC5kZWZhdWx0X2ltYWdlIn0&_nc_ht=instagram.fccp3-1.fna.fbcdn.net&_nc_cat=104&_nc_ohc=MqFV-oeK4X8Q7kNvgFjYFgj&_nc_gid=3efa323e0cc74cfdb0673287e7de9bb8&edm=APoiHPcBAAAA&ccb=7-5&ig_cache_key=MzM0MTI1ODMwMTY3Njc4Mjk5OQ%3D%3D.3-ccb7-5&oh=00_AYD94M-u7eBLB8uPctZaQ-grDLteZW7iF2h5TQ4etI4BEw&oe=6741C299&_nc_sid=22de04',
                fit: BoxFit.contain),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_a_photo),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventPublicEditCreate(),
              ),
            );
          }),
    );
  }
}
