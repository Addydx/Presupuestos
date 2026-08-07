import 'package:hive/hive.dart';
import 'equipo.dart';
import 'finanzas.dart';
import 'mano_obra.dart';
import 'material.dart';
import 'presupuesto.dart';

part 'borrador_presupuesto.g.dart';

/// Borrador autoguardado de un presupuesto en progreso dentro del wizard.
///
/// typeId 10 (typeIds 0-9 ya estaban ocupados por los modelos existentes,
/// verificado leyendo cada `@HiveType` antes de asignar este). Reserva:
/// los typeIds 11-14 quedan libres para futuros modelos auxiliares.
@HiveType(typeId: 10)
class BorradorPresupuesto {
  /// `nuevo_<proyectoId>` para presupuestos nuevos o
  /// `editar_<presupuestoId>` cuando se edita uno existente — como máximo
  /// un borrador activo por presupuesto.
  @HiveField(0)
  String id;

  @HiveField(1)
  String proyectoId;

  @HiveField(2)
  String? presupuestoIdEnEdicion;

  @HiveField(3)
  int pasoActual;

  @HiveField(4)
  String titulo;

  @HiveField(5)
  double superficieM2;

  @HiveField(6)
  DateTime fechaCreacion;

  @HiveField(7)
  EstadoPresupuesto estado;

  @HiveField(8)
  ManoObra? manoObra;

  @HiveField(9)
  List<Equipo> equipos;

  @HiveField(10)
  List<MaterialPresupuesto> materiales;

  @HiveField(11)
  Finanzas finanzas;

  @HiveField(12)
  DateTime ultimaModificacion;

  BorradorPresupuesto({
    required this.id,
    required this.proyectoId,
    this.presupuestoIdEnEdicion,
    required this.pasoActual,
    required this.titulo,
    required this.superficieM2,
    required this.fechaCreacion,
    required this.estado,
    this.manoObra,
    required this.equipos,
    required this.materiales,
    required this.finanzas,
    DateTime? ultimaModificacion,
  }) : ultimaModificacion = ultimaModificacion ?? DateTime.now();
}
