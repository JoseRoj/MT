import 'dart:convert';
import 'package:clubconnect/insfrastructure/models/club.dart';

import 'dart:convert';

class Post {
  String id;
  DateTime fechaPublicacion;
  DateTime fechaEvento;
  bool estado;
  String clubId;
  Club? club;

  String image;

  Post({
    required this.id,
    required this.fechaPublicacion,
    required this.fechaEvento,
    required this.estado,
    required this.clubId,
    this.club,
    required this.image,
  });

  factory Post.fromRawJson(String str) => Post.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        fechaPublicacion: DateTime.parse(json["fecha_publicacion"]),
        fechaEvento: DateTime.parse(json["fecha_evento"]),
        //club: json["club"] ? Club.fromJson(json["club"]) : null,
        estado: json["estado"],
        clubId: json["club_id"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fecha_publicacion": fechaPublicacion.toIso8601String(),
        "fecha_evento": fechaEvento.toIso8601String(),
        "estado": estado,
        "club_id": clubId,
        "image": image,
        "club": club?.toJson(),
      };
}
