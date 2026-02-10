import 'package:flutter/material.dart';
import 'proyectos_vista.dart';
import 'nuevo_proyecto_screen.dart';

//statelessWidget es una pantalla que no cambia.
class ProyectosScreens extends StatelessWidget {
  const ProyectosScreens({super.key});

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NuevoProyectoScreen(),
                  ),
                );
              },
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
          // Tarjeta de proyecto de ejemplo
          _ProyectoCard(
            nombreProyecto: 'Casa Residencial García',
            nombreCliente: 'Juan García López',
            imagenAsset:
                'assets/images/construccion-de-una-casa-de-dos-pisos-1.webp',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const ProyectosVista(
                        nombreProyecto: 'Casa Residencial García',
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
