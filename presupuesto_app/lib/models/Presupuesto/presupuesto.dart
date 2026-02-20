import 'package:hive/hive.dart';

// Este import es necesario para que Dart reconozca HiveType, HiveField y HiveObject.
@HiveType(typeId: 1)
class Presupuesto {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String descripcion;

  @HiveField(3)
  final List<Map<String, dynamic>> gastos;

  @HiveField(4)
  final String proyectoId;

  Presupuesto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.gastos,
    required this.proyectoId,
  });
}
