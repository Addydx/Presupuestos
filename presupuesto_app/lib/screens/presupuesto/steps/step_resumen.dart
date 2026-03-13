import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_equipos.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_finanzas.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_mano_obra.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_materiales.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';

class StepResumen extends StatelessWidget {
  final List<MaterialPresupuesto> materiales;
  final List<Equipo> equipos;
  final List<ManoObra> manoObra;
  final Finanzas finanzas;
  final String? titulo;
  final DateTime? fecha;

  const StepResumen({
    super.key,
    required this.materiales,
    required this.equipos,
    required this.manoObra,
    required this.finanzas,
    this.titulo,
    this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular totales
    final totalMateriales = materiales.fold<double>(
      0,
      (sum, m) => sum + m.total,
    );
    final totalManoObra = manoObra.fold<double>(0, (sum, mo) => sum + mo.costo);
    final totalEquipos = equipos.fold<double>(0, (sum, e) => sum + e.total);

    // Calcular finanzas
    final calculadora = CalculadoraFinanzas();
    final resultados = calculadora.calcularTodo(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
      finanzas: finanzas,
    );

    final totalFinal = resultados['totalFinal']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y fecha
          if (titulo != null || fecha != null)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titulo != null)
                      Text(
                        titulo!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (fecha != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${fecha!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Sección: Materiales
          SeccionMateriales(materiales: materiales),
          const SizedBox(height: 12),

          // Sección: Mano de Obra
          SeccionManoObra(manoObra: manoObra),
          const SizedBox(height: 12),

          // Sección: Equipos
          SeccionEquipos(equipos: equipos),
          const SizedBox(height: 12),

          // Sección: Finanzas
          SeccionFinanzas(
            totalMateriales: totalMateriales,
            totalManoObra: totalManoObra,
            totalEquipos: totalEquipos,
            finanzas: finanzas,
          ),
          const SizedBox(height: 16),

          // TOTAL FINAL - Destacado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL FINAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalFinal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
