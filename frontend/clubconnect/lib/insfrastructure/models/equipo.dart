import 'dart:convert';

class Equipo {
  String? id;
  String nombre;
  String idClub;

  Equipo({
    this.id,
    required this.nombre,
    required this.idClub,
  });

  factory Equipo.fromRawJson(String str) => Equipo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Equipo.fromJson(Map<String, dynamic> json) => Equipo(
        id: json["id"],
        nombre: json["nombre"],
        idClub: json["id_club"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "id_club": idClub,
      };
}
