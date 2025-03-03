import 'dart:convert';

class Evento {
  String? id;
  String descripcion;
  DateTime fecha;
  String horaInicio;
  String horaFinal;
  String estado;
  String idEquipo;
  String titulo;
  String lugar;

  Evento({
    this.id,
    required this.descripcion,
    required this.fecha,
    required this.horaInicio,
    required this.horaFinal,
    required this.estado,
    required this.idEquipo,
    required this.titulo,
    required this.lugar,
  });

  factory Evento.fromRawJson(String str) => Evento.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(
        id: json["id"],
        descripcion: json["descripcion"],
        fecha: DateTime.parse(json["fecha"]),
        horaInicio: json["hora_inicio"],
        horaFinal: json["hora_final"],
        estado: json["estado"],
        idEquipo: json["id_equipo"],
        titulo: json["titulo"],
        lugar: json["lugar"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "descripcion": descripcion,
        "fecha": fecha.toIso8601String(),
        "hora_inicio": horaInicio,
        "hora_final": horaFinal,
        "estado": estado,
        "id_equipo": idEquipo,
        "titulo": titulo,
        "lugar": lugar,
      };
}

class EventoFull {
  Evento evento;
  List<Asistente> asistentes;

  EventoFull({
    required this.evento,
    required this.asistentes,
  });

  factory EventoFull.fromRawJson(String str) =>
      EventoFull.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EventoFull.fromJson(Map<String, dynamic> json) => EventoFull(
        evento: Evento.fromJson(json["evento"]),
        asistentes: List<Asistente>.from(
            json["asistentes"].map((x) => Asistente.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "evento": evento.toJson(),
        "asistentes": List<dynamic>.from(asistentes.map((x) => x.toJson())),
      };
}

class Asistente {
  String nombre;
  String apellido1;
  String id;

  Asistente({
    required this.nombre,
    required this.apellido1,
    required this.id,
  });

  factory Asistente.fromRawJson(String str) =>
      Asistente.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Asistente.fromJson(Map<String, dynamic> json) => Asistente(
        nombre: json["nombre"],
        apellido1: json["apellido1"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "apellido1": apellido1,
        "id": id,
      };
}
