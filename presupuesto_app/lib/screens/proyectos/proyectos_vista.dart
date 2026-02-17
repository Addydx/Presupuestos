import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/Proyectos/proyecto.dart';

class ProyectosVista extends StatelessWidget {
  // Recibimos el proyecto completo porque en la vista se usan varios datos
  // (nombre del proyecto, cliente y descripción).
  final Proyecto proyecto;

  const ProyectosVista({super.key, required this.proyecto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(proyecto.nombreProyecto)),
      body: Padding(
        padding: const EdgeInsets.all(16),//esto sirve para darle un poco de espacio a los bordes de la pantalla
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proyecto.nombreProyecto, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Cliente: ${proyecto.nombreCliente}',
              style: const TextStyle(fontSize: 16),//esto es para mostrar el nombre del cliente
            ),
            const SizedBox(height:10),
            if (proyecto.descripcion !=null)//esto es para mostrar la descripcion del proyecto si es que existe
            Text(proyecto.descripcion!),
          ],
        ),
      ),
    );
  }
}
