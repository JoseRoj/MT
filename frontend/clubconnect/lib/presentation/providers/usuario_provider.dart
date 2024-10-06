import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubconnect/insfrastructure/models.dart';

final usuarioProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  final supaDBRepositoryImpl = ref.watch(clubConnectProvider);
  return UserNotifier(supaDBRepositoryImpl);
});

class UserNotifier extends StateNotifier<User> {
  final SupaDBRepositoryImpl _supaDBRepositoryImpl;

  UserNotifier(this._supaDBRepositoryImpl)
      : super(User(
          nombre: '',
          email: '',
          telefono: '',
          fechaNacimiento: DateTime.now(),
          apellido1: '',
          genero: '',
          apellido2: '',
        )) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      state = User.fromRawJson(userJson);
    }
  }

  Future<void> getUsuario(String id) async {
    final user = await _supaDBRepositoryImpl.getUsuario(int.parse(id));
    state = user;
    _saveUser(user);
  }

  Future<dynamic> updateUsuario(User usuario) async {
    final user = await _supaDBRepositoryImpl.updateUser(usuario);
    if (user.statusCode == 200) {
      state = usuario;
      _saveUser(usuario);
    }
    return user;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', user.toRawJson());
  }
}
