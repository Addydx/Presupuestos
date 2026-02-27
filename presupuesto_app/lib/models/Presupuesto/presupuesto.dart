import 'package:hive/hive.dart';
import '../gastoReal/gasto.dart';

@HiveType(typeId: 1)
class Presupuesto extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String descripcion;

  @HiveField(3)
  List<Gasto> costosDirectos;

  @HiveField(4)
  List<Gasto> costosIndirectos;

  @HiveField(5)
  double margenGanancia;

  @HiveField(6)
  String proyectoId;

  @HiveField(7)
  DateTime fechaCreacion;

  Presupuesto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.costosDirectos,
    required this.costosIndirectos,
    required this.margenGanancia,
    required this.proyectoId,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  double get totalDirectos =>
      costosDirectos.fold(0, (sum, g) => sum + g.monto);

  double get totalIndirectos =>
      costosIndirectos.fold(0, (sum, g) => sum + g.monto);

  double get subtotal => totalDirectos + totalIndirectos;

  double get totalFinal =>
      subtotal + (subtotal * margenGanancia / 100);
}