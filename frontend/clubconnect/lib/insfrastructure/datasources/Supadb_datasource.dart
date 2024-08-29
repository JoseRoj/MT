import 'dart:convert';
import 'package:clubconnect/domain/datasources/clubConnect_datasource.dart';
import 'package:clubconnect/insfrastructure/models.dart';
import 'package:clubconnect/insfrastructure/models/categoria.dart';
import 'package:clubconnect/insfrastructure/models/club.dart';
import 'package:clubconnect/insfrastructure/models/deporte.dart';
import 'package:clubconnect/insfrastructure/models/eventoStadistic.dart';
import 'package:clubconnect/insfrastructure/models/monthStadistic.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/userTeam.dart';

class SupabdDatasource extends ClubConnectDataSource {
  @override
  Future<List<Club>> getClubs(List<int> deportes, double northeastLat,
      double northeastLng, double southwestLat, double southwestLng) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get('${dotenv.env["API_URL"]}/club/getclubs',
        data: jsonEncode(<String, dynamic>{
          "deportes": deportes,
          "northeastLat": northeastLat,
          "northeastLng": northeastLng,
          "southwestLat": southwestLat,
          "southwestLng": southwestLng,
        }));
    if (response.statusCode != 200) return [];
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
  Future<dynamic> editClub(Club club, List categorias, List tipos) async {
    final dio = Dio(BaseOptions(headers: {}));
    try {
      final response = await dio.put('${dotenv.env["API_URL"]}/club/editclub',
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
            "id": club.id,
            "facebook": club.facebook,
            "instagram": club.instagram,
            "tiktok": club.tiktok
          }));
      return response;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<dynamic> updateImagenClub(String image, int idclub) async {
    final dio = Dio(BaseOptions(headers: {}));
    try {
      final response = await dio.patch(
          '${dotenv.env["API_URL"]}/club/updateImage',
          data: jsonEncode(<String, dynamic>{"imagen": image, "id": idclub}));
      return response;
    } catch (e) {
      return false;
    }
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
            "id": club.id,
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
            "facebook": club.facebook,
            "instagram": club.instagram,
            "tiktok": club.tiktok
          }));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteMiembroClub(int idusuario, int idclub) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.delete(
        '${dotenv.env["API_URL"]}/club/deletemiembro',
        data: jsonEncode(
          <String, dynamic>{
            "id_usuario": idusuario,
            "id_club": idclub,
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
      print("Error: $e");
      return null;
    }
    return null;
  }

  @override
  Future<bool> updateToken(int idusuario, String tokenfb) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.patch(
        '${dotenv.env["API_URL"]}/token',
        data: jsonEncode(
          <String, dynamic>{
            "id_usuario": idusuario,
            "tokenfb": tokenfb,
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
  Future<List<MonthStadisticUser>> getMonthStadisticUser(
      int idusuario, int idequipo) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/usuarios/stadistic',
      queryParameters: {'id_usuario': idusuario, 'id_equipo': idequipo},
    );
    if (response.statusCode != 200) return [];
    List<MonthStadisticUser> stadistics =
        response.data["data"].map<MonthStadisticUser>((stadistic) {
      return MonthStadisticUser.fromJson(stadistic);
    }).toList();
    return stadistics;
  }

  @override
  Future<bool?> updateImageUser(String image, int usuario) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.patch(
        '${dotenv.env["API_URL"]}/usuarios/updateImage',
        data: jsonEncode(
          <String, dynamic>{
            "imagen": image,
            "id": usuario,
          },
        ),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> getRole(int idusuario, int idclub, int? idequipo) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/usuarios/rol',
      queryParameters: {
        'id_usuario': idusuario,
        'id_club': idclub,
        'id_equipo': idequipo
      },
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
  Future<List<User>> getMiembrosEquipo(int idequipo) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.get(
        '${dotenv.env["API_URL"]}/equipo/miembros',
        queryParameters: {'id_equipo': idequipo},
      );
      if (response.statusCode != 200) return [];
      List<User> users = response.data["data"].map<User>((user) {
        return User.fromJson(user);
      }).toList();
      return users;
    } catch (e) {
      return [];
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
  Future<bool> addMiembro(int idusuario, int idequipo, String rol) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.post(
        '${dotenv.env["API_URL"]}/miembro/addMiembroEquipo',
        data: jsonEncode(
          <String, dynamic>{
            "id_usuario": idusuario,
            "id_equipo": idequipo,
            "rol": rol,
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
  Future<bool> deleteMiembro(int idusuario, int idequipo) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.delete(
        '${dotenv.env["API_URL"]}/miembro/deleteMiembroEquipo',
        data: jsonEncode(
          <String, dynamic>{
            "id_usuario": idusuario,
            "id_equipo": idequipo,
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
  Future<List<UserTeam>> getMiembros(int idclub) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.get(
        '${dotenv.env["API_URL"]}/club/getmiembros',
        queryParameters: {'id_club': idclub},
      );
      List<UserTeam> users = response.data["data"].map<UserTeam>((user) {
        return UserTeam.fromJson(user);
      }).toList();

      return users;
    } catch (e) {
      print("Error: $e");

      return [];
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
      print(response.data["data"]);
      if (response.data["data"] == "Admin") return "Admin";
      if (response.data["data"] == "") return "";
      return response.data["data"][0]["estado"];
    } catch (e) {
      return null;
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

  @override
  Future<bool> deleteEquipo(int idequipo) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.delete(
        '${dotenv.env["API_URL"]}/equipo/deleteEquipo',
        queryParameters: {
          'id_equipo': idequipo,
        },
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
  Future<bool> updateSolicitud(int idusuario, int idclub, String estado) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.patch(
        '${dotenv.env["API_URL"]}/solicitud',
        data: jsonEncode(
          <String, dynamic>{
            "id_usuario": idusuario,
            "id_club": idclub,
            "estado": estado,
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
  Future<List<EventoFull>?> getEventos(int idequipo, String estado,
      DateTime initialDate, int month, int year) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/eventos',
      queryParameters: {
        'id_equipo': idequipo,
        'estado': estado,
        'initialDate': initialDate,
        'month': month,
        'year': year
      },
    );

    if (response.data["data"].length <= 0) return [];
    List<EventoFull> eventos = response.data["data"].map<EventoFull>((evento) {
      return EventoFull.fromJson(evento);
    }).toList();
    return eventos;
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
    try {
      final dio = Dio(BaseOptions(headers: {}));

      final response = await dio.post(
        '${dotenv.env["API_URL"]}/eventos',
        data: jsonEncode(
          <String, dynamic>{
            "fechas": fechas,
            "horaFin": horaFinal,
            "descripcion": descripcion,
            "horaInicio": horaInicio,
            "id_equipo": idequipo,
            "id_club": idclub,
            "titulo": titulo,
            "lugar": lugar,
          },
        ),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  @override
  Future<Evento> getEvento(int idevento) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/evento',
      queryParameters: {'id_evento': idevento},
    );
    Evento evento = Evento.fromJson(response.data["data"]);
    return evento;
  }

  @override
  Future<bool> deleteEvento(int idevento) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.delete(
      '${dotenv.env["API_URL"]}/eventos',
      data: jsonEncode(<String, dynamic>{"id_evento": idevento}),
    );
    return response.statusCode == 200 ? true : false;
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
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.put(
        '${dotenv.env["API_URL"]}/eventos',
        data: jsonEncode(
          <String, dynamic>{
            "fecha": fecha,
            "horaInicio": horaInicio,
            "descripcion": descripcion,
            "horaFin": horaFinal,
            "id_evento": idevento,
            "titulo": titulo,
            "lugar": lugar,
            "asistentesDelete": asistentesDelete
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
  Future<bool> updateEstadoEvento(int idevento, String estado) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.patch(
        '${dotenv.env["API_URL"]}/eventos/estado',
        data: jsonEncode(
          <String, dynamic>{
            "id_evento": idevento,
            "estado": estado,
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
  Future<bool> addAsistencia(int idevento, int idusuario) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.post(
        '${dotenv.env["API_URL"]}/asistencia',
        data: jsonEncode(
          <String, dynamic>{
            "id_evento": idevento,
            "id_usuario": idusuario,
          },
        ),
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
  Future<bool> deleteAsistencia(int idevento, int idusuario) async {
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.delete(
        '${dotenv.env["API_URL"]}/asistencia',
        data: jsonEncode(
          <String, dynamic>{
            "id_evento": idevento,
            "id_usuario": idusuario,
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

  //* --------------- CONFIGURACION EVENTOS ----------------*//
  @override
  Future<List<ConfigEventos>> getConfigEventos(int idequipo) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/configEventos',
      queryParameters: {'id_equipo': idequipo},
    );
    List<ConfigEventos> configEventos =
        response.data["data"].map<ConfigEventos>((configEvento) {
      return ConfigEventos.fromJson(configEvento);
    }).toList();
    return configEventos;
  }

  @override
  Future<dynamic> createConfigEvento(ConfigEventos configEvento) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.post(
      '${dotenv.env["API_URL"]}/configEvento',
      data: jsonEncode(configEvento.toJson()),
    );
    return response;
  }

  @override
  Future<dynamic> deleteConfigEvento(int idConfig) {
    final dio = Dio(BaseOptions(headers: {}));
    final response = dio.delete(
      '${dotenv.env["API_URL"]}/configEvento',
      queryParameters: {'id_config': idConfig},
    );
    return response;
  }

  @override
  Future<dynamic> editConfigEvento(ConfigEventos configEvento) {
    final dio = Dio(BaseOptions(headers: {}));
    final response = dio.put(
      '${dotenv.env["API_URL"]}/configEvento',
      data: jsonEncode(configEvento.toJson()),
    );
    return response;
  }

  @override
  Future<EventoStadistic> getEventoStadistic(
      DateTime initDate, DateTime endDate, int idequipo, int idClub) async {
    final dio = Dio(BaseOptions(headers: {}));
    final response = await dio.get(
      '${dotenv.env["API_URL"]}/equipo/stadistic',
      queryParameters: {
        'fecha_inicio': initDate,
        'fecha_final': endDate,
        'id_equipo': idequipo,
        'id_club': idClub
      },
    );
    EventoStadistic stadistic = EventoStadistic.fromJson(response.data["data"]);

    return stadistic;
  }
}
