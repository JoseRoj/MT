import 'package:clubconnect/insfrastructure/models/club.dart';

List<int> getIdClubes(List<Club> clubes) {
  List<int> idClubes = [];
  if (clubes.isNotEmpty) {
    idClubes = clubes.map((element) => int.parse(element.id!)).toList();
  }
  return idClubes;
}
