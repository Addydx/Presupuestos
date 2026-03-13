import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_mano_obra.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_materiales.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

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

  // Datos del presupuesto
  String _titulo = '';
  double _superficie = 0.0;
  DateTime _fechaCreacion = DateTime.now();
  EstadoPresupuesto _estado = EstadoPresupuesto.borrador;
  ManoObra? _manoObra;

  final _formKey = GlobalKey<FormState>();
  final _manoObraFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Obtener la instancia singleton de MaterialesService
    _materialesService = MaterialesService();
    // Aquí podrías cargar el proyecto desde Hive si es necesario
    // Por ahora, asumimos que se pasa o se obtiene de otra forma
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Presupuesto')),
      body: SingleChildScrollView(
        child: Stepper(
          currentStep: _currentStep,
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
            } else {
              // Otros pasos
              if (_currentStep < 5) {
                setState(() => _currentStep++);
              } else {
                _guardarPresupuesto();
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
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
              content: const Text('Paso 4: Equipos'),
              isActive: _currentStep >= 3,
            ),
            Step(
              title: const Text('Finanzas'),
              content: const Text('Paso 5: Finanzas'),
              isActive: _currentStep >= 4,
            ),
            Step(
              title: const Text('Resumen'),
              content: const Text('Paso 6: Resumen'),
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
            ),
            validator: (value) => value!.isEmpty ? 'Ingrese un título' : null,
            onSaved: (value) => _titulo = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Superficie (M²)'),
            keyboardType: TextInputType.number,
            validator:
                (value) =>
                    double.tryParse(value!) == null
                        ? 'Ingrese un número válido'
                        : null,
            onSaved: (value) => _superficie = double.parse(value!),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fecha de Creación: ${_fechaCreacion.toLocal().toString().split(' ')[0]}',
                ),
              ),
              TextButton(
                onPressed: _seleccionarFecha,
                child: const Text('Seleccionar Fecha'),
              ),
            ],
          ),
          DropdownButtonFormField<EstadoPresupuesto>(
            value: _estado,
            decoration: const InputDecoration(labelText: 'Estado'),
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

  void _guardarPresupuesto() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Crear el presupuesto con los datos
      final presupuesto = Presupuesto(
        id: DateTime.now().toString(), // Generar ID único
        proyectoId: widget.proyectoId,
        titulo: _titulo,
        superficieM2: _superficie,
        fechaCreacion: _fechaCreacion,
        estado: _estado,
        version: 1,
        manoObra: _manoObra != null ? [_manoObra!] : [],
        equipos: [],
        materiales: [],
      );
      // Aquí guardar en Hive o navegar a siguiente pantalla
      print('Presupuesto creado: ${presupuesto.id}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Presupuesto guardado')));
    }
  }
}
