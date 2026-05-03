import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_mano_obra.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_materiales.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_equipos.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_finanzas.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_resumen.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';
import 'package:presupuesto_app/services/materiales_service.dart';
import 'package:presupuesto_app/services/equipos_service.dart';
import 'package:presupuesto_app/services/presupuestos_service.dart';

class WizardPresupuestoScreen extends StatefulWidget {
  final String proyectoId;
  final Presupuesto? presupuesto;

  const WizardPresupuestoScreen({
    super.key,
    required this.proyectoId,
    this.presupuesto,
  });

  @override
  State<WizardPresupuestoScreen> createState() =>
      _WizardPresupuestoScreenState();
}

class _WizardPresupuestoScreenState extends State<WizardPresupuestoScreen> {
  static const int _maxTituloPresupuesto = 100;

  late Proyecto proyecto;
  int _currentStep = 0;
  late MaterialesService _materialesService;
  late EquiposService _equiposService;
  final CalculadoraFinanzas _calculadoraFinanzas = CalculadoraFinanzas();
  final GlobalKey<StepManoObraState> _manoObraKey =
      GlobalKey<StepManoObraState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _superficieController;

  // Datos del presupuesto
  String _titulo = '';
  double _superficie = 0.0;
  DateTime _fechaCreacion = DateTime.now();
  EstadoPresupuesto _estado = EstadoPresupuesto.borrador;
  ManoObra? _manoObra;
  Finanzas _finanzas = Finanzas();

  final _formKey = GlobalKey<FormState>();
  final _manoObraFormKey = GlobalKey<FormState>();
  bool _cargandoDatos = true;

  bool get _esEdicion => widget.presupuesto != null;

  @override
  void initState() {
    super.initState();
    // Obtener las instancias singleton
    _materialesService = MaterialesService();
    _equiposService = EquiposService();
    _inicializarDatosBase();
    _tituloController = TextEditingController(text: _titulo);
    _superficieController = TextEditingController(
      text: _superficie > 0 ? _superficie.toString() : '',
    );
    _inicializarWizard();
  }

  void _inicializarDatosBase() {
    final presupuesto = widget.presupuesto;
    if (presupuesto == null) {
      return;
    }

    _titulo = presupuesto.titulo;
    _superficie = presupuesto.superficieM2;
    _fechaCreacion = presupuesto.fechaCreacion;
    _estado = presupuesto.estado;
    _manoObra =
        presupuesto.manoObra.isNotEmpty ? presupuesto.manoObra.first : null;
    _finanzas = presupuesto.finanzas;
  }

