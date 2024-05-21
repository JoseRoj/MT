import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final UsuarioProvider = FutureProvider.family<User, int>((ref, id) async {
  print('UsuarioProvider');
  final user = await ref.watch(clubConnectProvider).getUsuario(id);
  return user;
});
