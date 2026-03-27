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
  final _ubicacionController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  File?
  _imagenProyecto; //esto es para almacenar la imagen seleccionada del proyecto
  final ImagePicker _picker =
      ImagePicker(); //esto es para seleccionar la imagen del proyecto desde la galeria o la camara
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void dispose() {
    _nombreProyectoController.dispose();
    _nombreClienteController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaInicio() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fechaInicio) {
      setState(() {
        _fechaInicio = picked;
        _fechaInicioController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fechaFin) {
      setState(() {
        _fechaFin = picked;
        _fechaFinController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
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
      appBar: AppBar(title: const Text('Nuevo Proyecto'), elevation: 0),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espacio para imagen del proyecto - mejorado
                GestureDetector(
                  onDoubleTap: _seleccionarImagen,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient:
                          _imagenProyecto == null
                              ? LinearGradient(
                                colors: [
                                  const Color(0xFF2E5090).withOpacity(0.1),
                                  const Color(0xFF00B4DB).withOpacity(0.1),
                                ],
                              )
                              : null,
                      border: Border.all(
                        color: const Color(0xFFE8EEF5),
                        width: 2,
                      ),
                      boxShadow:
                          _imagenProyecto == null
                              ? []
                              : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                ),
                              ],
                    ),
                    child:
                        _imagenProyecto != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _imagenProyecto!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _seleccionarImagen,
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF00B4DB,
                                        ).withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Color(0xFF00B4DB),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Agregar imagen del proyecto',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF6C757D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Toca para seleccionar o haz doble clic',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFFB0BCC4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sección de información principal
                _buildFormSection(
                  context,
                  title: 'Información Principal',
                  children: [
                    _buildFormField(
                      context,
                      controller: _nombreProyectoController,
                      label: 'Nombre del proyecto',
                      hint: 'Ej: Casa Residencial García',
                      icon: Icons.home_work,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Ingrese el nombre del proyecto'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      context,
                      controller: _nombreClienteController,
                      label: 'Nombre del cliente',
                      hint: 'Ej: Juan García López',
                      icon: Icons.person,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Ingrese el nombre del cliente'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      context,
                      controller: _ubicacionController,
                      label: 'Ubicación del proyecto',
                      hint: 'Ej: Calle Principal 123, Apartamento 4B',
                      icon: Icons.location_on,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sección de descripción
                _buildFormSection(
                  context,
                  title: 'Descripción',
                  children: [
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Detalles adicionales del proyecto...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8EEF5),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8EEF5),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00B4DB),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sección de fechas
                _buildFormSection(
                  context,
                  title: 'Fechas',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            context,
                            controller: _fechaInicioController,
                            label: 'Fecha de inicio',
                            onTap: _seleccionarFechaInicio,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            context,
                            controller: _fechaFinController,
                            label: 'Fecha de fin',
                            onTap: _seleccionarFechaFin,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botón de guardar - mejorado
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4DB), Color(0xFF2E5090)],
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
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          final nuevoProyecto = Proyecto(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            nombreProyecto:
                                _nombreProyectoController.text.trim(),
                            nombreCliente: _nombreClienteController.text.trim(),
                            descripcion:
                                _descripcionController.text.trim().isEmpty
                                    ? null
                                    : _descripcionController.text.trim(),
                            imagenPath: _imagenProyecto?.path,
                            ubicacion:
                                _ubicacionController.text.trim().isEmpty
                                    ? null
                                    : _ubicacionController.text.trim(),
                            fechaInicio: _fechaInicio,
                            fechaFin: _fechaFin,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Proyecto guardado correctamente',
                              ),
                              backgroundColor: const Color(0xFF4CAF50),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          Navigator.pop(context, nuevoProyecto);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Guardar Proyecto',
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEF5), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF00B4DB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Selecciona una fecha',
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF00B4DB),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
