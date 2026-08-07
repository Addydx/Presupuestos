import 'package:hive/hive.dart';
import 'package:presupuesto_app/models/presupuesto/borrador_presupuesto.dart';

/// Persiste el borrador autoguardado del wizard de presupuestos.
class BorradorPresupuestoService {
  static const String _boxName = 'borradores_presupuesto';
  static final BorradorPresupuestoService _instance =
      BorradorPresupuestoService._internal();
  static bool _initialized = false;
  late Box<BorradorPresupuesto> _box;

  BorradorPresupuestoService._internal();

  factory BorradorPresupuestoService() => _instance;

  Future<void> initialize() async {
    if (_initialized) return;
    _box = await Hive.openBox<BorradorPresupuesto>(_boxName);
    _initialized = true;
  }

  /// Id del borrador para un presupuesto nuevo (aún no guardado).
  static String idNuevo(String proyectoId) => 'nuevo_$proyectoId';

  /// Id del borrador para la edición de un presupuesto ya existente.
  static String idEdicion(String presupuestoId) => 'editar_$presupuestoId';

  BorradorPresupuesto? obtener(String id) => _box.get(id);

  Future<void> guardar(BorradorPresupuesto borrador) async {
    await _box.put(borrador.id, borrador);
  }

  Future<void> eliminar(String id) async {
    await _box.delete(id);
  }
}
