/// Modelo de datos para representar un proyecto
class Proyecto {
  final String id;
  final String nombreProyecto;
  final String nombreCliente;
  final String? descripcion;
  final String? imagenPath;
  final DateTime fechaCreacion;

  Proyecto({
    required this.id,
    required this.nombreProyecto,
    required this.nombreCliente,
    this.descripcion,
    this.imagenPath,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  /// Crea una copia del proyecto con los campos modificados
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
