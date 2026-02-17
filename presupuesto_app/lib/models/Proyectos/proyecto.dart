import 'package:hive/hive.dart';

part '../proyecto.g.dart';

@HiveType(typeId: 0)
class Proyecto {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombreProyecto;

  @HiveField(2)
  final String nombreCliente;

  @HiveField(3)
  final String? descripcion;

  @HiveField(4)
  final String? imagenPath;

  @HiveField(5)
  final DateTime fechaCreacion;

  Proyecto({
    required this.id,
    required this.nombreProyecto,
    required this.nombreCliente,
    this.descripcion,
    this.imagenPath,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Proyecto copyWith({
    String? id,
    String? nombreProyecto,
    String? nombreCliente,
    String? descripcion,
    String? imagenPath,
    DateTime? fechaCreacion,
  }) {
    return Proyecto(
      id: id ?? this.id,
      nombreProyecto: nombreProyecto ?? this.nombreProyecto,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      descripcion: descripcion ?? this.descripcion,
      imagenPath: imagenPath ?? this.imagenPath,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
