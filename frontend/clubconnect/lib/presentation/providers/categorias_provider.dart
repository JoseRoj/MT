import 'package:clubconnect/insfrastructure/models/categoria.dart';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriasProvider =
    StateNotifierProvider<CategoriaNotifier, List<Categoria>>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return CategoriaNotifier(supaDBRepositoryImpl);
});

class CategoriaNotifier extends StateNotifier<List<Categoria>> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;
  CategoriaNotifier(this._supaDBRepositoryImpl) : super([]);

  Future<void> getCategorias() async {
    final cats = await _supaDBRepositoryImpl.getCategorias();
    state = cats;
  }
}
