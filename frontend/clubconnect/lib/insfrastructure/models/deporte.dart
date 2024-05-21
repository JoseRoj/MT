import 'dart:convert';

class Deportes {
  List<Deporte> data;

  Deportes({
    required this.data,
  });

  factory Deportes.fromRawJson(String str) =>
      Deportes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Deportes.fromJson(Map<String, dynamic> json) => Deportes(
        data: List<Deporte>.from(json["data"].map((x) => Deporte.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Deporte {
  String id;
  String nombre;

  Deporte({
    required this.id,
    required this.nombre,
  });

  factory Deporte.fromRawJson(String str) => Deporte.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Deporte.fromJson(Map<String, dynamic> json) => Deporte(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
