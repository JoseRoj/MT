import 'dart:convert';

class UserTeam {
  String id;
  String nombre;
  String email;
  String apellido1;
  String apellido2;
  String genero;
  String imagen;
  DateTime fechaNacimiento;
  String telefono;
  List<EquipoUser> equipos;

  UserTeam({
    required this.id,
    required this.nombre,
    required this.email,
    required this.apellido1,
    required this.apellido2,
    required this.genero,
    required this.imagen,
    required this.fechaNacimiento,
    required this.telefono,
    required this.equipos,
  });

  factory UserTeam.fromRawJson(String str) =>
      UserTeam.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserTeam.fromJson(Map<String, dynamic> json) => UserTeam(
        id: json["id"],
        nombre: json["nombre"],
        email: json["email"],
        apellido1: json["apellido1"],
        apellido2: json["apellido2"],
        genero: json["genero"],
        imagen: json["imagen"],
        fechaNacimiento: DateTime.parse(json["fecha_nacimiento"]),
        telefono: json["telefono"],
        equipos: List<EquipoUser>.from(
            json["equipos"].map((x) => EquipoUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "email": email,
        "apellido1": apellido1,
        "apellido2": apellido2,
        "genero": genero,
        "imagen": imagen,
        "fecha_nacimiento": fechaNacimiento.toIso8601String(),
        "telefono": telefono,
        "equipos": List<dynamic>.from(equipos.map((x) => x.toJson())),
      };
}

class EquipoUser {
  String? id;
  String nombre;
  String rol;

  EquipoUser({
    this.id,
    required this.nombre,
    required this.rol,
  });

  factory EquipoUser.fromRawJson(String str) =>
      EquipoUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EquipoUser.fromJson(Map<String, dynamic> json) => EquipoUser(
        id: json["id"] ?? "",
        nombre: json["nombre"],
        rol: json["rol"],
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? "",
        "nombre": nombre,
        "rol": rol,
      };
}
