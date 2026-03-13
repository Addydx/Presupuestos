import 'package:hive/hive.dart';
import 'equipo.dart';
import 'mano_obra.dart';
import 'material.dart';

part 'presupuesto.g.dart';

enum EstadoPresupuesto { borrador, enviado, aprobado, rechazado, cancelado }

@HiveType(typeId: 1)
class Presupuesto {
  @HiveField(0)
  String id;

  @HiveField(1)
  String proyectoId;

  @HiveField(2)
  String titulo;

  @HiveField(3)
  double superficieM2;

  @HiveField(4)
  DateTime fechaCreacion;

  @HiveField(5)
  EstadoPresupuesto estado;

  @HiveField(6)
  int version;

  @HiveField(7)
  List<ManoObra> manoObra;

  @HiveField(8)
  List<Equipo> equipos;

  @HiveField(9)
  List<MaterialPresupuesto> materiales;

  @HiveField(10)
  double totalFinal;

  Presupuesto({
    required this.id,
    required this.proyectoId,
    required this.titulo,
    required this.superficieM2,
    required this.fechaCreacion,
    required this.estado,
    required this.version,
    required this.manoObra,
    required this.equipos,
    required this.materiales,
    this.totalFinal = 0.0,
  });
}
