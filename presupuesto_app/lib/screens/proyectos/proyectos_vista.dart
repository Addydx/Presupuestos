import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/Presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/Proyectos/proyecto.dart';
import 'package:presupuesto_app/screens/presupuesto/new_presupuesto_scrren.dart';

class ProyectosVista extends StatefulWidget {
  // Recibimos el proyecto completo porque en la vista se usan varios datos
  // (nombre del proyecto, cliente y descripción).
  final Proyecto proyecto;

  const ProyectosVista({super.key, required this.proyecto});

  @override
  State<ProyectosVista> createState() => _ProyectosVistaState();
}

class _ProyectosVistaState extends State<ProyectosVista> {
  List<Presupuesto> _presupuestos = [];
  //añadir esta nueva para luego modificarla en la mac

  Future<void> _crearPresupuesto() async {
    final nuevoPresupuesto = await Navigator.push<Presupuesto>(
      context,
      MaterialPageRoute(
        builder:
            (context) => NewPresupuestoScrren(proyectoId: widget.proyecto.id),
      ),
    );

    if (nuevoPresupuesto != null) {
      setState(() {
        _presupuestos.add(nuevoPresupuesto);
      });
    }
  }

  double _calcularTotal(List<Map<String, dynamic>> gastos) {
    return gastos.fold<double>(0, (acumulado, gasto) {
      final monto = gasto['monto'];
      if (monto is num) {
        return acumulado + monto.toDouble();
      }
      return acumulado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.proyecto.nombreProyecto)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearPresupuesto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Presupuesto'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.proyecto.nombreProyecto,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cliente: ${widget.proyecto.nombreCliente}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.proyecto.descripcion != null &&
                      widget.proyecto.descripcion!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(widget.proyecto.descripcion!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_presupuestos.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Este proyecto aún no tiene presupuesto.'),
              ),
            )
          else
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _presupuestos.last.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_presupuestos.last.descripcion != null &&
                        _presupuestos.last.descripcion!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(_presupuestos.last.descripcion!),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Total: ${_calcularTotal(_presupuestos.last.gastos).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_presupuestos.last.gastos.isEmpty)
                      const Text('Sin gastos registrados.')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _presupuestos.last.gastos.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final gasto = _presupuestos.last.gastos[index];
                          final nombre = (gasto['nombre'] ?? '').toString();
                          final montoValor = gasto['monto'];
                          final monto =
                              montoValor is num ? montoValor.toDouble() : 0.0;

                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nombre.isEmpty ? 'Gasto sin nombre' : nombre,
                                ),
                              ),
                              Text(monto.toStringAsFixed(2)),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
