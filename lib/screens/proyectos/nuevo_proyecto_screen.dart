import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/core/widgets/opciones_avanzadas.dart';
import '../../models/proyectos/proyecto.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NuevoProyectoScreen extends StatefulWidget {
  const NuevoProyectoScreen({super.key});

  @override
  State<NuevoProyectoScreen> createState() => _NuevoProyectoScreenState();
}

class _NuevoProyectoScreenState extends State<NuevoProyectoScreen> {
  static const int _maxDescripcion = 100;

  final _formKey = GlobalKey<FormState>();
  final _nombreProyectoController = TextEditingController();
  final _nombreClienteController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();

  final _focoNombreProyecto = FocusNode();
  final _focoNombreCliente = FocusNode();
  final _focoUbicacion = FocusNode();
  final _focoDescripcion = FocusNode();
  final _focoFechaFin = FocusNode();

  final _campoNombreProyectoKey = GlobalKey<FormFieldState<String>>();
  final _campoNombreClienteKey = GlobalKey<FormFieldState<String>>();
  final _campoUbicacionKey = GlobalKey<FormFieldState<String>>();
  final _campoDescripcionKey = GlobalKey<FormFieldState<String>>();
  final _campoFechaFinKey = GlobalKey<FormFieldState<String>>();

  File?
  _imagenProyecto; //esto es para almacenar la imagen seleccionada del proyecto
  final ImagePicker _picker =
      ImagePicker(); //esto es para seleccionar la imagen del proyecto desde la galeria o la camara
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    // Fecha de inicio = hoy por defecto: es el caso típico y evita un
    // selector de fecha obligatorio para empezar un proyecto.
    _fechaInicio = DateTime.now();
    _fechaInicioController.text = _formatearFecha(_fechaInicio!);
  }

  @override
  void dispose() {
    _nombreProyectoController.dispose();
    _nombreClienteController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _focoNombreProyecto.dispose();
    _focoNombreCliente.dispose();
    _focoUbicacion.dispose();
    _focoDescripcion.dispose();
    _focoFechaFin.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) =>
      '${fecha.day}/${fecha.month}/${fecha.year}';

  bool get _hayCambiosSinGuardar {
    return _nombreProyectoController.text.trim().isNotEmpty ||
        _nombreClienteController.text.trim().isNotEmpty ||
        _descripcionController.text.trim().isNotEmpty ||
        _ubicacionController.text.trim().isNotEmpty ||
        _imagenProyecto != null ||
        _fechaFin != null;
  }

  Future<bool> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Salir sin guardar?'),
            content: const Text(
              'Perderás los datos que capturaste para este proyecto.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Seguir editando'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salir sin guardar'),
              ),
            ],
          ),
    );
    return salir ?? false;
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
        _fechaInicioController.text = _formatearFecha(picked);

        if (_fechaFin != null && _fechaFin!.isBefore(picked)) {
          _fechaFin = null;
          _fechaFinController.clear();
        }
      });
      _campoFechaFinKey.currentState?.validate();
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fechaInicio ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fechaFin) {
      setState(() {
        _fechaFin = picked;
        _fechaFinController.text = _formatearFecha(picked);
      });
      _campoFechaFinKey.currentState?.validate();
    }
  }

  void _limpiarFechaFin() {
    setState(() {
      _fechaFin = null;
      _fechaFinController.clear();
    });
    _campoFechaFinKey.currentState?.validate();
  }

  void _guardar() {
    final valido = validarPasoYEnfocarError(
      formKey: _formKey,
      camposEnOrden: [
        (_campoNombreProyectoKey, _focoNombreProyecto),
        (_campoNombreClienteKey, _focoNombreCliente),
        (_campoDescripcionKey, _focoDescripcion),
        (_campoFechaFinKey, _focoFechaFin),
      ],
    );
    if (!valido) return;

    final nuevoProyecto = Proyecto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombreProyecto: _nombreProyectoController.text.trim(),
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
        content: const Text('Proyecto guardado correctamente'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, nuevoProyecto);
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
    return PopScope(
      canPop: !_hayCambiosSinGuardar,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final salir = await _confirmarSalida();
        if (salir && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nuevo Proyecto'), elevation: 0),
        body: Container(
          color: AppColors.gray100,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de información principal (lo único
                  // imprescindible para crear el proyecto).
                  _buildFormSection(
                    context,
                    title: 'Información Principal',
                    children: [
                      _buildFormField(
                        context,
                        fieldKey: _campoNombreProyectoKey,
                        focusNode: _focoNombreProyecto,
                        siguienteFoco: _focoNombreCliente,
                        controller: _nombreProyectoController,
                        label: 'Nombre del proyecto',
                        hint: 'Ej: Casa Residencial García',
                        icon: Icons.home_work,
                        validator:
                            (value) => Validadores.requerido(
                              value,
                              campo: 'el nombre del proyecto',
                              maximo: 100,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildFormField(
                        context,
                        fieldKey: _campoNombreClienteKey,
                        focusNode: _focoNombreCliente,
                        controller: _nombreClienteController,
                        label: 'Nombre del cliente',
                        hint: 'Ej: Juan García López',
                        icon: Icons.person,
                        textInputAction: TextInputAction.done,
                        validator:
                            (value) => Validadores.requerido(
                              value,
                              campo: 'el nombre del cliente',
                              maximo: 100,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  OpcionesAvanzadas(
                    titulo: 'Mostrar opciones avanzadas',
                    children: [
                      _buildFormSection(
                        context,
                        title: 'Detalles opcionales',
                        children: [
                          GestureDetector(
                            onDoubleTap: _seleccionarImagen,
                            child: Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient:
                                    _imagenProyecto == null
                                        ? LinearGradient(
                                          colors: [
                                            AppColors.gray300.withValues(
                                              alpha: 0.4,
                                            ),
                                            AppColors.gray300.withValues(
                                              alpha: 0.15,
                                            ),
                                          ],
                                        )
                                        : null,
                                border: Border.all(
                                  color: AppColors.gray300,
                                  width: 2,
                                ),
                              ),
                              child:
                                  _imagenProyecto != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
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
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.yellowSoft,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.add_a_photo,
                                                  size: 32,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Agregar imagen del proyecto (opcional)',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.copyWith(
                                                  color: AppColors.gray700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            context,
                            fieldKey: _campoUbicacionKey,
                            controller: _ubicacionController,
                            focusNode: _focoUbicacion,
                            siguienteFoco: _focoDescripcion,
                            label: 'Ubicación del proyecto',
                            hint: 'Ej: Calle Principal 123, Apartamento 4B',
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Descripción',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 6),
                          CampoValidado(
                            fieldKey: _campoDescripcionKey,
                            focusNode: _focoDescripcion,
                            controller: _descripcionController,
                            maxLength: _maxDescripcion,
                            maxLines: 4,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              // La descripción es opcional: solo se valida
                              // la longitud máxima si el usuario escribió
                              // algo.
                              final texto = (value ?? '').trim();
                              if (texto.isEmpty) return null;
                              if (texto.length > _maxDescripcion) {
                                return 'La descripción no puede superar $_maxDescripcion caracteres';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Detalles adicionales del proyecto...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.gray500,
                                  width: 1,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.gray100,
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                  fieldKey: _campoFechaFinKey,
                                  focusNode: _focoFechaFin,
                                  controller: _fechaFinController,
                                  label: 'Fecha de fin (opcional)',
                                  onTap: _seleccionarFechaFin,
                                  onClear:
                                      _fechaFin != null
                                          ? _limpiarFechaFin
                                          : null,
                                  validator: (_) {
                                    if (_fechaInicio != null &&
                                        _fechaFin != null &&
                                        _fechaFin!.isBefore(_fechaInicio!)) {
                                      return 'La fecha de fin no puede ser anterior a la de inicio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Botón de guardar
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.yellowPrimary, AppColors.yellowDark],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellowDark.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _guardar,
                        borderRadius: BorderRadius.circular(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check,
                              color: AppColors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Guardar Proyecto',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: AppColors.black,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray300, width: 1),
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
    required GlobalKey<FormFieldState<String>> fieldKey,
    required FocusNode focusNode,
    FocusNode? siguienteFoco,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        CampoValidado(
          fieldKey: fieldKey,
          focusNode: focusNode,
          controller: controller,
          siguienteFoco: siguienteFoco,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gray500, width: 1),
            ),
            filled: true,
            fillColor: AppColors.gray100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          validator: validator ?? (_) => null,
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    GlobalKey<FormFieldState<String>>? fieldKey,
    FocusNode? focusNode,
    VoidCallback? onClear,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: fieldKey,
          focusNode: focusNode,
          controller: controller,
          readOnly: true,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: 'Sin definir',
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: AppColors.black,
            ),
            suffixIcon:
                onClear != null
                    ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Quitar fecha',
                      onPressed: onClear,
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gray500, width: 1),
            ),
            filled: true,
            fillColor: AppColors.gray100,
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
