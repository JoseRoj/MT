import 'package:clubconnect/insfrastructure/models/userTeam.dart';

import '../../insfrastructure/models.dart';
import '../../presentation/providers/auth_provider.dart';

abstract class ClubConnectRepository {
  //* --------------- CLUBS  ----------- *//
  Future<List<Club>> getClubs(List<int> deportes);
  Future<ClubEspecifico> getClub(int id);
  Future<List<Deporte>> getDeportes();
  Future<List<Categoria>> getCategorias();
  Future<List<Tipo>> getTipos();
  Future<bool> addClub(
      Club club, List<dynamic> categorias, List<dynamic> tipos, int id_user);
  Future<bool> deleteMiembroClub(int idusuario, int idclub);

  Future<List<Club>> getClubsUser(int idusuario);
  Future<String> getRole(int idusuario, int idclub, int? idequipo);
  Future<List<UserTeam>> getMiembros(int idclub);

  //* ------ EQUIPOS USUARIO ------- *//
  Future<List<Equipo>> getEquipos(int idclub);
  Future<bool> addEquipo(Equipo equipo);
  Future<List<Equipo>> getEquiposUser(int idusuario, int idclub);
  Future<List<User>> getMiembrosEquipo(int idequipo);

  //* --------------- AUTH  ----------- *//
  Future<Data?> validar(String email, String contrasena);
  Future<bool> updateToken(int idusuario, String tokenfb);

  Future<bool?> createUser(User usuario);
  Future<User> getUsuario(int id);

  //* --------------- SOLICITUDES  ----------- *//
  Future<bool> sendSolicitud(int idusuario, int idclub);
  Future<List<Solicitud>> getSolicitudes(int idclub);
  Future<String?> getEstadoSolicitud(int idusuario, int idclub);
  Future<bool> updateSolicitud(int idusuario, int idclub, String estado);

  //* --------------- MIEMBROS ----------- *//
  Future<bool> acceptSolicitud(
      List<dynamic> equipos, int idusuario, String rol, int idclub);
  Future<bool> addMiembro(int idusuario, int idequipo, String rol);
  Future<bool> deleteMiembro(int idusuario, int idequipo);

  //* --------------- EVENTOS ----------------*//
  Future<List<EventoFull>?> getEventos(int idequipo, String estado);
  Future<bool> createEvento(
      List<String> fechas,
      String horaInicio,
      String descripcion,
      String horaFinal,
      int idequipo,
      int idclub,
      String titulo,
      String lugar);
  Future<Evento> getEvento(int idevento);
  Future<bool> deleteEvento(int idevento);
  Future<bool> editEvento(
      String fecha,
      String horaInicio,
      String descripcion,
      String horaFinal,
      int idevento,
      String titulo,
      String lugar,
      List<int> asistentesDelete);
  Future<bool> updateEstadoEvento(int idevento, String estado);

  //* --------------- ASISTENCIA ----------------*//
  Future<bool> addAsistencia(int idevento, int idusuario);
  Future<bool> deleteAsistencia(int idevento, int idusuario);
}
