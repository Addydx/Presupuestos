import 'package:hive/hive.dart';

part 'equipo.g.dart';

@HiveType(typeId: 3)
class Equipo {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  double costoPorDia;

  @HiveField(2)
  int dias;

  Equipo({required this.nombre, required this.costoPorDia, required this.dias});
}
