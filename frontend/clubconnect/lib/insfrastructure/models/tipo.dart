import 'dart:convert';

class Tipo {
  String id;
  String nombre;

  Tipo({
    required this.id,
    required this.nombre,
  });

  factory Tipo.fromRawJson(String str) => Tipo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Tipo.fromJson(Map<dynamic, dynamic> json) => Tipo(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
