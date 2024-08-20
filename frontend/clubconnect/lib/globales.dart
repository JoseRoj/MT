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

final List<String> daysOfWeek = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo'
];
