import 'dart:convert';

class Solicitud {
  String id;
  String nombre;
  String email;
  String telefono;
  String contrasena;
  DateTime fechaNacimiento;
  String apellido1;
  String genero;
  String apellido2;
  String imagen;
  String estado;
  DateTime fechaSolicitud;

  Solicitud({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.contrasena,
    required this.fechaNacimiento,
    required this.apellido1,
    required this.genero,
    required this.apellido2,
    required this.imagen,
    required this.estado,
    required this.fechaSolicitud,
  });

  factory Solicitud.fromRawJson(String str) =>
      Solicitud.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Solicitud.fromJson(Map<String, dynamic> json) => Solicitud(
        id: json["id"],
        nombre: json["nombre"],
        email: json["email"],
        telefono: json["telefono"],
        contrasena: json["contrasena"],
        fechaNacimiento: DateTime.parse(json["fecha_nacimiento"]),
        apellido1: json["apellido1"],
        genero: json["genero"],
        apellido2: json["apellido2"],
        imagen: json["imagen"],
        estado: json["estado"],
        fechaSolicitud: DateTime.parse(json["fecha_solicitud"]),
      );

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
        "imagen": imagen,
        "estado": estado,
        "fecha_solicitud": fechaSolicitud.toIso8601String(),
      };
}
