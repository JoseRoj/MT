import 'dart:convert';

class User {
  String? id;
  String nombre;
  String email;
  String telefono;
  String contrasena;
  DateTime fechaNacimiento;
  String apellido1;
  String genero;
  String apellido2;
  dynamic imagen;

  User({
    this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.contrasena,
    required this.fechaNacimiento,
    required this.apellido1,
    required this.genero,
    required this.apellido2,
    this.imagen,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["id"],
      nombre: json["nombre"],
      email: json["email"],
      telefono: json["telefono"],
      contrasena: json["contrasena"],
      fechaNacimiento: DateTime.parse(json["fecha_nacimiento"]),
      apellido1: json["apellido1"],
      genero: json["genero"],
      apellido2: json["apellido2"],
      imagen: json["imagen"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "email": email,
        "telefono": telefono,
        "contrasena": contrasena,
        "fecha_nacimiento": fechaNacimiento.toIso8601String(),
        "apellido1": apellido1,
        "genero": genero,
        "apellido2": apellido2,
        "imagen": imagen
      };
}
