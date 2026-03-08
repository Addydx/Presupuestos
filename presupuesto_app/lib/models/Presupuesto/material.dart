

class Material {
  String nombre;
  String categoria;
  String unidad;

  double cantidad;
  double precioUnitario;

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