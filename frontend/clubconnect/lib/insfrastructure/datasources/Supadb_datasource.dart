import 'dart:convert';
import 'dart:math';

import 'package:clubconnect/domain/datasources/clubConnect_datasource.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/categoria.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/deporte.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabdDatasource extends ClubConnectDataSource {
  @override
  Future<List<Club>> getClubs() async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get('${dotenv.env["API_URL"]}/club/getclubs');
    List<Club> clubs = response.data["data"].map<Club>((club) {
      return Club.fromJson(club);
    }).toList();
    return clubs;
  }

  @override
  Future<ClubEspecifico> getClub(int id) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/club/getClub',
      queryParameters: {'id': id},
    );
    ClubEspecifico club = ClubEspecifico.fromJson(response.data["data"]);
    return club;
  }

  @override
  Future<List<Deporte>> getDeportes() async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get('${dotenv.env["API_URL"]}/getDeportes');
    Deportes sports = Deportes.fromJson(response.data);
    return sports.data;
  }

  @override
  Future<List<Categoria>> getCategorias() async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get('${dotenv.env["API_URL"]}/getCategorias');
    Categorias cat = Categorias.fromJson(response.data);
    return cat.data;
  }

  @override
  Future<List<Tipo>> getTipos() async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get('${dotenv.env["API_URL"]}/getTipos');
    List<Tipo> tipos = response.data["data"].map<Tipo>((tipo) {
      return Tipo.fromJson(tipo);
    }).toList();
    return tipos;
  }

  @override
  Future<bool> addClub(Club club, List<dynamic> categorias, List<dynamic> tipos,
      int id_user) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final resp = await dio.post('${dotenv.env["API_URL"]}/club',
          data: jsonEncode(<String, dynamic>{
            "latitud": club.latitud,
            "longitud": club.longitud,
            "nombre": club.nombre,
            "descripcion": club.descripcion,
            "id_deporte": club.idDeporte,
            "logo": club.logo,
            "correo": club.correo,
            "telefono": club.telefono,
            "categorias": categorias,
            "tipos": tipos,
            "id_usuario": id_user,
          }));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Data?> validar(String email, String contrasena) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));

      final response = await dio.post('${dotenv.env["API_URL"]}/login',
          data: jsonEncode(
              <String, String>{"email": email, "contrasena": contrasena}));
      if (response.statusCode == 200) {
        Login res = Login.fromJson(response.data);
        return res.data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<bool?> createUser(User usuario) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.post(
          '${dotenv.env["API_URL"]}/usuarios/create',
          data: usuario.toJson());
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<User> getUsuario(int id) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/usuarios/getUser',
      queryParameters: {'id': id},
    );
    User user = User.fromJson(response.data["data"][0]);
    return user;
  }

  @override
  Future<String> getRole(int idusuario, int idclub) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/usuarios/rol',
      queryParameters: {'id_usuario': idusuario, 'id_club': idclub},
    );
    return response.data["data"];
  }

  @override
  Future<List<Club>> getClubsUser(int idusuario) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/usuarios/getclubesUser',
      queryParameters: {'id_usuario': idusuario},
    );
    List<Club> clubs = response.data["data"].map<Club>((club) {
      return Club.fromJson(club);
    }).toList();
    print(clubs);
    return clubs;
  }

//! Falta implementar
  @override
  Future<bool> sendSolicitud(int idusuario, int idclub) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.post(
        '${dotenv.env["API_URL"]}/solicitud/send',
        data: jsonEncode(
          <String, dynamic>{
            "id_usuario": idusuario,
            "id_club": idclub,
          },
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Equipo>> getEquipos(int idclub) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/equipo/getEquipos',
      queryParameters: {'id_club': idclub},
    );
    List<Equipo> equipos = response.data["data"].map<Equipo>((equipo) {
      return Equipo.fromJson(equipo);
    }).toList();
    return equipos;
  }

  @override
  Future<bool> addEquipo(Equipo equipo) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.post(
        '${dotenv.env["API_URL"]}/equipo/createEquipo',
        data: jsonEncode(equipo.toJson()),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Solicitud>> getSolicitudes(int idclub) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.get(
          '${dotenv.env["API_URL"]}/solicitud/getPendientes',
          queryParameters: {'id_club': idclub});
      List<Solicitud> solicitudes =
          response.data["data"].map<Solicitud>((solicitud) {
        return Solicitud.fromJson(solicitud);
      }).toList();
      return solicitudes;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> acceptSolicitud(
      List<dynamic> equipos, int idusuario, String rol, int idclub) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.post(
        '${dotenv.env["API_URL"]}/miembro/assignMiembro',
        data: jsonEncode(
          <String, dynamic>{
            "id_usuario": idusuario,
            "id_club": idclub,
            "rol": rol,
            "equipos": equipos,
          },
        ),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getEstadoSolicitud(int idusuario, int idclub) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.get(
        '${dotenv.env["API_URL"]}/solicitud/getEstado',
        queryParameters: {'id_usuario': idusuario, 'id_club': idclub},
      );
      return response.data["data"];
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<List<Equipo>> getEquiposUser(int idusuario, int idclub) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.get(
        '${dotenv.env["API_URL"]}/equipo/getEquiposByUser',
        queryParameters: {'id_usuario': idusuario, 'id_club': idclub},
      );
      List<Equipo> equipos = response.data["data"].map<Equipo>((equipo) {
        return Equipo.fromJson(equipo);
      }).toList();
      return equipos;
    } catch (e) {
      return [];
    }
  }
}
