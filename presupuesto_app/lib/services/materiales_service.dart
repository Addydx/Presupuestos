import 'package:hive/hive.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/material_catalogo.dart';

class MaterialesService {
  static const String _boxNameCatalogo = 'materiales_catalogo';
  static const String _boxNamePresupuesto = 'materiales_presupuesto';

  // Singleton
  static final MaterialesService _instance = MaterialesService._internal();

  late Box<MaterialCatalogo> _catalogoBox;
  late Box<MaterialPresupuesto> _presupuestoBox;

  bool _initialized = false;

  // Constructor privado
  MaterialesService._internal();

  // Factory constructor para obtener instancia única
  factory MaterialesService() {
    return _instance;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    _catalogoBox = await Hive.openBox<MaterialCatalogo>(_boxNameCatalogo);
    _presupuestoBox = await Hive.openBox<MaterialPresupuesto>(
      _boxNamePresupuesto,
    );

    _initialized = true;
  }

  // ==================== CATÁLOGO ====================

  /// Obtener todos los materiales del catálogo
  List<MaterialCatalogo> obtenerCatalogos() {
    return _catalogoBox.values.toList();
  }

  /// Obtener materiales filtrados por categoría
  List<MaterialCatalogo> obtenerPorCategoria(String categoria) {
    return _catalogoBox.values
        .where((m) => m.categoria.toLowerCase() == categoria.toLowerCase())
        .toList();
  }

  /// Buscar materiales por nombre
  List<MaterialCatalogo> buscar(String termo) {
    final termoBajo = termo.toLowerCase();
    return _catalogoBox.values
        .where(
          (m) =>
              m.nombre.toLowerCase().contains(termoBajo) ||
              m.categoria.toLowerCase().contains(termoBajo),
        )
        .toList();
  }

  /// Obtener material del catálogo por ID
  MaterialCatalogo? obtenerCatalogoPorId(String id) {
    try {
      return _catalogoBox.values.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Agregar material al catálogo
  Future<void> agregarAlCatalogo(MaterialCatalogo material) async {
    await _catalogoBox.put(material.id, material);
  }

  /// Actualizar material del catálogo
  Future<void> actualizarCatalogo(MaterialCatalogo material) async {
    await _catalogoBox.put(material.id, material);
  }

  /// Eliminar del catálogo
  Future<void> eliminarDelCatalogo(String id) async {
    await _catalogoBox.delete(id);
  }

  /// Obtener todas las categorías del catálogo
  Set<String> obtenerCategorias() {
    return _catalogoBox.values.map((m) => m.categoria).toSet();
  }

  // ==================== MATERIALES DEL PRESUPUESTO ====================

  /// Agg material al presupuesto
  Future<void> agregarMaterialPresupuesto(MaterialPresupuesto material) async {
    await _presupuestoBox.put(material.id, material);
  }

  /// Actualizar material del presupuesto
  Future<void> actualizarMaterialPresupuesto(
    MaterialPresupuesto material,
  ) async {
    await _presupuestoBox.put(material.id, material);
  }

  /// Obtener todos los materiales del presupuesto
  List<MaterialPresupuesto> obtenerMaterialesPresupuesto() {
    return _presupuestoBox.values.toList();
  }

  /// Obtener material del presupuesto por ID
  MaterialPresupuesto? obtenerMaterialPresupuestoPorId(String id) {
    try {
      return _presupuestoBox.values.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Eliminar material del presupuesto
  Future<void> eliminarMaterialPresupuesto(String id) async {
    await _presupuestoBox.delete(id);
  }

  /// Limpiar todos los materiales del presupuesto
  Future<void> limpiarMaterialesPresupuesto() async {
    await _presupuestoBox.clear();
  }

  // ==================== CÁLCULOS ====================

  /// Calcular total general de materiales del presupuesto
  double calcularTotalMateriales() {
    double total = 0;
    for (var material in _presupuestoBox.values) {
      total += material.total;
    }
    return total;
  }

  /// Calcular subtotal por categoría
  Map<String, double> calcularSubtotalPorCategoria() {
    Map<String, double> subtotales = {};
    for (var material in _presupuestoBox.values) {
      final categoria = material.categoria;
      subtotales[categoria] = (subtotales[categoria] ?? 0) + material.total;
    }
    return subtotales;
  }

  /// Cantidad total de items
  int obtenerCantidadMateriales() {
    return _presupuestoBox.length;
  }
}
