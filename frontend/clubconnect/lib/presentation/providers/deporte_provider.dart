import 'package:clubconnect/insfrastructure/models/deporte.dart';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deportesProvider =
    StateNotifierProvider<DeporteNotifier, List<Deporte>>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return DeporteNotifier(supaDBRepositoryImpl);
});

class DeporteNotifier extends StateNotifier<List<Deporte>> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;
  DeporteNotifier(this._supaDBRepositoryImpl) : super([]);

  void getDeportes() async {
    final sports = await _supaDBRepositoryImpl.getDeportes();
    state = sports;
  }
}
