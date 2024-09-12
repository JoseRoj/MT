import 'package:clubconnect/insfrastructure/models/tipo.dart';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tiposProvider = StateNotifierProvider<TiposNotifier, List<Tipo>>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return TiposNotifier(supaDBRepositoryImpl);
});

class TiposNotifier extends StateNotifier<List<Tipo>> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;
  TiposNotifier(this._supaDBRepositoryImpl) : super([]);

  Future<void> getTipos() async {
    final tipos = await _supaDBRepositoryImpl.getTipos();
    //final types = tipos.map((tipo) => {"id": tipo.id: tipo.nombre}).toList();
    state = tipos;
  }
}
