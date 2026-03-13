import 'package:hive/hive.dart';

part 'material.g.dart';

@HiveType(typeId: 4)
class MaterialPresupuesto {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  String unidad;

  @HiveField(4)
  double cantidad;

  @HiveField(5)
  double precioUnitario;

  @HiveField(6)
  bool esPersonalizado;

  @HiveField(7)
  String? materialCatalogoId;

  MaterialPresupuesto({
    String? id,
    required this.nombre,
    required this.categoria,
    required this.unidad,
    required this.cantidad,
    required this.precioUnitario,
    this.esPersonalizado = false,
    this.materialCatalogoId,
  }) : id = id ?? DateTime.now().toString();

  /// Total = cantidad * precioUnitario
  double get total => cantidad * precioUnitario;

  @override
  String toString() =>
      'MaterialPresupuesto(nombre: $nombre, cantidad: $cantidad x \$$precioUnitario = \$$total)';
}
