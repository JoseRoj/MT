import 'package:clubconnect/domain/datasources/clubConnect_datasource.dart';
import 'package:clubconnect/domain/repositories/club_repository.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/categoria.dart';
import 'package:clubconnect/insfrastructure/models/eventoStadistic.dart';
import 'package:clubconnect/insfrastructure/models/local_video_model.dart';
import 'package:clubconnect/insfrastructure/models/monthStadistic.dart';
import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:clubconnect/insfrastructure/models/userTeam.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';

class SupaDBRepositoryImpl extends ClubConnectRepository {
  final ClubConnectDataSource clubConnectDataSource;

  SupaDBRepositoryImpl({required this.clubConnectDataSource});

  @override
  Future<List<Club>> getClubs(List<int> deportes, double northeastLat,
      double northeastLng, double southwestLat, double southwestLng) async {
    return await clubConnectDataSource.getClubs(
        deportes, northeastLat, northeastLng, southwestLat, southwestLng);
  }

  @override
  Future<ClubEspecifico> getClub(int id) async {
    return await clubConnectDataSource.getClub(id);
  }

  @override
  Future<dynamic> editClub(
      Club club, List<dynamic> categorias, List<dynamic> tipos) async {
    return await clubConnectDataSource.editClub(club, categorias, tipos);
  }

  @override
  Future<List<Tipo>> getTipos() async {
    return await clubConnectDataSource.getTipos();
  }

  @override
  Future<List<Deporte>> getDeportes() async {
    return await clubConnectDataSource.getDeportes();
  }

  @override
  Future<List<Categoria>> getCategorias() async {
    return await clubConnectDataSource.getCategorias();
  }

  @override
  Future<bool> addClub(Club club, List<dynamic> categorias, List<dynamic> tipos,
      int id_user) async {
    return await clubConnectDataSource.addClub(
        club, categorias, tipos, id_user);
  }

  @override
  Future<bool> deleteMiembroClub(int idusuario, int idclub) async {
    return await clubConnectDataSource.deleteMiembroClub(idusuario, idclub);
  }

  @override
  Future<bool> updateToken(int idusuario, String tokenfb) async {
    return await clubConnectDataSource.updateToken(idusuario, tokenfb);
  }

  @override
  Future<bool?> createUser(User usuario) async {
    return await clubConnectDataSource.createUser(usuario);
  }

  @override
  Future<bool?> updateImageUser(String image, int usuario) async {
    return await clubConnectDataSource.updateImageUser(image, usuario);
  }

  @override
  Future<dynamic> updateUser(User usuario) async {
    return await clubConnectDataSource.updateUser(usuario);
  }

  @override
  Future<String> getRole(int idusuario, int idclub, int? idequipo) async {
    return await clubConnectDataSource.getRole(idusuario, idclub, idequipo);
  }

  @override
  Future<User> getUsuario(int id) async {
    return await clubConnectDataSource.getUsuario(id);
  }

  @override
  Future<List<MonthStadisticUser>> getMonthStadisticUser(
      int idusuario, int idequipo) async {
    return await clubConnectDataSource.getMonthStadisticUser(
        idusuario, idequipo);
  }

  @override
  Future<bool> sendSolicitud(int idusuario, int idclub) async {
    return await clubConnectDataSource.sendSolicitud(idusuario, idclub);
  }

  @override
  Future<List<Club>> getClubsUser(int idusuario) async {
    return await clubConnectDataSource.getClubsUser(idusuario);
  }

  @override
  Future<List<Equipo>> getEquipos(int idclub) async {
    return await clubConnectDataSource.getEquipos(idclub);
  }

  @override
  Future<bool> addEquipo(Equipo equipo) async {
    return await clubConnectDataSource.addEquipo(equipo);
  }

  @override
  Future<bool> deleteEquipo(int idequipo) async {
    return await clubConnectDataSource.deleteEquipo(idequipo);
  }

  @override
  Future<List<User>> getMiembrosEquipo(int idequipo) async {
    return await clubConnectDataSource.getMiembrosEquipo(idequipo);
  }

  @override
  Future<List<Solicitud>> getSolicitudes(int idclub) async {
    return await clubConnectDataSource.getSolicitudes(idclub);
  }

