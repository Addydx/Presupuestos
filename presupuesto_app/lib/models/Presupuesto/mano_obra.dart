import 'package:flutter/foundation.dart';

class ManoObra {
  TipoPago tipoPago;

  String? rol;
  int? cantidadPersonas;
  int? diasEstimados;
  double? costoPorDia;

  double? montoContrato;
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

enum TipoPago {
  porDia,
  porContrato,
}