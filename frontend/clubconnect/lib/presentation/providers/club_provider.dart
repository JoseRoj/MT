import 'package:clubconnect/insfrastructure/datasources/Supadb_datasource.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clubConnectProvider = Provider((ref) {
  final token = ref.watch(authProvider).token;
  return SupaDBRepositoryImpl(
      clubConnectDataSource: SupabdDatasource(token: token!));
});

final clubesRegisterProvider =
    StateNotifierProvider<ClubesRegisterNotifier, List<Club>>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return ClubesRegisterNotifier(supaDBRepositoryImpl);
});

class ClubesRegisterNotifier extends StateNotifier<List<Club>> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;
  ClubesRegisterNotifier(this._supaDBRepositoryImpl) : super([]);

  Future<List<Club>> getClubes(List<int> deportes, double northeastLat,
      double northeastLng, double southwestLat, double southwestLng) async {
    final clubes = await _supaDBRepositoryImpl.getClubs(
        deportes, northeastLat, northeastLng, southwestLat, southwestLng);
    state = clubes;
    return clubes;
  }
}
