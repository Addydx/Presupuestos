import 'package:hive/hive.dart';

// Este import es necesario para que Dart reconozca HiveType, HiveField y HiveObject.
@HiveType(typeId: 1)
class Presupuesto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String? descripcion;

  @HiveField(3)
  List<Map<String, dynamic>> gastos;

  @HiveField(4)
  String proyectoId;

  Presupuesto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.gastos,
    required this.proyectoId,
  });
}
