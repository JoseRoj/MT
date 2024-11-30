import 'dart:convert';

import 'package:clubconnect/insfrastructure/models/post.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class ClubEspecifico {
  Club club;
  List<String> categorias;
  List<String> tipo;
  List<Post> eventos;

  ClubEspecifico({
    required this.club,
    required this.categorias,
    required this.tipo,
    required this.eventos,
  });

  factory ClubEspecifico.fromRawJson(String str) =>
      ClubEspecifico.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClubEspecifico.fromJson(Map<String, dynamic> json) => ClubEspecifico(
        club: Club.fromJson(json["club"]),
        categorias: List<String>.from(json["categorias"].map((x) => x)),
        tipo: List<String>.from(json["tipo"].map((x) => x)),
        eventos: List<Post>.from(json["eventos"].map((x) => Post.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "club": club.toJson(),
        "categorias": List<dynamic>.from(categorias.map((x) => x)),
        "tipo": List<dynamic>.from(tipo.map((x) => x)),
        "eventos": List<dynamic>.from(eventos.map((evento) => evento.toJson())),
      };
}

class Club implements ClusterItem {
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
  String? facebook;
  String? instagram;
  String? tiktok;

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
    this.facebook,
    this.instagram,
    this.tiktok,
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
        instagram: json["instagram"] ?? "",
        facebook: json["facebook"] ?? "",
        tiktok: json["tiktok"] ?? "",
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
        "instagram": instagram,
        "facebook": facebook,
        "tiktok": tiktok,
        "deporte": deporte,
      };

  @override
  String get geohash => "Lat";

  @override
  LatLng get location => LatLng(latitud, longitud);
}
