import 'dart:convert';

class ClubEspecifico {
  Club club;
  List<String> categorias;
  List<String> tipo;

  ClubEspecifico({
    required this.club,
    required this.categorias,
    required this.tipo,
  });

  factory ClubEspecifico.fromRawJson(String str) =>
      ClubEspecifico.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClubEspecifico.fromJson(Map<String, dynamic> json) => ClubEspecifico(
        club: Club.fromJson(json["club"]),
        categorias: List<String>.from(json["categorias"].map((x) => x)),
        tipo: List<String>.from(json["tipo"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "club": club.toJson(),
        "categorias": List<dynamic>.from(categorias.map((x) => x)),
        "tipo": List<dynamic>.from(tipo.map((x) => x)),
      };
}

class Club {
  String? id;
  double latitud;
  DateTime? createdAt;
  double longitud;
  String nombre;
  String descripcion;
  String idDeporte;
  String logo;
  String correo;
  String telefono;
  String? deporte;

  Club({
    this.id,
    required this.latitud,
    this.createdAt,
    required this.longitud,
    required this.nombre,
    required this.descripcion,
    required this.idDeporte,
    required this.logo,
    required this.correo,
    required this.telefono,
    this.deporte,
  });

  factory Club.fromRawJson(String str) => Club.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Club.fromJson(Map<String, dynamic> json) => Club(
        id: json["id"],
        latitud: json["latitud"]?.toDouble(),
        createdAt: DateTime.parse(json["created_at"]),
        longitud: json["longitud"]?.toDouble(),
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        idDeporte: json["id_deporte"],
        logo: json["logo"],
        correo: json["correo"],
        telefono: json["telefono"],
        deporte: json["deporte"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "latitud": latitud,
        "created_at": createdAt?.toIso8601String(),
        "longitud": longitud,
        "nombre": nombre,
        "descripcion": descripcion,
        "id_deporte": idDeporte,
        "logo": logo,
        "correo": correo,
        "telefono": telefono,
        "deporte": deporte,
      };
}
