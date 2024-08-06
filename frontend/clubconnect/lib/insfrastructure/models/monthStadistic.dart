import 'dart:convert';

class MonthStadisticUser {
  String year;
  String mes;
  int participation;
  int totalEventos;
  int percentile;
  int idUsuario;

  MonthStadisticUser({
    required this.year,
    required this.mes,
    required this.participation,
    required this.totalEventos,
    required this.percentile,
    required this.idUsuario,
  });

  factory MonthStadisticUser.fromRawJson(String str) =>
      MonthStadisticUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MonthStadisticUser.fromJson(Map<String, dynamic> json) =>
      MonthStadisticUser(
        year: json["year"],
        mes: json["mes"],
        participation: json["participation"],
        totalEventos: json["total_eventos"],
        percentile: json["percentile"],
        idUsuario: json["id_usuario"],
      );

  Map<String, dynamic> toJson() => {
        "year": year,
        "mes": mes,
        "participation": participation,
        "total_eventos": totalEventos,
        "percentile": percentile,
        "id_usuario": idUsuario,
      };
}
