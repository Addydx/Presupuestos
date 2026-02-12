import 'package:flutter/material.dart';
import 'proyectos_vista.dart';
import 'nuevo_proyecto_screen.dart';
import '../../models/proyecto.dart';

/// StatefulWidget para manejar la lista de proyectos dinámicamente
class ProyectosScreens extends StatefulWidget {
  const ProyectosScreens({super.key});

  @override
  State<ProyectosScreens> createState() => _ProyectosScreensState();
}

class _ProyectosScreensState extends State<ProyectosScreens> {
  // Lista de proyectos que se actualiza dinámicamente
  final List<Proyecto> _proyectos = [
    // Proyecto de ejemplo inicial
    Proyecto(
      id: '1',
      nombreProyecto: 'Casa Residencial García',
      nombreCliente: 'Juan García López',
      imagenPath: 'assets/images/construccion-de-una-casa-de-dos-pisos-1.webp',
    ),
  ];

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón de crear nuevo proyecto
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _crearNuevoProyecto,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Crear Nuevo Proyecto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Lista de proyectos
          Expanded(
            child:
                _proyectos.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay proyectos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primer proyecto',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _proyectos.length,
                      itemBuilder: (context, index) {
                        final proyecto = _proyectos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _ProyectoCard(
                            nombreProyecto: proyecto.nombreProyecto,
                            nombreCliente: proyecto.nombreCliente,
                            imagenAsset: proyecto.imagenPath,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProyectosVista(
                                        nombreProyecto: proyecto.nombreProyecto,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
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
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Espacio para imagen (más grande)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child:
                      imagenAsset != null
                          ? Image.asset(
                            imagenAsset!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                          : Center(
                            child: Icon(
                              Icons.home_work,
                              size: 80,
                              color: Colors.grey[500],
                            ),
                          ),
                ),
              ),
              // Información del proyecto (abajo)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nombreProyecto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              nombreCliente,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey[400],
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
    );
  }
}
