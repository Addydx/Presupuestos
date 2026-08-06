import 'package:presupuesto_app/models/presupuesto/finanzas.dart';

/// Servicio para calcular finanzas del presupuesto
///
/// Proporciona métodos para calcular todos los valores financieros
/// basados en costos de materiales, mano de obra y equipos.
class CalculadoraFinanzas {
  static final CalculadoraFinanzas _instance = CalculadoraFinanzas._internal();

  CalculadoraFinanzas._internal();

  factory CalculadoraFinanzas() {
    return _instance;
  }

  // Constantes
  static const double IVA_RATE = 0.16; // 16% IVA

  /// Calcula el costo directo (suma de materiales, mano de obra y equipos)
  ///
  /// CostoDirecto = totalMateriales + totalManoObra + totalEquipos
  double costoDirecto({
    required double totalMateriales,
    required double totalManoObra,
    required double totalEquipos,
  }) {
    return totalMateriales + totalManoObra + totalEquipos;
  }

  /// Calcula el monto de imprevistos
  ///
  /// Imprevistos = CostoDirecto * (porcentajeImprevistos / 100)
  double imprevistos({
    required double costoDirecto,
    required double porcentajeImprevistos,
  }) {
    if (costoDirecto <= 0 || porcentajeImprevistos < 0) return 0;
    return costoDirecto * (porcentajeImprevistos / 100);
  }

  /// Calcula el subtotal (costo directo + imprevistos)
  ///
  /// Subtotal = CostoDirecto + Imprevistos
  double subtotal({required double costoDirecto, required double imprevistos}) {
    return costoDirecto + imprevistos;
  }

  /// Calcula el monto de utilidad/ganancia
  ///
  /// Utilidad = Subtotal * (porcentajeUtilidad / 100)
  double utilidad({
    required double subtotal,
    required double porcentajeUtilidad,
  }) {
    if (subtotal <= 0 || porcentajeUtilidad < 0) return 0;
    return subtotal * (porcentajeUtilidad / 100);
  }

  /// Calcula el precio final (antes de IVA)
  ///
  /// PrecioFinal = Subtotal + Utilidad
  double precioFinal({required double subtotal, required double utilidad}) {
    return subtotal + utilidad;
  }

  /// Calcula el monto del IVA (16%)
  ///
  /// IVA = PrecioFinal * 0.16
  double iva({required double precioFinal, required bool aplicarIVA}) {
    if (!aplicarIVA || precioFinal <= 0) return 0;
    return precioFinal * IVA_RATE;
  }

  /// Calcula el total final con (o sin) IVA
  ///
  /// TotalFinal = PrecioFinal + IVA (si aplicarIVA es true)
  double totalFinal({required double precioFinal, required double iva}) {
    return precioFinal + iva;
  }

  /// Método conveniente para calcular todo de una vez
  /// Retorna un mapa con todos los valores calculados
  Map<String, double> calcularTodo({
    required double totalMateriales,
    required double totalManoObra,
    required double totalEquipos,
    required Finanzas finanzas,
  }) {
    // 1. Costo directo
    final costo = costoDirecto(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
    );

    // 2. Imprevistos
    final imprevistosMonto = imprevistos(
      costoDirecto: costo,
      porcentajeImprevistos: finanzas.porcentajeImprevistos,
    );

    // 3. Subtotal
    final subtotalMonto = subtotal(
      costoDirecto: costo,
      imprevistos: imprevistosMonto,
    );

    // 4. Utilidad
    final utilidadMonto = utilidad(
      subtotal: subtotalMonto,
      porcentajeUtilidad: finanzas.porcentajeUtilidad,
    );

    // 5. Precio final
    final precioFinalMonto = precioFinal(
      subtotal: subtotalMonto,
      utilidad: utilidadMonto,
    );

    // 6. IVA
    final ivaMonto = iva(
      precioFinal: precioFinalMonto,
      aplicarIVA: finanzas.aplicarIVA,
    );

    // 7. Total final
    final totalFinalMonto = totalFinal(
      precioFinal: precioFinalMonto,
      iva: ivaMonto,
    );

    return {
      'costoDirecto': costo,
      'imprevistos': imprevistosMonto,
      'subtotal': subtotalMonto,
      'utilidad': utilidadMonto,
      'precioFinal': precioFinalMonto,
      'iva': ivaMonto,
      'totalFinal': totalFinalMonto,
    };
  }

  /// Formatea un número como dinero
  String formatoMoneda(double valor) {
    return '\$${valor.toStringAsFixed(2)}';
  }
}
