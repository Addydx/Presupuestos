import 'package:flutter/material.dart';
import '../../models/proyectos/proyecto.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  File?
  _imagenProyecto; //esto es para almacenar la imagen seleccionada del proyecto
  final ImagePicker _picker =
      ImagePicker(); //esto es para seleccionar la imagen del proyecto desde la galeria o la camara

  @override
  void dispose() {
    _nombreProyectoController.dispose();
    _nombreClienteController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final XFile? imagenSeleccionada = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 600,
    );
    if (imagenSeleccionada != null) {
      setState(() {
        _imagenProyecto = File(imagenSeleccionada.path);
      });
    }
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
              GestureDetector(
                onDoubleTap: _seleccionarImagen,
                child: Container(
                  width:
                      double
                          .infinity, //esto es para que el contenedor ocupe todo el ancho disponible
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Colors
                              .grey[300]!, //esto es para darle un borde al contenedor de la imagen
                      width: 2,
                    ),
                  ),
                  child:
                      _imagenProyecto != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imagenProyecto!, //aqui se muestra la imagen seleccionada del proyecto y ! sirve para decirle a dart que no es nula
                              width: double.infinity,
                              fit:
                                  BoxFit
                                      .cover, //esto es para que la imagen ocupe todo el espacio del contenedor y se recorte si es necesario
                            ),
                          )
                          : Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center, //esto es para centrar el contenido del contenedor de la imagen
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color:
                                    Colors
                                        .grey[500], //esto es para mostrar un icono de agregar imagen cuando no se ha seleccionado una imagen para el proyecto
                              ),
                              const SizedBox(
                                height: 8,
                              ), //esto es para darle un espacio entre el icono y el texto
                              Text(
                                'Agregar imagen del proyecto',
                                style: TextStyle(
                                  color:
                                      Colors
                                          .grey[500], //esto es para mostrar un texto de agregar imagen cuando no se ha seleccionado una imagen para el proyecto
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
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
                        imagenPath:
                            _imagenProyecto
                                ?.path, // Guardar la ruta de la imagen
                      );

                      print(
                        'Ruta de la imagen guardada: \\${_imagenProyecto?.path}',
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
