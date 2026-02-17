import 'package:flutter/material.dart';
import '../../models/Proyectos/proyecto.dart';

class NuevoProyectoScreen extends StatefulWidget {
  const NuevoProyectoScreen({super.key});

  @override
  State<NuevoProyectoScreen> createState() => _NuevoProyectoScreenState();
}

class _NuevoProyectoScreenState extends State<NuevoProyectoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreProyectoController = TextEditingController();
  final _nombreClienteController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void dispose() {
    _nombreProyectoController.dispose();
    _nombreClienteController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Proyecto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Espacio para imagen del proyecto
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agregar imagen del proyecto',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Campo nombre del proyecto
              const Text(
                'Nombre del proyecto',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreProyectoController,
                decoration: InputDecoration(
                  hintText: 'Ej: Casa Residencial García',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.home_work),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del proyecto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo nombre del cliente
              const Text(
                'Nombre del cliente',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreClienteController,
                decoration: InputDecoration(
                  hintText: 'Ej: Juan García López',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del cliente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo descripción
              const Text(
                'Descripción (opcional)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Detalles adicionales del proyecto...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Crear el nuevo proyecto con un ID único
                      final nuevoProyecto = Proyecto(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nombreProyecto: _nombreProyectoController.text.trim(),
                        nombreCliente: _nombreClienteController.text.trim(),
                        descripcion:
                            _descripcionController.text.trim().isEmpty
                                ? null
                                : _descripcionController.text.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Proyecto guardado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Retornar el proyecto creado a la pantalla anterior
                      Navigator.pop(context, nuevoProyecto);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar Proyecto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
