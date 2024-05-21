import 'package:clubconnect/domain/datasources/clubConnect_datasource.dart';
import 'package:clubconnect/domain/repositories/club_repository.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/categoria.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';

class SupaDBRepositoryImpl extends ClubConnectRepository {
  final ClubConnectDataSource clubConnectDataSource;

  SupaDBRepositoryImpl({required this.clubConnectDataSource});

  @override
  Future<List<Club>> getClubs() async {
    return await clubConnectDataSource.getClubs();
  }

  @override
  Future<ClubEspecifico> getClub(int id) async {
    return await clubConnectDataSource.getClub(id);
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
  Future<Data?> validar(String email, String contrasena) async {
    return await clubConnectDataSource.validar(email, contrasena);
  }

  @override
  Future<bool?> createUser(User usuario) async {
    return await clubConnectDataSource.createUser(usuario);
  }

  @override
  Future<String> getRole(int idusuario, int idclub) async {
    return await clubConnectDataSource.getRole(idusuario, idclub);
  }

  @override
  Future<User> getUsuario(int id) async {
    return await clubConnectDataSource.getUsuario(id);
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
  Future<List<Solicitud>> getSolicitudes(int idclub) async {
    return await clubConnectDataSource.getSolicitudes(idclub);
  }

  @override
  Future<bool> acceptSolicitud(
      List<dynamic> equipos, int idusuario, String rol, int idclub) async {
    return clubConnectDataSource.acceptSolicitud(
        equipos, idusuario, rol, idclub);
  }

  @override
  Future<String?> getEstadoSolicitud(int idusuario, int idclub) async {
    return await clubConnectDataSource.getEstadoSolicitud(idusuario, idclub);
  }

  @override
  Future<List<Equipo>> getEquiposUser(int idusuario, int idclub) async {
    return await clubConnectDataSource.getEquiposUser(idusuario, idclub);
  }
}