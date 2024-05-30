import 'package:clubconnect/insfrastructure/datasources/Supadb_datasource.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clubConnectProvider = Provider((ref) {
  return SupaDBRepositoryImpl(clubConnectDataSource: SupabdDatasource());
});

final clubesRegisterProvider =
    StateNotifierProvider<ClubesRegisterNotifier, List<Club>>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return ClubesRegisterNotifier(supaDBRepositoryImpl);
});

class ClubesRegisterNotifier extends StateNotifier<List<Club>> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;
  ClubesRegisterNotifier(this._supaDBRepositoryImpl) : super([]);

  Future<void> getClubes(List<int> deportes) async {
    final clubes = await _supaDBRepositoryImpl.getClubs(deportes);
    state = clubes;
  }
}
