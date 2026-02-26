import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/screens/presupuesto/new_presupuesto_scrren.dart';
import 'package:hive/hive.dart';

class ProyectosVista extends StatefulWidget {
  final Proyecto proyecto;

  const ProyectosVista({super.key, required this.proyecto});

  @override
  State<ProyectosVista> createState() => _ProyectosVistaState();
}

class _ProyectosVistaState extends State<ProyectosVista> {
  List<Presupuesto> _presupuestos = [];

  @override
  void initState() {
    super
        .initState(); // Esto es para cargar los presupuestos del proyecto al iniciar
    _cargarPresupuestos();
  }

  void _cargarPresupuestos() {
    final box = Hive.box<Presupuesto>('presupuestos');
    if (!box.isOpen) {
      throw Exception('La caja de presupuestos no está abierta');
    }
    final todos =
        box.values.where((p) => p.proyectoId == widget.proyecto.id).toList();
    setState(() {
      _presupuestos = todos;
    });
    print(_presupuestos.length);
  }

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
            ListView.builder(
              //esto es una lista de presupuestos
              shrinkWrap:
                  true, //esto es para que la lista se adapte al contenido
              physics:
                  const NeverScrollableScrollPhysics(), //esto es para que la lista no sea scrolleable
              itemCount:
                  _presupuestos
                      .length, //esto es para que la lista tenga el mismo numero de elementos que presupuestos
              itemBuilder: (context, index) {
                //esto es para construir cada elmento de la lista
                final presupuesto =
                    _presupuestos[index]; //esto es para obtener el presupuesto en la posicion index
                return Card(
                  shape: RoundedRectangleBorder(
                    //shape es para darle forma a la tarjeta
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    //esto es para darle espacio a la tarjeta
                    padding: const EdgeInsets.all(
                      16,
                    ), //esto es para darle espacio a la tarjeta
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          presupuesto.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (presupuesto.descripcion != null &&
                            presupuesto.descripcion!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(presupuesto.descripcion!),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Total: \$${_calcularTotal(presupuesto.gastos).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
