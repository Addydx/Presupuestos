import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/core/widgets/opciones_avanzadas.dart';
import 'package:presupuesto_app/models/presupuesto/borrador_presupuesto.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/screens/finanzas/finanzas_screen.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_mano_obra.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_materiales.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_equipos.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_finanzas.dart';
import 'package:presupuesto_app/screens/presupuesto/steps/step_resumen.dart';
import 'package:presupuesto_app/services/borrador_presupuesto_service.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';
import 'package:presupuesto_app/services/materiales_service.dart';
import 'package:presupuesto_app/services/equipos_service.dart';
import 'package:presupuesto_app/services/presupuestos_service.dart';

const _nombresPasos = [
  'Información',
  'Mano de obra',
  'Materiales',
  'Equipos',
  'Finanzas',
  'Resumen',
];

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

class _WizardPresupuestoScreenState extends State<WizardPresupuestoScreen>
    with WidgetsBindingObserver {
  static const int _maxTituloPresupuesto = 100;

  late Proyecto proyecto;
  int _currentStep = 0;
  late MaterialesService _materialesService;
  late EquiposService _equiposService;
  final CalculadoraFinanzas _calculadoraFinanzas = CalculadoraFinanzas();
  final GlobalKey<StepManoObraState> _manoObraKey =
      GlobalKey<StepManoObraState>();
  final GlobalKey<FinanzasScreenState> _finanzasKey =
      GlobalKey<FinanzasScreenState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _superficieController;
  final _focoTitulo = FocusNode();
  final _focoSuperficie = FocusNode();
  final _campoTituloKey = GlobalKey<FormFieldState<String>>();
  final _campoSuperficieKey = GlobalKey<FormFieldState<String>>();

  // Datos del presupuesto
  String _titulo = '';
  double _superficie = 0.0;
  DateTime _fechaCreacion = DateTime.now();
  EstadoPresupuesto _estado = EstadoPresupuesto.borrador;
  ManoObra? _manoObra;
  Finanzas _finanzas = Finanzas();

  final _formKey = GlobalKey<FormState>();
  final _manoObraFormKey = GlobalKey<FormState>();
  final _finanzasFormKey = GlobalKey<FormState>();
  bool _cargandoDatos = true;
  late final String _draftId;
  Timer? _debounceBorrador;
  String _instantaneaInicial = '';

  bool get _esEdicion => widget.presupuesto != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _draftId =
        widget.presupuesto != null
            ? BorradorPresupuestoService.idEdicion(widget.presupuesto!.id)
            : BorradorPresupuestoService.idNuevo(widget.proyectoId);
    // Obtener las instancias singleton
    _materialesService = MaterialesService();
    _equiposService = EquiposService();
    _inicializarDatosBase();
    _tituloController = TextEditingController(text: _titulo);
    _superficieController = TextEditingController(
      text: _superficie > 0 ? _superficie.toString() : '',
    );
    _tituloController.addListener(_alCambiarTitulo);
    _superficieController.addListener(_alCambiarSuperficie);
    _inicializarWizard();
  }

  void _alCambiarTitulo() {
    _titulo = _tituloController.text;
    _programarAutoguardado();
  }

  void _alCambiarSuperficie() {
    _superficie = MonedaUtils.aDouble(_superficieController.text) ?? 0.0;
    _programarAutoguardado();
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

    final borrador = BorradorPresupuestoService().obtener(_draftId);
    if (borrador != null && mounted) {
      final continuar = await _preguntarContinuarBorrador();
      if (continuar) {
        _cargarBorrador(borrador);
      } else {
        await BorradorPresupuestoService().eliminar(_draftId);
      }
    }

    if (mounted) {
      setState(() {});
    }

    _cargandoDatos = false;
    _instantaneaInicial = _instantanea();
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _preguntarContinuarBorrador() async {
    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Tienes un borrador sin terminar'),
            content: const Text(
              'Encontramos un presupuesto que empezaste a llenar y no '
              'terminaste. ¿Quieres continuarlo o prefieres empezar de nuevo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Empezar de nuevo'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuar borrador'),
              ),
            ],
          ),
    );
    return continuar ?? false;
  }

  void _cargarBorrador(BorradorPresupuesto borrador) {
    _titulo = borrador.titulo;
    _tituloController.text = borrador.titulo;
    _superficie = borrador.superficieM2;
    _superficieController.text =
        borrador.superficieM2 > 0 ? borrador.superficieM2.toString() : '';
    _fechaCreacion = borrador.fechaCreacion;
    _estado = borrador.estado;
    _manoObra = borrador.manoObra;
    _finanzas = borrador.finanzas;
    _materialesService.cargarMaterialesPresupuesto(borrador.materiales);
    _equiposService.cargarEquipos(borrador.equipos);
    _currentStep = borrador.pasoActual.clamp(0, 5);
  }

  /// Firma compacta del estado actual, usada para saber si hay cambios
  /// sin guardar al intentar salir.
  String _instantanea() {
    final materiales = _materialesService.obtenerMaterialesPresupuesto();
    final equipos = _equiposService.obtenerEquipos();
    final mo = _manoObra;
    return [
      _titulo,
      _superficie,
      _fechaCreacion.toIso8601String(),
      _estado.index,
      mo == null
          ? 'null'
          : '${mo.tipoPago}|${mo.rol}|${mo.cantidadPersonas}|${mo.diasEstimados}|${mo.costoPorDia}|${mo.montoContrato}|${mo.observaciones}',
      '${_finanzas.porcentajeImprevistos}|${_finanzas.porcentajeUtilidad}|${_finanzas.aplicarIVA}',
      materiales.map((m) => '${m.id}:${m.cantidad}:${m.precioUnitario}').join(','),
      equipos.map((e) => '${e.id}:${e.dias}:${e.costoPorDia}').join(','),
    ].join('§');
  }

  bool get _hayCambiosSinGuardar {
    if (_cargandoDatos) return false;
    return _instantanea() != _instantaneaInicial;
  }

  void _programarAutoguardado() {
    _debounceBorrador?.cancel();
    _debounceBorrador = Timer(
      const Duration(milliseconds: 900),
      _guardarBorradorAhora,
    );
  }

  Future<void> _guardarBorradorAhora() async {
    if (_cargandoDatos || !mounted) return;
    if (!_hayCambiosSinGuardar) return;
    final borrador = BorradorPresupuesto(
      id: _draftId,
      proyectoId: widget.proyectoId,
      presupuestoIdEnEdicion: widget.presupuesto?.id,
      pasoActual: _currentStep,
      titulo: _titulo,
      superficieM2: _superficie,
      fechaCreacion: _fechaCreacion,
      estado: _estado,
      manoObra: _manoObra,
      equipos: _equiposService.obtenerEquipos(),
      materiales: _materialesService.obtenerMaterialesPresupuesto(),
      finanzas: _finanzas,
    );
    await BorradorPresupuestoService().guardar(borrador);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _debounceBorrador?.cancel();
      _guardarBorradorAhora();
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

  Future<bool> _confirmarSalida() async {
    await _guardarBorradorAhora();
    if (!mounted) return false;
    final salir = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Salir del presupuesto?'),
            content: const Text(
              'Guardamos tu progreso como borrador. Podrás continuarlo la '
              'próxima vez que entres a este proyecto.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Seguir editando'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salir'),
              ),
            ],
          ),
    );
    return salir ?? false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceBorrador?.cancel();
    _materialesService.limpiarMaterialesPresupuesto();
    _equiposService.limpiarEquipos();
    _tituloController.removeListener(_alCambiarTitulo);
    _superficieController.removeListener(_alCambiarSuperficie);
    _tituloController.dispose();
    _superficieController.dispose();
    _focoTitulo.dispose();
    _focoSuperficie.dispose();
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
        appBar: AppBar(
          title: Text(_esEdicion ? 'Editar Presupuesto' : 'Crear Presupuesto'),
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildIndicadorProgreso(),
            Expanded(
              child: Container(
                color: AppColors.gray100,
                child: Stepper(
                  currentStep: _currentStep,
                  physics: const BouncingScrollPhysics(),
                  onStepContinue: _alPresionarSiguiente,
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                      _guardarBorradorAhora();
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
                                colors: [
                                  AppColors.yellowPrimary,
                                  AppColors.yellowDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.yellowDark.withValues(
                                    alpha: 0.4,
                                  ),
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
                                        ? (_esEdicion
                                            ? 'Actualizar presupuesto'
                                            : 'Guardar presupuesto')
                                        : 'Siguiente',
                                    style: const TextStyle(
                                      color: AppColors.black,
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
                                  color: AppColors.black,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(48, 48),
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
                      content: StepMateriales(
                        materialesService: _materialesService,
                        onCambio: _alCambiarListaDeItems,
                      ),
                      isActive: _currentStep >= 2,
                    ),
                    Step(
                      title: const Text('Equipos'),
                      content: StepEquipos(
                        equiposService: _equiposService,
                        onCambio: _alCambiarListaDeItems,
                      ),
                      isActive: _currentStep >= 3,
                    ),
                    Step(
                      title: const Text('Finanzas'),
                      content: StepFinanzas(
                        finanzasScreenKey: _finanzasKey,
                        formKey: _finanzasFormKey,
                        totalMateriales:
                            _materialesService.calcularTotalMateriales(),
                        totalManoObra: _manoObra?.costo ?? 0,
                        totalEquipos: _equiposService.calcularTotalEquipos(),
                        onFinanzasChanged: (finanzas) {
                          setState(() {
                            _finanzas = finanzas;
                          });
                          _programarAutoguardado();
                        },
                        finanzasInicial: _finanzas,
                      ),
                      isActive: _currentStep >= 4,
                    ),
                    Step(
                      title: const Text('Resumen'),
                      content: StepResumen(
                        materiales:
                            _materialesService.obtenerMaterialesPresupuesto(),
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
          ],
        ),
        bottomNavigationBar: _buildBarraTotalPersistente(),
      ),
    );
  }

  void _alPresionarSiguiente() {
    switch (_currentStep) {
      case 0:
        final valido = validarPasoYEnfocarError(
          formKey: _formKey,
          camposEnOrden: [
            (_campoTituloKey, _focoTitulo),
            (_campoSuperficieKey, _focoSuperficie),
          ],
        );
        if (valido) {
          _formKey.currentState!.save();
          setState(() => _currentStep++);
          _guardarBorradorAhora();
        }
      case 1:
        final avanzar = _manoObraKey.currentState?.saveForm() ?? false;
        if (avanzar) {
          setState(() => _currentStep++);
          _guardarBorradorAhora();
        }
      case 2:
      case 3:
        setState(() => _currentStep++);
        _guardarBorradorAhora();
      case 4:
        final valido = _finanzasFormKey.currentState?.validate() ?? true;
        if (valido) {
          setState(() => _currentStep++);
          _guardarBorradorAhora();
        } else {
          final campos = _finanzasKey.currentState?.camposEnOrden ?? [];
          for (final (fieldKey, focusNode) in campos) {
            if (fieldKey.currentState?.hasError ?? false) {
              final ctx = fieldKey.currentContext;
              if (ctx != null) {
                Scrollable.ensureVisible(
                  ctx,
                  duration: const Duration(milliseconds: 300),
                  alignment: 0.2,
                );
              }
              focusNode.requestFocus();
              break;
            }
          }
        }
      case 5:
        _guardarPresupuesto();
    }
  }

  Widget _buildIndicadorProgreso() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso ${_currentStep + 1} de ${_nombresPasos.length} · '
            '${_nombresPasos[_currentStep]}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_nombresPasos.length, (i) {
              final esActivo = i == _currentStep;
              final completado = i < _currentStep;
              final Color fondo =
                  esActivo
                      ? AppColors.yellowPrimary
                      : completado
                      ? AppColors.black
                      : AppColors.gray100;
              final Color contenidoColor =
                  esActivo
                      ? AppColors.black
                      : completado
                      ? AppColors.white
                      : AppColors.gray700;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == _nombresPasos.length - 1 ? 0 : 6,
                  ),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: fondo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child:
                        completado
                            ? Icon(Icons.check, size: 14, color: contenidoColor)
                            : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: contenidoColor,
                              ),
                            ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraTotalPersistente() {
    final totalMateriales = _materialesService.calcularTotalMateriales();
    final totalManoObra = _manoObra?.costo ?? 0;
    final totalEquipos = _equiposService.calcularTotalEquipos();
    final resultados = _calculadoraFinanzas.calcularTodo(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
      finanzas: _finanzas,
    );
    final total = resultados['totalFinal'] ?? 0;

    return Material(
      color: AppColors.black,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total estimado',
                style: TextStyle(color: AppColors.gray300, fontSize: 12),
              ),
              Text(
                MonedaUtils.formatear(total),
                style: const TextStyle(
                  color: AppColors.yellowPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
          CampoValidado(
            fieldKey: _campoTituloKey,
            focusNode: _focoTitulo,
            controller: _tituloController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Título del Presupuesto',
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            maxLength: _maxTituloPresupuesto,
            validator:
                (value) => Validadores.requerido(
                  value,
                  campo: 'un título',
                  maximo: _maxTituloPresupuesto,
                ),
          ),
          const SizedBox(height: 8),
          OpcionesAvanzadas(
            children: [
              CampoValidado(
                fieldKey: _campoSuperficieKey,
                focusNode: _focoSuperficie,
                controller: _superficieController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Superficie (m²) — opcional',
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (value) {
                  final raw = (value ?? '').trim();
                  if (raw.isEmpty) return null;
                  final superficie = MonedaUtils.aDouble(raw);
                  if (superficie == null) {
                    return 'Ingresa un número válido';
                  }
                  if (superficie < 0) {
                    return 'La superficie no puede ser negativa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
                      minimumSize: const Size(48, 48),
                    ),
                    child: const Text('Cambiar', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EstadoPresupuesto>(
                initialValue: _estado,
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
                onChanged: (value) {
                  setState(() => _estado = value!);
                  _programarAutoguardado();
                },
              ),
            ],
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
      _programarAutoguardado();
    }
  }

  /// Materiales y equipos se agregan/editan dentro de una hoja modal, sin
  /// pasar por el `onSaved` de un Step: este callback es lo único que le
  /// avisa al wizard que debe refrescar la barra de total persistente y
  /// disparar el autoguardado del borrador.
  void _alCambiarListaDeItems() {
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
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
        _programarAutoguardado();
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
        await BorradorPresupuestoService().eliminar(_draftId);
        _instantaneaInicial = _instantanea();

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
            content: Text('No se pudo guardar el presupuesto: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
