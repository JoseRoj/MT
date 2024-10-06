class EstadosEventos {
  static const String activo = 'Activo';
  static const String terminado = 'Finalizado';
  static const String todos = 'Todos';
}

class MonthYear {
  MonthYear(this.month, this.year, this.nameMonth);
  final String nameMonth;
  final int month;
  final int year;
}

List<String> generos = [
  "Masculino",
  "Femenino",
  "Otro",
];

final List<String> daysOfWeek = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo'
];

final List<Meses> Months = <Meses>[
  Meses("Enero", 1),
  Meses("Febrero", 2),
  Meses("Marzo", 3),
  Meses("Abril", 4),
  Meses("Mayo", 5),
  Meses("Junio", 6),
  Meses("Julio", 7),
  Meses("Agosto", 8),
  Meses("Septiembre", 9),
  Meses("Octubre", 10),
  Meses("Noviembre", 11),
  Meses("Diciembre", 12),
];

class Meses {
  Meses(this.mes, this.value);
  final String mes;
  final int value;
}
