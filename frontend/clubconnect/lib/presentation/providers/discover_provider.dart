import 'package:clubconnect/domain/repositories/club_repository.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:clubconnect/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final discoverProvider = ChangeNotifierProvider<DiscoverProvider>((ref) {
  final cc = ref.watch(clubConnectProvider);
  if (cc == null) {
    throw Exception(
        "ClubConnectRepository es nulo. Asegúrate de que esté inicializado.");
  }
  return DiscoverProvider(clubConnectRepository: cc, ref: ref);
});

class DiscoverProvider extends ChangeNotifier {
  final ClubConnectRepository clubConnectRepository;
  final Ref ref;

  bool initialLoading = true;
  bool noMore = false;
  int page = 0;
  List<Post> videos = [];

  DiscoverProvider({required this.clubConnectRepository, required this.ref});

  Future<void> loadNextPage(List<int> clubes) async {
    // await Future.delayed( const Duration(seconds: 2) );

    // final List<VideoPost> newVideos = videoPosts.map(
    //   ( video ) => LocalVideoModel.fromJson(video).toVideoPostEntity()
    // ).toList();
    final clubesNear = ref.read(clubesRegisterProvider);
    final newVideos = await clubConnectRepository.getFeedByPage(clubes, page);
    for (var post in newVideos) {
      final matches =
          clubesNear.where((club) => club.id == post.clubId).toList();
      if (matches.isEmpty) {
        print("Error: No se encontró ningún club con ID ${post.clubId}");
      } else {
        final value = matches.first; // Obtén el primer elemento coincidente
        post.club = value;
        print("Club encontrado: ${value.nombre}");
      }
    }

    if (newVideos.isEmpty) {
      noMore = true;
    } else {
      page += 1;
      videos.addAll(newVideos);
      initialLoading = false;
      notifyListeners();
    }
  }

  void updatePage(int newPage) {
    page = newPage;
    notifyListeners(); // Notifica a los oyentes que `page` ha cambiado
  }
}
