import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
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

  // ******** FUNCIONES REQUEST *************//
  /* Function Create */
  Future<void> create(Post newPost) async {
    //* Llamar a la API, que retorne el id. y se agrega al newPost y se agrega
    final idPost =
        await ref.read(clubConnectProvider).createEventPublic(newPost);
    newPost.id = idPost;
    widget.club!.eventos.add(newPost);
    setState(() {});
    print(widget.club!.eventos.last.id);
  }

  Future<void> edit(Post newPost) async {
    //* Llamar a la API, que retorne el id. y se agrega al newPost y se agrega
    final index =
        widget.club!.eventos.indexWhere((element) => element.id == newPost.id);
    if (index != -1) {
      widget.club!.eventos[index] = newPost; // Sustituyes el objeto completo
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: widget.club?.eventos.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventPublicEdit(
                    post: widget.club!.eventos[index],
                    editEvent: edit,
                  ),
                ),
              );
            },
            child: Container(
              color: Colors.black,
              child: Image.memory(
                imagenFromBase64(widget.club!.eventos[index].image),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_a_photo),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventPublicEditCreate(
                  addEvent: create,
                  idClub: widget.club!.club.id!,
                ),
              ),
            );
          }),
    );
  }
}
