import 'package:hive/hive.dart';

part 'material_catalogo.g.dart';

@HiveType(typeId: 5)
class MaterialCatalogo {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String categoria;

  @HiveField(3)
  String unidad;

  @HiveField(4)
  double precioReferencia;

  @HiveField(5)
  String? imagen;

  @HiveField(6)
  String? tienda;

  @HiveField(7)
  DateTime fechaCreacion;

  MaterialCatalogo({
    String? id,
    required this.nombre,
    required this.categoria,
    required this.unidad,
    required this.precioReferencia,
    this.imagen,
    this.tienda,
    DateTime? fechaCreacion,
  }) : id = id ?? DateTime.now().toString(),
       fechaCreacion = fechaCreacion ?? DateTime.now();

  @override
  String toString() =>
      'MaterialCatalogo(nombre: $nombre, categoria: $categoria, precio: \$$precioReferencia)';
}