  @override
  Future<List<UserTeam>> getMiembros(int idclub) async {
    return await clubConnectDataSource.getMiembros(idclub);
  }

  @override
  Future<bool> acceptSolicitud(
      List<dynamic> equipos, int idusuario, String rol, int idclub) async {
    return clubConnectDataSource.acceptSolicitud(
        equipos, idusuario, rol, idclub);
  }

  @override
  Future<bool> addMiembro(int idusuario, int idequipo, String rol) async {
    return await clubConnectDataSource.addMiembro(idusuario, idequipo, rol);
  }

  @override
  Future<bool> deleteMiembro(int idusuario, int idequipo) async {
    return await clubConnectDataSource.deleteMiembro(idusuario, idequipo);
  }

  @override
  Future<String?> getEstadoSolicitud(int idusuario, int idclub) async {
    return await clubConnectDataSource.getEstadoSolicitud(idusuario, idclub);
  }

  @override
  Future<bool> updateSolicitud(int idusuario, int idclub, String estado) async {
    return await clubConnectDataSource.updateSolicitud(
        idusuario, idclub, estado);
  }

  @override
  Future<List<Equipo>> getEquiposUser(int idusuario, int idclub) async {
    return await clubConnectDataSource.getEquiposUser(idusuario, idclub);
  }

  @override
  Future<List<EventoFull>> getEventos(int idequipo, String estado,
      DateTime initialDate, int month, int year) async {
    return await clubConnectDataSource.getEventos(
        idequipo, estado, initialDate, month, year);
  }

  @override
  Future<bool> createEvento(
      List<String> fechas,
      String horaInicio,
      String descripcion,
      String horaFinal,
      int idequipo,
      int idclub,
      String titulo,
      String lugar) async {
    return await clubConnectDataSource.createEvento(fechas, horaInicio,
        descripcion, horaFinal, idequipo, idclub, titulo, lugar);
  }

  @override
  Future<Evento> getEvento(int idevento) async {
    return await clubConnectDataSource.getEvento(idevento);
  }

  @override
  Future<bool> deleteEvento(int idevento) async {
    return await clubConnectDataSource.deleteEvento(idevento);
  }

  @override
  Future<bool> editEvento(
      String fecha,
      String horaInicio,
      String descripcion,
      String horaFinal,
      int idevento,
      String titulo,
      String lugar,
      List<int> asistentesDelete) async {
    return await clubConnectDataSource.editEvento(fecha, horaInicio,
        descripcion, horaFinal, idevento, titulo, lugar, asistentesDelete);
  }

  @override
  Future<bool> updateEstadoEvento(int idevento, String estado) async {
    return await clubConnectDataSource.updateEstadoEvento(idevento, estado);
  }

  @override
  Future<bool> addAsistencia(int idevento, int idusuario) async {
    return await clubConnectDataSource.addAsistencia(idevento, idusuario);
  }

  @override
  Future<bool> deleteAsistencia(int idevento, int idusuario) async {
    return await clubConnectDataSource.deleteAsistencia(idevento, idusuario);
  }

  @override
  Future updateImagenClub(String image, int idclub) async {
    return await clubConnectDataSource.updateImagenClub(image, idclub);
  }

  //* --------------- CONFIGURACION EVENTOS ----------------*//
  @override
  Future<dynamic> createConfigEvento(ConfigEventos configEvento) async {
    return await clubConnectDataSource.createConfigEvento(configEvento);
  }

  @override
  Future<dynamic> deleteConfigEvento(int idConfig) async {
    return await clubConnectDataSource.deleteConfigEvento(idConfig);
  }

  @override
  Future<List<ConfigEventos>> getConfigEventos(int idequipo) async {
    return await clubConnectDataSource.getConfigEventos(idequipo);
  }

  @override
  Future<dynamic> editConfigEvento(ConfigEventos configEvento) async {
    return await clubConnectDataSource.editConfigEvento(configEvento);
  }

  @override
  Future<EventoStadistic> getEventoStadistic(
      DateTime initDate, DateTime endDate, int idequipo, int idClub) async {
    return await clubConnectDataSource.getEventoStadistic(
        initDate, endDate, idequipo, idClub);
  }

  @override
  Future<List<Post>> getFeedByPage(List<int> clubes, int page) async {
    return await clubConnectDataSource.getFeedByPage(clubes, page);
  }
}
