import 'package:hive/hive.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';

class PresupuestosService {
  static const String _boxName = 'presupuestos';
  static final PresupuestosService _instance = PresupuestosService._internal();
  static bool _initialized = false;
  late Box<Presupuesto> _box;

  PresupuestosService._internal();

  factory PresupuestosService() {
    return _instance;
  }

  /// Inicializa el servicio y abre la caja de Hive
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PresupuestoAdapter());
      }

      _box = await Hive.openBox<Presupuesto>(_boxName);
      _initialized = true;
      print('PresupuestosService inicializado exitosamente');
    } catch (e) {
      print('Error al inicializar PresupuestosService: $e');
      rethrow;
    }
  }

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _initialized;

  /// Obtiene la caja de Hive
  Box<Presupuesto> get box {
    if (!_initialized) {
      throw Exception(
        'PresupuestosService no está inicializado. Llama a initialize() primero.',
      );
    }
    return _box;
  }

  /// Agrega un nuevo presupuesto
  Future<void> agregarPresupuesto(Presupuesto presupuesto) async {
    try {
      await _box.put(presupuesto.id, presupuesto);
      print('Presupuesto guardado: ${presupuesto.id}');
    } catch (e) {
      print('Error al guardar presupuesto: $e');
      rethrow;
    }
  }

  /// Obtiene todos los presupuestos de un proyecto específico
  List<Presupuesto> obtenerPresupuestosPorProyecto(String proyectoId) {
    try {
      final presupuestos =
          _box.values.where((p) => p.proyectoId == proyectoId).toList();
      return presupuestos;
    } catch (e) {
      print('Error al obtener presupuestos del proyecto: $e');
      return [];
    }
  }

  /// Obtiene todos los presupuestos
  List<Presupuesto> obtenerTodos() {
    try {
      return _box.values.toList();
    } catch (e) {
      print('Error al obtener presupuestos: $e');
      return [];
    }
  }

  /// Obtiene un presupuesto por ID
  Presupuesto? obtenerPresupuestoPorId(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      print('Error al obtener presupuesto por ID: $e');
      return null;
    }
  }

  /// Actualiza un presupuesto existente
  Future<void> actualizarPresupuesto(Presupuesto presupuesto) async {
    try {
      await _box.put(presupuesto.id, presupuesto);
      print('Presupuesto actualizado: ${presupuesto.id}');
    } catch (e) {
      print('Error al actualizar presupuesto: $e');
      rethrow;
    }
  }

  /// Elimina un presupuesto por ID
  Future<void> eliminarPresupuesto(String id) async {
    try {
      await _box.delete(id);
      print('Presupuesto eliminado: $id');
    } catch (e) {
      print('Error al eliminar presupuesto: $e');
      rethrow;
    }
  }

  /// Elimina todos los presupuestos de un proyecto
  Future<void> eliminarPresupuestosPorProyecto(String proyectoId) async {
    try {
      final presupuestosAEliminar =
          _box.values
              .where((p) => p.proyectoId == proyectoId)
              .map((p) => p.id)
              .toList();

      for (final id in presupuestosAEliminar) {
        await _box.delete(id);
      }
      print('Presupuestos del proyecto $proyectoId eliminados');
    } catch (e) {
      print('Error al eliminar presupuestos del proyecto: $e');
      rethrow;
    }
  }

  /// Obtiene el total de presupuestos
  int obtenerTotal() {
    return _box.length;
  }

  /// Calcula el total de un presupuesto (suma de todos los costos)
  double calcularTotal(Presupuesto presupuesto) {
    double total = 0;

    // Sumar costos de mano de obra
    for (final mano in presupuesto.manoObra) {
      total += mano.costo;
    }

    // Sumar costos de materiales
    for (final material in presupuesto.materiales) {
      total += material.total;
    }

    // Sumar costos de equipos
    for (final equipo in presupuesto.equipos) {
      total += equipo.total;
    }

    return total;
  }

  /// Limpia todos los presupuestos (úsalo con cuidado)
  Future<void> limpiarTodos() async {
    try {
      await _box.clear();
      print('Todos los presupuestos han sido eliminados');
    } catch (e) {
      print('Error al limpiar presupuestos: $e');
      rethrow;
    }
  }
}
