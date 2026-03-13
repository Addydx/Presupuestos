import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_mano_obra.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_materiales.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_equipos.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_finanzas.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_resumen.dart';
import 'package:presupuesto_app/services/materiales_service.dart';
import 'package:presupuesto_app/services/equipos_service.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';
import 'package:presupuesto_app/services/presupuestos_service.dart';

class WizardPresupuestoScreen extends StatefulWidget {
  final String proyectoId;

  const WizardPresupuestoScreen({super.key, required this.proyectoId});

  @override
  State<WizardPresupuestoScreen> createState() =>
      _WizardPresupuestoScreenState();
}

class _WizardPresupuestoScreenState extends State<WizardPresupuestoScreen> {
  late Proyecto proyecto;
  int _currentStep = 0;
  late MaterialesService _materialesService;
  late EquiposService _equiposService;
  late CalculadoraFinanzas _calculadora;

  // Datos del presupuesto
  String _titulo = '';
  double _superficie = 0.0;
  DateTime _fechaCreacion = DateTime.now();
  EstadoPresupuesto _estado = EstadoPresupuesto.borrador;
  ManoObra? _manoObra;
  Finanzas _finanzas = Finanzas();

  final _formKey = GlobalKey<FormState>();
  final _manoObraFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Obtener las instancias singleton
    _materialesService = MaterialesService();
    _equiposService = EquiposService();
    _calculadora = CalculadoraFinanzas();
    // Aquí podrías cargar el proyecto desde Hive si es necesario
    // Por ahora, asumimos que se pasa o se obtiene de otra forma
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Presupuesto')),
      body: Theme(
        data: Theme.of(context).copyWith(
          // Reducir el spacing por defecto del Stepper
          useMaterial3: true,
        ),
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
                _manoObraFormKey.currentState!.save();
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
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 5 ? 'Guardar' : 'Siguiente'),
                  ),
                  const SizedBox(width: 8),
                  if (details.stepIndex > 0)
                    OutlinedButton(
                      onPressed: details.onStepCancel,
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
            validator: (value) => value!.isEmpty ? 'Ingrese un título' : null,
            onSaved: (value) => _titulo = value!,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Superficie (M²)',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            keyboardType: TextInputType.number,
            validator:
                (value) =>
                    double.tryParse(value!) == null
                        ? 'Ingrese un número válido'
                        : null,
            onSaved: (value) => _superficie = double.parse(value!),
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

        // Crear el presupuesto con todos los datos
        final presupuesto = Presupuesto(
          id: DateTime.now().toString(),
          proyectoId: widget.proyectoId,
          titulo: _titulo,
          superficieM2: _superficie,
          fechaCreacion: _fechaCreacion,
          estado: _estado,
          version: 1,
          manoObra: manoObraList,
          equipos: equipos,
          materiales: materiales,
        );

        // Guardar en Hive usando PresupuestosService
        final presupuestosService = PresupuestosService();
        await presupuestosService.agregarPresupuesto(presupuesto);

        print('Presupuesto guardado: ${presupuesto.id}');
        print('Título: ${presupuesto.titulo}');
        print('Materiales: ${materiales.length}');
        print('Equipos: ${equipos.length}');
        print('Mano de obra: ${manoObraList.length}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presupuesto guardado exitosamente'),
            duration: Duration(seconds: 2),
          ),
        );

        // Volver a la vista anterior (proyectos)
        Navigator.of(context).pop();
      } catch (e) {
        print('Error al guardar presupuesto: $e');
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
