import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clubesUserProvider = StateNotifierProvider<ClubesUser, List<Club>>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return ClubesUser(supaDBRepositoryImpl);
});

class ClubesUser extends StateNotifier<List<Club>> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;
  ClubesUser(this._supaDBRepositoryImpl) : super([]);

  Future<void> getClubesUser(int idUser) async {
    final clubesUser = await _supaDBRepositoryImpl.getClubsUser(idUser);
    state = clubesUser;
  }

  Future<void> deleteClub(dynamic clubId) async {
    final clubes =
        state.where((club) => int.parse(club.id!) != clubId).toList();
    state = clubes;
  }
}
