import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'dart:io';

class ProyectosVista extends StatefulWidget {
  final Proyecto proyecto;

  const ProyectosVista({super.key, required this.proyecto});

  @override
  State<ProyectosVista> createState() => _ProyectosVistaState();
}

class _ProyectosVistaState extends State<ProyectosVista> {
  @override
  void initState() {
    super.initState();
    // Presupuestos serán manejados en el nuevo formulario wizard
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
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.proyecto.imagenPath !=
                        null && //esto es para mostrar la imagen del proyecto si es que tiene una, y si no tiene una imagen se muestra un contenedor gris
                    widget
                        .proyecto
                        .imagenPath!
                        .isNotEmpty //esto es para verificar que la ruta de la imagen no este vacia
                ? Image.file(
                  //aqui se muestra la imagen del proyecto, y se usa Image.file para mostrar la imagen desde el sistema de archivos, y se le pasa la ruta de la imagen que se guardo en el proyecto
                  File(
                    widget.proyecto.imagenPath!,
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
          widget.proyecto.nombreProyecto,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(
          widget.proyecto.nombreCliente,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),

        if (widget.proyecto.descripcion != null &&
            widget.proyecto.descripcion!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(widget.proyecto.descripcion!),
        ],

        // Ubicación
        if (widget.proyecto.ubicacion != null &&
            widget.proyecto.ubicacion!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.proyecto.ubicacion!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],

        // Fechas
        if (widget.proyecto.fechaInicio != null ||
            widget.proyecto.fechaFin != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatearRangoFechas(
                    widget.proyecto.fechaInicio,
                    widget.proyecto.fechaFin,
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

        // SECCIÓN DE PRESUPUESTOS (Próximamente disponible)
        const Text(
          "Presupuestos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 16),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Los presupuestos estarán disponibles pronto con el nuevo formulario wizard.',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FloatingActionButton removido - Los presupuestos se crearán con el nuevo wizard
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
