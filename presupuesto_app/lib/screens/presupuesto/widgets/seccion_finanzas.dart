import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';

class SeccionFinanzas extends StatelessWidget {
  final double totalMateriales;
  final double totalManoObra;
  final double totalEquipos;
  final Finanzas finanzas;

  const SeccionFinanzas({
    super.key,
    required this.totalMateriales,
    required this.totalManoObra,
    required this.totalEquipos,
    required this.finanzas,
  });

  @override
  Widget build(BuildContext context) {
    final calculadora = CalculadoraFinanzas();

    final resultados = calculadora.calcularTodo(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
      finanzas: finanzas,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cálculos Financieros',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Costo directo
            _buildFila('Costo Directo:', resultados['costoDirecto']!),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 8),
            // Imprevistos
            _buildFila(
              'Imprevistos (${finanzas.porcentajeImprevistos.toStringAsFixed(1)}%):',
              resultados['imprevistos']!,
            ),
            const SizedBox(height: 8),
            // Subtotal
            _buildFila('Subtotal:', resultados['subtotal']!, esMarcado: true),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 8),
            // Utilidad
            _buildFila(
              'Utilidad (${finanzas.porcentajeUtilidad.toStringAsFixed(1)}%):',
              resultados['utilidad']!,
            ),
            const SizedBox(height: 8),
            // Precio final
            _buildFila(
              'Precio Final:',
              resultados['precioFinal']!,
              esMarcado: true,
            ),
            if (finanzas.aplicarIVA) ...[
              const SizedBox(height: 8),
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height: 8),
              _buildFila('IVA (16%):', resultados['iva']!),
            ],
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade400, height: 2),
            const SizedBox(height: 12),
            // Total final
            _buildFila(
              '🎯 TOTAL FINAL:',
              resultados['totalFinal']!,
              esTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFila(
    String label,
    double valor, {
    bool esMarcado = false,
    bool esTotal = false,
  }) {
    final fontSize = esTotal ? 16.0 : (esMarcado ? 14.0 : 12.0);
    final fontWeight =
        esTotal
            ? FontWeight.bold
            : (esMarcado ? FontWeight.w600 : FontWeight.w500);
    final color =
        esTotal
            ? Colors.green.shade700
            : (esMarcado ? Colors.blue.shade700 : Colors.black87);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
        Text(
          '\$${valor.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }
}
