import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';

abstract class ClubConnectDataSource {
  Future<List<Club>> getClubs(List<int> deportes);
  Future<ClubEspecifico> getClub(int id);
  Future<List<Deporte>> getDeportes();
  Future<List<Categoria>> getCategorias();
  Future<List<Tipo>> getTipos();
  Future<bool> addClub(
      Club club, List<dynamic> categorias, List<dynamic> tipos, int id_user);
  Future<Data?> validar(String email, String contrasena);
  Future<User> getUsuario(int id);
  Future<List<User>> getMiembros(int idclub);

  //* ------ EQUIPOS USUARIO ------- *//
  Future<List<Equipo>> getEquipos(int idclub);
  Future<bool> addEquipo(Equipo equipo);
  Future<List<Equipo>> getEquiposUser(int idusuario, int idclub);

  Future<String> getRole(int idusuario, int idclub);
  Future<List<Club>> getClubsUser(int idusuario);
  Future<bool> sendSolicitud(int idusuario, int idclub);
  Future<bool?> createUser(User usuario);

  //* --------------- SOLICITUDES  ----------- *//
  Future<List<Solicitud>> getSolicitudes(int idclub);
  Future<String?> getEstadoSolicitud(int idusuario, int idclub);
  Future<bool> updateSolicitud(int idusuario, int idclub, String estado);

  //* --------------- MIEMBROS ----------- *//
  Future<bool> acceptSolicitud(
      List<dynamic> equipos, int idusuario, String rol, int idclub);

  //* --------------- EVENTOS ----------------*//
  Future<List<EventoFull>?> getEventos(int idequipo, String estado);
  Future<bool> createEvento(List<String> fechas, String horaInicio,
      String descripcion, String horaFinal, int idequipo, String titulo);
  Future<Evento> getEvento(int idevento);

  //* --------------- ASISTENCIA ----------------*//
  Future<bool> addAsistencia(int idevento, int idusuario);
  Future<bool> deleteAsistencia(int idevento, int idusuario);
}
