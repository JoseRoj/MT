import 'dart:convert';

class ConfigEventos {
  String? id;
  DateTime fechaInicio;
  DateTime fechaFinal;
  String horaInicio;
  String horaFinal;
  String idEquipo;
  String descripcion;
  String lugar;
  int diaRepetible;
  String titulo;

  ConfigEventos({
    this.id,
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

  factory ConfigEventos.fromRawJson(String str) =>
      ConfigEventos.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ConfigEventos.fromJson(Map<String, dynamic> json) => ConfigEventos(
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
