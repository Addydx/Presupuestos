import 'package:hive/hive.dart';

part 'material.g.dart';

@HiveType(typeId: 4)
class Material {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  String categoria;

  @HiveField(2)
  String unidad;

  @HiveField(3)
  double cantidad;

  @HiveField(4)
  double precioUnitario;

  @HiveField(5)
  bool esPersonalizado;

  Material({
    required this.nombre,
    required this.categoria,
    required this.unidad,
    required this.cantidad,
    required this.precioUnitario,
    this.esPersonalizado = false,
  });

  double get total => cantidad * precioUnitario;
}
