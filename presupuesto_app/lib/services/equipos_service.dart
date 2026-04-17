import 'package:hive/hive.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';

class EquiposService {
  static const String _boxName = 'equipos';

  // Singleton
  static final EquiposService _instance = EquiposService._internal();

  final List<Equipo> _equiposTemporales = [];

  bool _initialized = false;

  // Constructor privado
  EquiposService._internal();

  // Factory constructor para obtener instancia única
  factory EquiposService() {
    return _instance;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.openBox<Equipo>(_boxName);

    _initialized = true;
  }

  // ==================== OPERACIONES CRUD ====================

  /// Obtener todos los equipos
  List<Equipo> obtenerEquipos() {
    return List<Equipo>.from(_equiposTemporales);
  }

  /// Reemplaza los equipos temporales del presupuesto actual.
  Future<void> cargarEquipos(List<Equipo> equipos) async {
    _equiposTemporales
      ..clear()
      ..addAll(equipos);
  }

  /// Obtener equipo por ID
  Equipo? obtenerEquipoPorId(String id) {
    try {
      return _equiposTemporales.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Agregar nuevo equipo
  Future<void> agregarEquipo(Equipo equipo) async {
    _equiposTemporales.add(equipo);
  }

  /// Actualizar equipo existente
  Future<void> actualizarEquipo(Equipo equipo) async {
    final index = _equiposTemporales.indexWhere((e) => e.id == equipo.id);
    if (index == -1) {
      _equiposTemporales.add(equipo);
      return;
    }

    _equiposTemporales[index] = equipo;
  }

  /// Eliminar equipo por ID
  Future<void> eliminarEquipo(String id) async {
    _equiposTemporales.removeWhere((equipo) => equipo.id == id);
  }

  /// Limpiar todos los equipos
  Future<void> limpiarEquipos() async {
    _equiposTemporales.clear();
  }

  // ==================== CÁLCULOS ====================

  /// Calcular total general de todos los equipos
  double calcularTotalEquipos() {
    return _equiposTemporales.fold<double>(
      0,
      (sum, equipo) => sum + equipo.total,
    );
  }

  /// Obtener cantidad de equipos
  int obtenerCantidadEquipos() {
    return _equiposTemporales.length;
  }

  /// Calcular costo promedio por día
  double calcularPromedioCostoDia() {
    final equipos = _equiposTemporales.toList();
    if (equipos.isEmpty) return 0;
    return equipos.fold<double>(0, (sum, e) => sum + e.costoPorDia) /
        equipos.length;
  }

  /// Calcular días promedio
  double calcularPromedioDias() {
    final equipos = _equiposTemporales.toList();
    if (equipos.isEmpty) return 0;
    return equipos.fold<int>(0, (sum, e) => sum + e.dias) / equipos.length;
  }
}
