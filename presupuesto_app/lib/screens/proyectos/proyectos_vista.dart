import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard_presupuesto_screen.dart';
import 'package:presupuesto_app/services/presupuestos_service.dart';
import 'package:presupuesto_app/screens/presupuesto/resumen_presupuesto_screen.dart';
import 'package:presupuesto_app/screens/proyectos/editar_proyecto_screen.dart';
import 'dart:io';

class ProyectosVista extends StatefulWidget {
  final Proyecto proyecto;

  const ProyectosVista({super.key, required this.proyecto});

  @override
  State<ProyectosVista> createState() => _ProyectosVistaState();
}

class _ProyectosVistaState extends State<ProyectosVista> {
  late PresupuestosService _presupuestosService;
  List<Presupuesto> _presupuestos = [];
  late Proyecto _proyecto;

  @override
  void initState() {
    super.initState();
    _proyecto = widget.proyecto;
    _presupuestosService = PresupuestosService();
    _cargarPresupuestos();
  }

  Future<void> _editarProyecto() async {
    final proyectoActualizado = await Navigator.push<Proyecto>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProyectoScreen(proyecto: _proyecto),
      ),
    );

    if (proyectoActualizado != null && mounted) {
      final box = Hive.box<Proyecto>('proyectos');
      for (final key in box.keys) {
        if (box.get(key)?.id == _proyecto.id) {
          await box.put(key, proyectoActualizado);
          break;
        }
      }
      setState(() {
        _proyecto = proyectoActualizado;
      });
    }
  }

  Future<void> _eliminarProyecto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Eliminar Proyecto'),
            content: Text(
              'Se eliminará el proyecto "${_proyecto.nombreProyecto}" y todos sus presupuestos asociados. Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmar != true) {
      return;
    }

    await _presupuestosService.eliminarPresupuestosPorProyecto(_proyecto.id);

    final box = Hive.box<Proyecto>('proyectos');
    dynamic keyAEliminar;
    for (final key in box.keys) {
      if (box.get(key)?.id == _proyecto.id) {
        keyAEliminar = key;
        break;
      }
    }

    if (keyAEliminar != null) {
      await box.delete(keyAEliminar);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _cargarPresupuestos() {
    setState(() {
      _presupuestos = _presupuestosService.obtenerPresupuestosPorProyecto(
        _proyecto.id,
      );
    });
  }

  Future<void> _editarPresupuesto(Presupuesto presupuesto) async {
    final presupuestoActualizado = await Navigator.push<Presupuesto>(
      context,
      MaterialPageRoute(
        builder:
            (context) => WizardPresupuestoScreen(
              proyectoId: _proyecto.id,
              presupuesto: presupuesto,
            ),
      ),
    );

    if (presupuestoActualizado != null && mounted) {
      _cargarPresupuestos();
    }
  }

  void _eliminarPresupuesto(String presupuestoId) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Presupuesto'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este presupuesto?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _presupuestosService.eliminarPresupuesto(presupuestoId);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _cargarPresupuestos();
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  String _formatearRangoFechas(DateTime? inicio, DateTime? fin) {
    if (inicio == null && fin == null) {
      return 'Sin fechas definidas';
    } else if (inicio != null && fin == null) {
      return 'Inicio: ${inicio.day}/${inicio.month}/${inicio.year}';
    } else if (inicio == null && fin != null) {
      return 'Fin: ${fin.day}/${fin.month}/${fin.year}';
    } else {
      return '${inicio!.day}/${inicio.month}/${inicio.year} - ${fin!.day}/${fin.month}/${fin.year}';
    }
  }

  SliverAppBar _buildHeader() {
    //esto es para construir el header del proyecto, con la imagen y el nombre del proyecto
    return SliverAppBar(
      expandedHeight:
          180, //esto es para que el header tenga una altura de 180 pixeles
      pinned: true,
      backgroundColor:
          Colors.white, //esto es para que el header tenga un fondo blanco
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: _editarProyecto,
          tooltip: 'Editar proyecto',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _eliminarProyecto,
          tooltip: 'Eliminar proyecto',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _proyecto.imagenPath !=
                        null && //esto es para mostrar la imagen del proyecto si es que tiene una, y si no tiene una imagen se muestra un contenedor gris
                    _proyecto
                        .imagenPath!
                        .isNotEmpty //esto es para verificar que la ruta de la imagen no este vacia
                ? Image.file(
                  //aqui se muestra la imagen del proyecto, y se usa Image.file para mostrar la imagen desde el sistema de archivos, y se le pasa la ruta de la imagen que se guardo en el proyecto
                  File(
                    _proyecto.imagenPath!,
                  ), //esto es para convertir la ruta de la imagen en un archivo, y ! sirve para decirle a dart que no es nula
                  fit:
                      BoxFit
                          .cover, //esto es para que la imagen ocupe todo el espacio del header y se recorte si es necesario
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
          _proyecto.nombreProyecto,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(
          _proyecto.nombreCliente,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),

        if (_proyecto.descripcion != null &&
            _proyecto.descripcion!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(_proyecto.descripcion!),
        ],

        // Ubicación
        if (_proyecto.ubicacion != null &&
            _proyecto.ubicacion!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _proyecto.ubicacion!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],

        // Fechas
        if (_proyecto.fechaInicio != null || _proyecto.fechaFin != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatearRangoFechas(
                    _proyecto.fechaInicio,
                    _proyecto.fechaFin,
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // DIVISIÓN VISUAL
        Divider(color: Colors.grey[300]),

        const SizedBox(height: 16),

        // SECCIÓN DE PRESUPUESTOS
        const Text(
          "Presupuestos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 16),

        if (_presupuestos.isEmpty)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Crea un presupuesto para este proyecto usando el formulario wizard.',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => WizardPresupuestoScreen(
                                proyectoId: _proyecto.id,
                              ),
                        ),
                      ).then(
                        (_) => _cargarPresupuestos(),
                      ); // Recargar al volver
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Presupuesto'),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              ..._presupuestos.map((presupuesto) {
                double total = _presupuestosService.calcularTotal(presupuesto);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ResumenPresupuestoScreen(
                                presupuesto: presupuesto,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      presupuesto.titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Creado: ${presupuesto.fechaCreacion.day}/${presupuesto.fechaCreacion.month}/${presupuesto.fechaCreacion.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'editar') {
                                    _editarPresupuesto(presupuesto);
                                  }
                                  if (value == 'eliminar') {
                                    _eliminarPresupuesto(presupuesto.id);
                                  }
                                },
                                itemBuilder:
                                    (context) => const [
                                      PopupMenuItem(
                                        value: 'editar',
                                        child: Text('Editar'),
                                      ),
                                      PopupMenuItem(
                                        value: 'eliminar',
                                        child: Text(
                                          'Eliminar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: \$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  presupuesto.estado
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor:
                                    presupuesto.estado.toString().contains(
                                          'borrador',
                                        )
                                        ? Colors.orange[100]
                                        : Colors.green[100],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WizardPresupuestoScreen(
                              proyectoId: _proyecto.id,
                            ),
                      ),
                    ).then((_) => _cargarPresupuestos()); // Recargar al volver
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Otro Presupuesto'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      WizardPresupuestoScreen(proyectoId: _proyecto.id),
            ),
          ).then((_) => _cargarPresupuestos()); // Recargar al volver
        },
        tooltip: 'Crear Presupuesto',
        child: const Icon(Icons.add),
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
