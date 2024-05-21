import '../../insfrastructure/models.dart';
import '../../presentation/providers/auth_provider.dart';

abstract class ClubConnectRepository {
  Future<List<Club>> getClubs();

  Future<ClubEspecifico> getClub(int id);

  Future<List<Deporte>> getDeportes();

  Future<List<Categoria>> getCategorias();

  Future<List<Tipo>> getTipos();

  Future<bool> addClub(
      Club club, List<dynamic> categorias, List<dynamic> tipos, int id_user);

  Future<List<Club>> getClubsUser(int idusuario);
  Future<String> getRole(int idusuario, int idclub);

  //* ------ EQUIPOS USUARIO ------- *//
  Future<List<Equipo>> getEquipos(int idclub);
  Future<bool> addEquipo(Equipo equipo);
  Future<List<Equipo>> getEquiposUser(int idusuario, int idclub);

  Future<Data?> validar(String email, String contrasena);

  Future<bool?> createUser(User usuario);

  Future<User> getUsuario(int id);

  //* --------------- SOLICITUDES  ----------- *//
  Future<bool> sendSolicitud(int idusuario, int idclub);
  Future<List<Solicitud>> getSolicitudes(int idclub);
  Future<String?> getEstadoSolicitud(int idusuario, int idclub);

  //* --------------- MIEMBROS ----------- *//
  Future<bool> acceptSolicitud(
      List<dynamic> equipos, int idusuario, String rol, int idclub);
}
