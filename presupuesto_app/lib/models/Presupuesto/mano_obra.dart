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

  /// Calcula el costo total de mano de obra según el tipo de pago
  double get costo {
    if (tipoPago == TipoPago.porDia) {
      // Costo por día: cantidad de personas × días × costo por día
      final personas = cantidadPersonas ?? 0;
      final dias = diasEstimados ?? 0;
      final costoDia = costoPorDia ?? 0;
      return personas * dias * costoDia;
    } else {
      // Costo por contrato: monto fijo
      return montoContrato ?? 0;
    }
  }
}
