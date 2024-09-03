import 'package:clubconnect/globales.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventosActivosProvider =
    StateNotifierProvider<EventosActivos, List<EventoFull>?>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return EventosActivos(supaDBRepositoryImpl);
});

class EventosActivos extends StateNotifier<List<EventoFull>?> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;
  EventosActivos(this._supaDBRepositoryImpl) : super([]);

  Future<void> getEventosActivos(
      int idequipo, DateTime initDate, int month, int year) async {
    final eventosActivos = await _supaDBRepositoryImpl.getEventos(
        idequipo, EstadosEventos.activo, initDate, month, year);
    state = eventosActivos;
  }
}
