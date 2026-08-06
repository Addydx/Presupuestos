import 'package:hive/hive.dart';

part 'equipo.g.dart';

@HiveType(typeId: 2)
class Equipo {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  double costoPorDia;

  @HiveField(3)
  int dias;

  Equipo({
    String? id,
    required this.nombre,
    required this.costoPorDia,
    required this.dias,
  }) : id = id ?? DateTime.now().toString();

  /// Total = costoPorDia * dias
  double get total => costoPorDia * dias;

  @override
  String toString() =>
      'Equipo(nombre: $nombre, $dias días x \$$costoPorDia = \$$total)';
}