  Future<void> _inicializarWizard() async {
    await _reiniciarMaterialesTemporales(refrescar: false);
    await _reiniciarEquiposTemporales(refrescar: false);

    final presupuesto = widget.presupuesto;
    if (presupuesto != null) {
      await _materialesService.cargarMaterialesPresupuesto(
        presupuesto.materiales,
      );
      await _equiposService.cargarEquipos(presupuesto.equipos);
    }

    if (mounted) {
      setState(() {});
    }

    _cargandoDatos = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _reiniciarMaterialesTemporales({bool refrescar = true}) async {
    await _materialesService.limpiarMaterialesPresupuesto();
    if (refrescar && mounted) {
      setState(() {});
    }
  }

  Future<void> _reiniciarEquiposTemporales({bool refrescar = true}) async {
    await _equiposService.limpiarEquipos();
    if (refrescar && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _materialesService.limpiarMaterialesPresupuesto();
    _equiposService.limpiarEquipos();
    _tituloController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_esEdicion ? 'Editar Presupuesto' : 'Crear Presupuesto'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Presupuesto' : 'Crear Presupuesto'),
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(useMaterial3: true),
        child: Container(
          color: const Color(0xFFF5F7FA),
          child: Stepper(
            currentStep: _currentStep,
            physics: const BouncingScrollPhysics(),
            onStepContinue: () {
              if (_currentStep == 0) {
                // Validar paso 1: Información básica
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (_currentStep < 5) {
                    setState(() => _currentStep++);
                  }
                }
              } else if (_currentStep == 1) {
                // Validar paso 2: Mano de obra
                if (_manoObraFormKey.currentState!.validate()) {
                  _manoObraKey.currentState?.saveForm();
                  if (_currentStep < 5) {
                    setState(() => _currentStep++);
                  }
                }
              } else if (_currentStep < 5) {
                // Pasos 2-4: Materiales, Equipos, Finanzas
                setState(() => _currentStep++);
              } else if (_currentStep == 5) {
                // Paso 5: Resumen - Guardar directamente
                _guardarPresupuesto();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B4DB), Color(0xFF2E5090)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B4DB).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: details.onStepContinue,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Text(
                              _currentStep == 5
                                  ? (_esEdicion ? 'Actualizar' : 'Guardar')
                                  : 'Siguiente',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (details.stepIndex > 0)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2E5090),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Atrás'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Información Básica'),
                content: _buildStepInfo(),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Mano de Obra'),
                content: _buildStepManoObra(),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Materiales'),
                content: StepMateriales(materialesService: _materialesService),
                isActive: _currentStep >= 2,
              ),
              Step(
                title: const Text('Equipos'),
                content: StepEquipos(equiposService: _equiposService),
                isActive: _currentStep >= 3,
              ),
              Step(
                title: const Text('Finanzas'),
                content: StepFinanzas(
                  totalMateriales: _materialesService.calcularTotalMateriales(),
                  totalManoObra: _manoObra?.costo ?? 0,
                  totalEquipos: _equiposService.calcularTotalEquipos(),
                  onFinanzasChanged: (finanzas) {
                    setState(() {
                      _finanzas = finanzas;
                    });
                  },
                  finanzasInicial: _finanzas,
                ),
                isActive: _currentStep >= 4,
              ),
              Step(
                title: const Text('Resumen'),
                content: StepResumen(
                  materiales: _materialesService.obtenerMaterialesPresupuesto(),
                  equipos: _equiposService.obtenerEquipos(),
                  manoObra: _manoObra != null ? [_manoObra!] : [],
                  finanzas: _finanzas,
                  titulo: _titulo.isNotEmpty ? _titulo : null,
                  fecha: _fechaCreacion,
                ),
                isActive: _currentStep >= 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepInfo() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Título del Presupuesto',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            controller: _tituloController,
            maxLength: _maxTituloPresupuesto,
            validator: (value) {
              final titulo = (value ?? '').trim();
              if (titulo.isEmpty) {
                return 'Ingrese un título';
              }
              if (titulo.length > _maxTituloPresupuesto) {
                return 'El título no puede superar $_maxTituloPresupuesto caracteres';
              }
              return null;
            },
            onSaved: (value) => _titulo = (value ?? '').trim(),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Superficie (M²)',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            controller: _superficieController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) {
                return 'Ingrese la superficie';
              }

              final superficie = double.tryParse(raw.replaceAll(',', '.'));
              if (superficie == null) {
                return 'Ingrese un número válido';
              }
              if (superficie < 0) {
                return 'La superficie no puede ser negativa';
              }
              return null;
            },
            onSaved: (value) {
              _superficie =
                  double.tryParse((value ?? '').replaceAll(',', '.')) ?? 0.0;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fecha: ${_fechaCreacion.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: _seleccionarFecha,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: const Text('Cambiar', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EstadoPresupuesto>(
            value: _estado,
            decoration: const InputDecoration(
              labelText: 'Estado',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            items:
                EstadoPresupuesto.values.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado.toString().split('.').last),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _estado = value!),
          ),
        ],
      ),
    );
  }

  void _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaCreacion,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fechaCreacion) {
      setState(() {
        _fechaCreacion = picked;
      });
    }
  }

  Widget _buildStepManoObra() {
    return StepManoObra(
      key: _manoObraKey,
      formKey: _manoObraFormKey,
      initialData: _manoObra,
      onSaved: (manoObra) {
        setState(() {
          _manoObra = manoObra;
        });
      },
    );
  }

  void _guardarPresupuesto() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Obtener datos de los servicios
        final materiales = _materialesService.obtenerMaterialesPresupuesto();
        final equipos = _equiposService.obtenerEquipos();
        final manoObraList = <ManoObra>[if (_manoObra != null) _manoObra!];
        final resultados = _calculadoraFinanzas.calcularTodo(
          totalMateriales: materiales.fold<double>(
            0,
            (sum, item) => sum + item.total,
          ),
          totalManoObra: manoObraList.fold<double>(
            0,
            (sum, item) => sum + item.costo,
          ),
          totalEquipos: equipos.fold<double>(
            0,
            (sum, item) => sum + item.total,
          ),
          finanzas: _finanzas,
        );

        // Crear el presupuesto con todos los datos
        final presupuesto = Presupuesto(
          id: widget.presupuesto?.id ?? DateTime.now().toString(),
          proyectoId: widget.proyectoId,
          titulo: _titulo,
          superficieM2: _superficie,
          fechaCreacion: _fechaCreacion,
          estado: _estado,
          version: _esEdicion ? (widget.presupuesto!.version + 1) : 1,
          manoObra: manoObraList,
          equipos: equipos,
          materiales: materiales,
          totalFinal: resultados['totalFinal'] ?? 0,
          finanzas: _finanzas,
        );

        // Guardar en Hive usando PresupuestosService
        final presupuestosService = PresupuestosService();
        if (_esEdicion) {
          await presupuestosService.actualizarPresupuesto(presupuesto);
        } else {
          await presupuestosService.agregarPresupuesto(presupuesto);
        }
        await _materialesService.limpiarMaterialesPresupuesto();
        await _equiposService.limpiarEquipos();

        print('Presupuesto guardado: ${presupuesto.id}');
        print('Título: ${presupuesto.titulo}');
        print('Materiales: ${materiales.length}');
        print('Equipos: ${equipos.length}');
        print('Mano de obra: ${manoObraList.length}');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Presupuesto actualizado exitosamente'
                  : 'Presupuesto guardado exitosamente',
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Volver a la vista anterior (proyectos)
        Navigator.of(context).pop(presupuesto);
      } catch (e) {
        print('Error al guardar presupuesto: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
