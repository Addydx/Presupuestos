import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';

class SeccionManoObra extends StatelessWidget {
  final List<ManoObra> manoObra;

  const SeccionManoObra({super.key, required this.manoObra});

  @override
  Widget build(BuildContext context) {
    // Calcular total
    double totalManoObra = 0;
    for (final mo in manoObra) {
      totalManoObra += mo.costo;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mano de Obra',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (manoObra.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Sin mano de obra agregada',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: manoObra.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final mo = manoObra[index];
                  final tipoStr = mo.tipoPago.toString().split('.').last;

                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                mo.rol ?? 'Sin especificar',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '\$${mo.costo.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mo.tipoPago == TipoPago.porDia
                              ? '${mo.cantidadPersonas} personas × ${mo.diasEstimados} días × \$${mo.costoPorDia}'
                              : 'Costo por contrato',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (manoObra.isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Mano de Obra:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '\$${totalManoObra.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
