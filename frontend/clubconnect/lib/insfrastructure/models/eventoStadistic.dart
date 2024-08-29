import 'dart:convert';

import 'package:clubconnect/insfrastructure/models/evento.dart';

class EventoStadistic {
  List<Evento> eventos;
  List<Recurrente> recurrentes;
  List<UserList> userList;

  EventoStadistic({
    required this.eventos,
    required this.recurrentes,
    required this.userList,
  });

  factory EventoStadistic.fromRawJson(String str) =>
      EventoStadistic.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EventoStadistic.fromJson(Map<String, dynamic> json) =>
      EventoStadistic(
        eventos:
            List<Evento>.from(json["eventos"].map((x) => Evento.fromJson(x))),
        recurrentes: List<Recurrente>.from(
            json["recurrentes"].map((x) => Recurrente.fromJson(x))),
        userList: List<UserList>.from(
            json["userList"].map((x) => UserList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "eventos": List<dynamic>.from(eventos.map((x) => x.toJson())),
        "recurrentes": List<dynamic>.from(recurrentes.map((x) => x.toJson())),
        "userList": List<dynamic>.from(userList.map((x) => x.toJson())),
      };
}

class Asistente {
  String nombre;
  String apellido1;
  String apellido2;
  String id;
  String imagen;

  Asistente({
    required this.nombre,
    required this.apellido1,
    required this.apellido2,
    required this.id,
    required this.imagen,
  });

  factory Asistente.fromRawJson(String str) =>
      Asistente.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Asistente.fromJson(Map<String, dynamic> json) => Asistente(
        nombre: json["nombre"],
        apellido1: json["apellido1"],
        apellido2: json["apellido2"],
        id: json["id"],
        imagen: json["imagen"],
      );

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "apellido1": apellido1,
        "apellido2": apellido2,
        "id": id,
        "imagen": imagen,
      };
}

class Recurrente {
  String id;
  DateTime fechaInicio;
  DateTime fechaFinal;
  String horaInicio;
  String horaFinal;
  String idEquipo;
  String descripcion;
  String lugar;
  int diaRepetible;
  String titulo;

  Recurrente({
    required this.id,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.horaInicio,
    required this.horaFinal,
    required this.idEquipo,
    required this.descripcion,
    required this.lugar,
    required this.diaRepetible,
    required this.titulo,
  });

  factory Recurrente.fromRawJson(String str) =>
      Recurrente.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Recurrente.fromJson(Map<String, dynamic> json) => Recurrente(
        id: json["id"],
        fechaInicio: DateTime.parse(json["fecha_inicio"]),
        fechaFinal: DateTime.parse(json["fecha_final"]),
        horaInicio: json["hora_inicio"],
        horaFinal: json["hora_final"],
        idEquipo: json["id_equipo"],
        descripcion: json["descripcion"],
        lugar: json["lugar"],
        diaRepetible: json["dia_repetible"],
        titulo: json["titulo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fecha_inicio": fechaInicio.toIso8601String(),
        "fecha_final": fechaFinal.toIso8601String(),
        "hora_inicio": horaInicio,
        "hora_final": horaFinal,
        "id_equipo": idEquipo,
        "descripcion": descripcion,
        "lugar": lugar,
        "dia_repetible": diaRepetible,
        "titulo": titulo,
      };
}

class UserList {
  String nombrecompleto;
  String totalAsistencias;

  UserList({
    required this.nombrecompleto,
    required this.totalAsistencias,
  });

  factory UserList.fromRawJson(String str) =>
      UserList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
        nombrecompleto: json["nombrecompleto"],
        totalAsistencias: json["total_asistencias"],
      );

  Map<String, dynamic> toJson() => {
        "nombrecompleto": nombrecompleto,
        "total_asistencias": totalAsistencias,
      };
}
