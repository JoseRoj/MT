import 'dart:convert';

class Categorias {
  List<Categoria> data;

  Categorias({
    required this.data,
  });

  factory Categorias.fromRawJson(String str) =>
      Categorias.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Categorias.fromJson(Map<String, dynamic> json) => Categorias(
        data: List<Categoria>.from(
            json["data"].map((x) => Categoria.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Categoria {
  int id;
  String nombre;

  Categoria({
    required this.id,
    required this.nombre,
  });

  factory Categoria.fromRawJson(String str) =>
      Categoria.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
