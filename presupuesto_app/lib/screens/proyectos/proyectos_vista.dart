import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/screens/presupuesto/new_presupuesto_scrren.dart';
import 'package:hive/hive.dart';
import 'dart:io';

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
    print('Ruta de la imagen: \\${widget.proyecto.imagenPath}');
    if (widget.proyecto.imagenPath != null) {
      final existeImagen = File(widget.proyecto.imagenPath!).existsSync();
      print('¿Existe la imagen?: \\${existeImagen}');
      if (!existeImagen) {
        print('Advertencia: La imagen no se encuentra en la ruta especificada.');
      }
    } else {
      print('Advertencia: No se ha proporcionado una ruta para la imagen.');
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.proyecto.nombreProyecto)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearPresupuesto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Presupuesto'),
      ),
      body: CustomScrollView(
        slivers: [
          // HEADER CON IMAGEN
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.proyecto.nombreProyecto),
              background:
                  widget.proyecto.imagenPath != null &&
                          File(widget.proyecto.imagenPath!).existsSync()
                      ? Image.file(
                        File(widget.proyecto.imagenPath!),
                        fit: BoxFit.cover,
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 80),
                      ),
            ),
          ),

          // INFORMACIÓN DEL PROYECTO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cliente: ${widget.proyecto.nombreCliente}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  if (widget.proyecto.descripcion != null &&
                      widget.proyecto.descripcion!.trim().isNotEmpty)
                    Text(widget.proyecto.descripcion!),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // LISTA DE PRESUPUESTOS
          if (_presupuestos.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Este proyecto aún no tiene presupuesto.'),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final presupuesto = _presupuestos[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                  ),
                );
              }, childCount: _presupuestos.length),
            ),
        ],
      ),
    );
  }
}
