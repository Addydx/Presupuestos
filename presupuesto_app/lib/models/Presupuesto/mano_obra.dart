import 'package:hive/hive.dart';

part 'mano_obra.g.dart';

enum TipoPago { porDia, porContrato }

@HiveType(typeId: 2)
class ManoObra {
  @HiveField(0)
  String? id;

  @HiveField(1)
  TipoPago tipoPago;

  @HiveField(2)
  String? rol;

  @HiveField(3)
  int? cantidadPersonas;

  @HiveField(4)
  int? diasEstimados;

  @HiveField(5)
  double? costoPorDia;

  @HiveField(6)
  double? montoContrato;

  @HiveField(7)
  String? observaciones;

  ManoObra({
    String? id,
    required this.tipoPago,
    this.rol,
    this.cantidadPersonas,
    this.diasEstimados,
    this.costoPorDia,
    this.montoContrato,
    this.observaciones,
  }) : id = id ?? DateTime.now().toString();

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
