import 'dart:convert';

class LocalVideoModel {
  String estado;
  String club;
  DateTime fechaEvento;
  String url;
  DateTime fechaPublicacion;

  LocalVideoModel({
    required this.estado,
    required this.club,
    required this.fechaEvento,
    required this.url,
    required this.fechaPublicacion,
  });

  factory LocalVideoModel.fromRawJson(String str) =>
      LocalVideoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) =>
      LocalVideoModel(
        estado: json["estado"],
        club: json["club"],
        fechaEvento: DateTime.parse(json["fecha_evento"]),
        url: json["url"],
        fechaPublicacion: DateTime.parse(json["fecha_publicacion"]),
      );

  Map<String, dynamic> toJson() => {
        "estado": estado,
        "club": club,
        "fecha_evento": fechaEvento.toIso8601String(),
        "url": url,
        "fecha_publicacion": fechaPublicacion.toIso8601String(),
      };
}
