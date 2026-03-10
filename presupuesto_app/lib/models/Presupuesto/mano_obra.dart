import 'package:hive/hive.dart';

part 'mano_obra.g.dart';

enum TipoPago { porDia, porContrato }

@HiveType(typeId: 2)
class ManoObra {
  @HiveField(0)
  TipoPago tipoPago;

  @HiveField(1)
  String? rol;

  @HiveField(2)
  int? cantidadPersonas;

  @HiveField(3)
  int? diasEstimados;

  @HiveField(4)
  double? costoPorDia;

  @HiveField(5)
  double? montoContrato;

  @HiveField(6)
  String? observaciones;

  ManoObra({
    required this.tipoPago,
    this.rol,
    this.cantidadPersonas,
    this.diasEstimados,
    this.costoPorDia,
    this.montoContrato,
    this.observaciones,
  });
}
