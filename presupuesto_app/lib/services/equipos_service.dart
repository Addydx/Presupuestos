import 'package:hive/hive.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';

class EquiposService {
  static const String _boxName = 'equipos';

  // Singleton
  static final EquiposService _instance = EquiposService._internal();

  late Box<Equipo> _equiposBox;

  bool _initialized = false;

  // Constructor privado
  EquiposService._internal();

  // Factory constructor para obtener instancia única
  factory EquiposService() {
    return _instance;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    _equiposBox = await Hive.openBox<Equipo>(_boxName);

    _initialized = true;
  }

  // ==================== OPERACIONES CRUD ====================

  /// Obtener todos los equipos
  List<Equipo> obtenerEquipos() {
    return _equiposBox.values.toList();
  }

  /// Obtener equipo por ID
  Equipo? obtenerEquipoPorId(String id) {
    try {
      return _equiposBox.values.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Agregar nuevo equipo
  Future<void> agregarEquipo(Equipo equipo) async {
    await _equiposBox.put(equipo.id, equipo);
  }

  /// Actualizar equipo existente
  Future<void> actualizarEquipo(Equipo equipo) async {
    await _equiposBox.put(equipo.id, equipo);
  }

  /// Eliminar equipo por ID
  Future<void> eliminarEquipo(String id) async {
    await _equiposBox.delete(id);
  }

  /// Limpiar todos los equipos
  Future<void> limpiarEquipos() async {
    await _equiposBox.clear();
  }

  // ==================== CÁLCULOS ====================

  /// Calcular total general de todos los equipos
  double calcularTotalEquipos() {
    return _equiposBox.values.fold<double>(
      0,
      (sum, equipo) => sum + equipo.total,
    );
  }

  /// Obtener cantidad de equipos
  int obtenerCantidadEquipos() {
    return _equiposBox.length;
  }

  /// Calcular costo promedio por día
  double calcularPromedioCostoDia() {
    final equipos = _equiposBox.values.toList();
    if (equipos.isEmpty) return 0;
    return equipos.fold<double>(0, (sum, e) => sum + e.costoPorDia) /
        equipos.length;
  }

  /// Calcular días promedio
  double calcularPromedioDias() {
    final equipos = _equiposBox.values.toList();
    if (equipos.isEmpty) return 0;
    return equipos.fold<int>(0, (sum, e) => sum + e.dias) / equipos.length;
  }
}
