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

  SliverAppBar _buildHeader() {//esto es para construir el header del proyecto, con la imagen y el nombre del proyecto
    return SliverAppBar(
      expandedHeight: 180,//esto es para que el header tenga una altura de 180 pixeles
      pinned: true,
      backgroundColor: Colors.white,//esto es para que el header tenga un fondo blanco
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.proyecto.nombreProyecto),
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.proyecto.imagenPath != null &&//esto es para mostrar la imagen del proyecto si es que tiene una, y si no tiene una imagen se muestra un contenedor gris
                    widget.proyecto.imagenPath!.isNotEmpty//esto es para verificar que la ruta de la imagen no este vacia
                ? Image.file(//aqui se muestra la imagen del proyecto, y se usa Image.file para mostrar la imagen desde el sistema de archivos, y se le pasa la ruta de la imagen que se guardo en el proyecto
                    File(widget.proyecto.imagenPath!),//esto es para convertir la ruta de la imagen en un archivo, y ! sirve para decirle a dart que no es nula
                    fit: BoxFit.cover,//esto es para que la imagen ocupe todo el espacio del header y se recorte si es necesario
                  )
                : Container(color: Colors.grey[300]),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // TÍTULO PRINCIPAL (DESTACA)
      Text(
        widget.proyecto.nombreProyecto,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        widget.proyecto.nombreCliente,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),

      if (widget.proyecto.descripcion != null &&
          widget.proyecto.descripcion!.trim().isNotEmpty) ...[
        const SizedBox(height: 14),
        Text(widget.proyecto.descripcion!),
      ],

      const SizedBox(height: 24),

      // DIVISIÓN VISUAL
      Divider(color: Colors.grey[300]),

      const SizedBox(height: 16),

      // SECCIÓN PRESUPUESTOS
      const Text(
        "Presupuestos",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
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
        Column(
          children: _presupuestos.map((presupuesto) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearPresupuesto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Presupuesto'),
      ),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildContenido(),
            ),
          ),
        ],
      ),
    );
  }
}
