import 'package:flutter/material.dart';
import 'proyectos_vista.dart';
import 'nuevo_proyecto_screen.dart';
import '../../models/proyectos/proyecto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:io';

/// StatefulWidget para manejar la lista de proyectos dinámicamente
class ProyectosScreens extends StatefulWidget {
  const ProyectosScreens({super.key});

  @override
  State<ProyectosScreens> createState() => _ProyectosScreensState();
}

class _ProyectosScreensState extends State<ProyectosScreens> {
  // Lista de proyectos que se actualiza dinámicamente
  final List<Proyecto> _proyectos = [];
  late Box<Proyecto> _proyectosBox;

  @override
  void initState() {
    super.initState();
    _proyectosBox = Hive.box<Proyecto>('proyectos');
    _proyectos.addAll(_proyectosBox.values);
    debugPrint('Proyectos cargados desde Hive: \n');
    for (var proyecto in _proyectos) {
      debugPrint(proyecto.toString());
    }
  }

  /// Navega a la pantalla de nuevo proyecto y agrega el resultado a la lista
  Future<void> _crearNuevoProyecto() async {
    final nuevoProyecto = await Navigator.push<Proyecto>(
      context,
      MaterialPageRoute(builder: (context) => const NuevoProyectoScreen()),
    );

    // Si se retornó un proyecto, agregarlo a la lista
    if (nuevoProyecto != null) {
      setState(() {
        _proyectos.add(nuevoProyecto);
        _proyectosBox.add(nuevoProyecto);
        debugPrint('Proyecto guardado en Hive: ${nuevoProyecto.toString()}');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Proyectos'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón crear nuevo proyecto - estilo mejorado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00B4DB),
                    const Color(0xFF2E5090).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4DB).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _crearNuevoProyecto,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Nuevo Proyecto',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Lista de proyectos
            Expanded(
              child:
                  _proyectos.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2E5090,
                                ).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.folder_open,
                                size: 64,
                                color: Color(0xFF2E5090),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sin proyectos aún',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primer proyecto para comenzar',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF6C757D)),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _proyectos.length,
                        itemBuilder: (context, index) {
                          final proyecto = _proyectos[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _ProyectoCard(
                              nombreProyecto: proyecto.nombreProyecto,
                              nombreCliente: proyecto.nombreCliente,
                              imagenAsset: proyecto.imagenPath,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ProyectosVista(proyecto: proyecto),
                                  ),
                                );
                                if (mounted) {
                                  setState(() {
                                    _proyectos.clear();
                                    _proyectos.addAll(_proyectosBox.values);
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProyectoCard extends StatelessWidget {
  final String nombreProyecto;
  final String nombreCliente;
  final String? imagenAsset;
  final VoidCallback onTap;

  const _ProyectoCard({
    required this.nombreProyecto,
    required this.nombreCliente,
    this.imagenAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: 240,
            child: Stack(
              children: [
                // Imagen de fondo
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child:
                        imagenAsset != null && imagenAsset!.isNotEmpty
                            ? Image.file(
                              File(imagenAsset!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                            : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2E5090).withOpacity(0.9),
                                    const Color(0xFF00B4DB).withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.home_work,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                  ),
                ),
                // Gradiente oscuro en la parte inferior
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Contenido (abajo)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nombreProyecto,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nombreCliente,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
