import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_equipos.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_finanzas.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_mano_obra.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_materiales.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';

class ResumenPresupuestoScreen extends StatelessWidget {
  final List<MaterialPresupuesto>? materiales;
  final List<Equipo>? equipos;
  final List<ManoObra>? manoObra;
  final Finanzas? finanzas;
  final String? titulo;
  final DateTime? fecha;
  final Presupuesto? presupuesto;

  const ResumenPresupuestoScreen({
    super.key,
    this.materiales,
    this.equipos,
    this.manoObra,
    this.finanzas,
    this.titulo,
    this.fecha,
    this.presupuesto,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener datos del presupuesto o de los parámetros individuales
    final materialesList = presupuesto?.materiales ?? materiales ?? [];
    final equiposList = presupuesto?.equipos ?? equipos ?? [];
    final manoObraList = presupuesto?.manoObra ?? manoObra ?? [];
    final finanzasData = presupuesto?.finanzas ?? finanzas ?? Finanzas();
    final tituloText = presupuesto?.titulo ?? titulo;
    final fechaData = presupuesto?.fechaCreacion ?? fecha;

    // Calcular totales
    final totalMateriales = materialesList.fold<double>(
      0,
      (sum, m) => sum + m.total,
    );
    final totalManoObra = manoObraList.fold<double>(
      0,
      (sum, mo) => sum + mo.costo,
    );
    final totalEquipos = equiposList.fold<double>(0, (sum, e) => sum + e.total);

    // Calcular finanzas
    final calculadora = CalculadoraFinanzas();
    final resultados = calculadora.calcularTodo(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
      finanzas: finanzasData,
    );

    final totalFinal = resultados['totalFinal']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Presupuesto'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con título y fecha
            if (tituloText != null || fechaData != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tituloText != null)
                        Text(
                          tituloText!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (fechaData != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${fechaData!.toLocal().toString().split(' ')[0]}',
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
            SeccionMateriales(materiales: materialesList),
            const SizedBox(height: 12),

            // Sección: Mano de Obra
            SeccionManoObra(manoObra: manoObraList),
            const SizedBox(height: 12),

            // Sección: Equipos
            SeccionEquipos(equipos: equiposList),
            const SizedBox(height: 12),

            // Sección: Finanzas
            SeccionFinanzas(
              totalMateriales: totalMateriales,
              totalManoObra: totalManoObra,
              totalEquipos: totalEquipos,
              finanzas: finanzasData,
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
                    'TOTAL FINAL DEL PRESUPUESTO',
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    finanzasData.aplicarIVA
                        ? '(Incluye IVA ${finanzasData.porcentajeImprevistos.toStringAsFixed(1)}% imprevistos + ${finanzasData.porcentajeUtilidad.toStringAsFixed(1)}% utilidad)'
                        : '(Sin IVA - ${finanzasData.porcentajeImprevistos.toStringAsFixed(1)}% imprevistos + ${finanzasData.porcentajeUtilidad.toStringAsFixed(1)}% utilidad)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Resumen de componentes
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desglose de Componentes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildComponente(
                      'Materiales',
                      totalMateriales,
                      totalFinal,
                      Colors.blue,
                    ),
                    _buildComponente(
                      'Mano de Obra',
                      totalManoObra,
                      totalFinal,
                      Colors.purple,
                    ),
                    _buildComponente(
                      'Equipos Rentados',
                      totalEquipos,
                      totalFinal,
                      Colors.orange,
                    ),
                    _buildComponente(
                      'Imprevistos',
                      resultados['imprevistos']!,
                      totalFinal,
                      Colors.amber,
                    ),
                    _buildComponente(
                      'Utilidad',
                      resultados['utilidad']!,
                      totalFinal,
                      Colors.teal,
                    ),
                    if (finanzasData.aplicarIVA)
                      _buildComponente(
                        'IVA',
                        resultados['iva']!,
                        totalFinal,
                        Colors.red,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Presupuesto guardado'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Presupuesto exportado'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Exportar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildComponente(
    String nombre,
    double monto,
    double total,
    Color color,
  ) {
    final porcentaje = total > 0 ? ((monto / total) * 100) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontSize: 12)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: porcentaje / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${monto.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${porcentaje.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
