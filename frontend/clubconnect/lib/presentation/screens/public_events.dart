import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:clubconnect/presentation/providers/discover_provider.dart';
import 'package:clubconnect/presentation/views/feed/feedScrollable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ejemplo de un provider ficticio llamado discoverProvider

class EventsPublicClub extends ConsumerWidget {
  final ClubEspecifico club;
  final List<LocalVideoModel> videos;
  final int initialIndex; // Índice inicial
  const EventsPublicClub({
    super.key,
    required this.videos,
    required this.club,
    this.initialIndex = 0, // Valor predeterminado para el índice inicial
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accede al valor de discoverProvider

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color del icono de retroceso aquí
        ),
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Eventos Publicados",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Text(
              club.club.nombre,
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: videos.isEmpty
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : SafeArea(
              child:
                  Container() //FeedScrollable(posts: videos, initialIndex: initialIndex),
              ), // Pasa el valor del provider a FeedScrollable
    );
  }
}
