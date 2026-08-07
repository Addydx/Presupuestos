import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/advertencia_monto_alto.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/core/widgets/opciones_avanzadas.dart';
import 'package:presupuesto_app/models/presupuesto/borrador_presupuesto.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/screens/materiales/catalogo_materiales_screen.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard/agregar_equipo_screen.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard/agregar_material_screen.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard/pregunta_scaffold.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard/widgets/opcion_grande.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard/widgets/selector_porcentaje.dart';
import 'package:presupuesto_app/services/borrador_presupuesto_service.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';
import 'package:presupuesto_app/services/materiales_service.dart';
import 'package:presupuesto_app/services/equipos_service.dart';
import 'package:presupuesto_app/services/presupuestos_service.dart';

/// Identificador estable de cada pantalla del flujo. El orden de esta
/// lista NO define el orden real: el orden real lo arma [_pasosActivos]
/// dinámicamente según las respuestas (ver esa función para el porqué de
/// cada rama).
enum _PasoId {
  titulo,
  tamano,
  materiales,
  tieneManoObra,
  tipoPago,
  rol,
  cantidadPersonas,
  diasEstimados,
  costoPorDia,
  montoContrato,
  observaciones,
  equipos,
  imprevistos,
  utilidad,
  iva,
  resumen,
}

const _valoresImprevistos = [5.0, 10.0, 15.0];
const _valoresUtilidad = [10.0, 15.0, 20.0, 25.0];

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

  int _pasoIndex = 0;
  late MaterialesService _materialesService;
  late EquiposService _equiposService;
  final CalculadoraFinanzas _calculadoraFinanzas = CalculadoraFinanzas();

  // ------------ Información básica ------------
  late final TextEditingController _tituloController;
  late final TextEditingController _superficieController;
  final _focoTitulo = FocusNode();
  final _focoSuperficie = FocusNode();
  final _campoTituloKey = GlobalKey<FormFieldState<String>>();
  final _campoSuperficieKey = GlobalKey<FormFieldState<String>>();
  String _titulo = '';
  double _superficie = 0.0;
  DateTime _fechaCreacion = DateTime.now();
  EstadoPresupuesto _estado = EstadoPresupuesto.borrador;

  // ------------ Mano de obra ------------
  ManoObra? _manoObra;
  bool? _tieneManoObra;
  TipoPago? _tipoPago;
  final _rolController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _diasController = TextEditingController();
  final _costoPorDiaController = TextEditingController();
  final _montoContratoController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _focoRol = FocusNode();
  final _focoCantidad = FocusNode();
  final _focoDias = FocusNode();
  final _focoCostoPorDia = FocusNode();
  final _focoMontoContrato = FocusNode();
  final _focoObservaciones = FocusNode();
  final _campoCantidadKey = GlobalKey<FormFieldState<String>>();
  final _campoDiasKey = GlobalKey<FormFieldState<String>>();
  final _campoCostoPorDiaKey = GlobalKey<FormFieldState<String>>();
  final _campoMontoContratoKey = GlobalKey<FormFieldState<String>>();
  String? _observaciones;
  bool _costoPorDiaSospechoso = false;
  bool _montoContratoSospechoso = false;

  // ------------ Finanzas ------------
  Finanzas _finanzas = Finanzas();
  bool _imprevistosModoOtro = false;
  bool _utilidadModoOtro = false;
  final _imprevistosOtroController = TextEditingController();
  final _utilidadOtroController = TextEditingController();
  final _focoImprevistosOtro = FocusNode();
  final _focoUtilidadOtro = FocusNode();

  bool _cargandoDatos = true;
  bool _guardando = false;
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
    _materialesService = MaterialesService();
    _equiposService = EquiposService();
    _inicializarDatosBase();
    _tituloController = TextEditingController(text: _titulo);
    _superficieController = TextEditingController(
      text: _superficie > 0 ? _superficie.toString() : '',
    );
    _tituloController.addListener(_alCambiarTitulo);
    _superficieController.addListener(_alCambiarSuperficie);
    _imprevistosModoOtro =
        !_valoresImprevistos.contains(_finanzas.porcentajeImprevistos);
    _utilidadModoOtro =
        !_valoresUtilidad.contains(_finanzas.porcentajeUtilidad);
    if (_imprevistosModoOtro) {
      _imprevistosOtroController.text =
          _finanzas.porcentajeImprevistos.toString();
    }
    if (_utilidadModoOtro) {
      _utilidadOtroController.text = _finanzas.porcentajeUtilidad.toString();
    }
    _inicializarWizard();
  }

  void _alCambiarTitulo() {
    setState(() => _titulo = _tituloController.text);
    _programarAutoguardado();
  }

  void _alCambiarSuperficie() {
    _superficie = MonedaUtils.aDouble(_superficieController.text) ?? 0.0;
    _programarAutoguardado();
  }

  void _inicializarDatosBase() {
    final presupuesto = widget.presupuesto;
    if (presupuesto == null) return;

    _titulo = presupuesto.titulo;
    _superficie = presupuesto.superficieM2;
    _fechaCreacion = presupuesto.fechaCreacion;
    _estado = presupuesto.estado;
    _finanzas = presupuesto.finanzas;
    _cargarDatosManoObra(
      presupuesto.manoObra.isNotEmpty ? presupuesto.manoObra.first : null,
    );
  }

  /// Cuando ya existe mano de obra guardada, se restaura la respuesta
  /// "Sí" y sus datos. Cuando no existe, la pregunta "¿vas a pagar mano de
  /// obra?" queda sin responder (`null`) — el modelo no distingue "no
  /// aplica" de "todavía no se preguntó", así que se vuelve a preguntar.
  /// Es un toque extra en el peor caso, no un bloqueo.
  void _cargarDatosManoObra(ManoObra? mo) {
    _manoObra = mo;
    if (mo == null) {
      _tieneManoObra = null;
      _tipoPago = null;
      return;
    }
    _tieneManoObra = true;
    _tipoPago = mo.tipoPago;
    _rolController.text = mo.rol ?? '';
    _cantidadController.text = mo.cantidadPersonas?.toString() ?? '';
    _diasController.text = mo.diasEstimados?.toString() ?? '';
    _costoPorDiaController.text = MonedaInputFormatter.textoInicial(
      mo.costoPorDia ?? 0,
    );
    _montoContratoController.text = MonedaInputFormatter.textoInicial(
      mo.montoContrato ?? 0,
    );
    _observaciones = mo.observaciones;
    _observacionesController.text = mo.observaciones ?? '';
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

    if (mounted) setState(() {});

    _cargandoDatos = false;
    _instantaneaInicial = _instantanea();
    if (mounted) setState(() {});
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
    _finanzas = borrador.finanzas;
    _cargarDatosManoObra(borrador.manoObra);
    _materialesService.cargarMaterialesPresupuesto(borrador.materiales);
    _equiposService.cargarEquipos(borrador.equipos);
    _pasoIndex = borrador.pasoActual.clamp(0, _pasos.length - 1);
  }

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
      materiales
          .map((m) => '${m.id}:${m.cantidad}:${m.precioUnitario}')
          .join(','),
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
      pasoActual: _pasoIndex,
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
    if (refrescar && mounted) setState(() {});
  }

  Future<void> _reiniciarEquiposTemporales({bool refrescar = true}) async {
    await _equiposService.limpiarEquipos();
    if (refrescar && mounted) setState(() {});
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

  Future<void> _intentarSalir() async {
    final salir = await _confirmarSalida();
    if (salir && mounted) Navigator.of(context).pop();
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
    _rolController.dispose();
    _cantidadController.dispose();
    _diasController.dispose();
    _costoPorDiaController.dispose();
    _montoContratoController.dispose();
    _observacionesController.dispose();
    _focoRol.dispose();
    _focoCantidad.dispose();
    _focoDias.dispose();
    _focoCostoPorDia.dispose();
    _focoMontoContrato.dispose();
    _focoObservaciones.dispose();
    _imprevistosOtroController.dispose();
    _utilidadOtroController.dispose();
    _focoImprevistosOtro.dispose();
    _focoUtilidadOtro.dispose();
    super.dispose();
  }

  // ================== ORQUESTACIÓN DE PASOS ==================

  List<_PasoId> get _pasos => [
    _PasoId.titulo,
    _PasoId.tamano,
    _PasoId.materiales,
    _PasoId.tieneManoObra,
    if (_tieneManoObra == true) _PasoId.tipoPago,
    if (_tieneManoObra == true && _tipoPago == TipoPago.porDia) ...[
      _PasoId.rol,
      _PasoId.cantidadPersonas,
      _PasoId.diasEstimados,
      _PasoId.costoPorDia,
    ],
    if (_tieneManoObra == true && _tipoPago == TipoPago.porContrato) ...[
      _PasoId.montoContrato,
      _PasoId.observaciones,
    ],
    _PasoId.equipos,
    _PasoId.imprevistos,
    _PasoId.utilidad,
    _PasoId.iva,
    _PasoId.resumen,
  ];

  void _irASeccion(_PasoId id) {
    final pasos = _pasos;
    final indice = pasos.indexOf(id);
    if (indice == -1) return;
    setState(() => _pasoIndex = indice);
  }

  void _atras() {
    if (_pasoIndex == 0) {
      _intentarSalir();
      return;
    }
    setState(() => _pasoIndex--);
    _guardarBorradorAhora();
  }

  void _siguiente() {
    final pasos = _pasos;
    final actual = pasos[_pasoIndex];
    if (!_puedeAvanzar(actual)) return;
    if (actual == _PasoId.resumen) {
      _guardarPresupuesto();
      return;
    }
    setState(() => _pasoIndex = (_pasoIndex + 1).clamp(0, pasos.length - 1));
    _guardarBorradorAhora();
  }

  bool _puedeAvanzar(_PasoId paso) {
    switch (paso) {
      case _PasoId.titulo:
        return _tituloController.text.trim().isNotEmpty;
      case _PasoId.tamano:
        final texto = _superficieController.text.trim();
        if (texto.isEmpty) return true;
        final valor = MonedaUtils.aDouble(texto);
        return valor != null && valor >= 0;
      case _PasoId.materiales:
      case _PasoId.equipos:
        return true;
      case _PasoId.tieneManoObra:
        return _tieneManoObra != null;
      case _PasoId.tipoPago:
        return _tipoPago != null;
      case _PasoId.rol:
        return true;
      case _PasoId.cantidadPersonas:
        return Validadores.enteroPositivo(
              _cantidadController.text,
              campo: 'la cantidad de personas',
            ) ==
            null;
      case _PasoId.diasEstimados:
        return Validadores.enteroPositivo(
              _diasController.text,
              campo: 'los días',
            ) ==
            null;
      case _PasoId.costoPorDia:
        return Validadores.numeroPositivo(
              _costoPorDiaController.text,
              campo: 'el costo por día',
            ) ==
            null;
      case _PasoId.montoContrato:
        return Validadores.numeroPositivo(
              _montoContratoController.text,
              campo: 'el monto del contrato',
            ) ==
            null;
      case _PasoId.observaciones:
        return true;
      case _PasoId.imprevistos:
        if (!_imprevistosModoOtro) return true;
        final valor = MonedaUtils.aDouble(_imprevistosOtroController.text);
        return valor != null && valor >= 0 && valor <= 100;
      case _PasoId.utilidad:
        if (!_utilidadModoOtro) return true;
        final valor = MonedaUtils.aDouble(_utilidadOtroController.text);
        return valor != null && valor >= 0 && valor <= 100;
      case _PasoId.iva:
        return true;
      case _PasoId.resumen:
        return true;
    }
  }

  // ================== MANO DE OBRA: reconstrucción en vivo ==================

  void _actualizarManoObra() {
    setState(() {
      if (_tieneManoObra != true || _tipoPago == null) {
        _manoObra = null;
      } else {
        final rolTexto = _rolController.text.trim();
        _manoObra = ManoObra(
          id: _manoObra?.id,
          tipoPago: _tipoPago!,
          rol: rolTexto.isEmpty ? null : rolTexto,
          cantidadPersonas: int.tryParse(_cantidadController.text.trim()),
          diasEstimados: int.tryParse(_diasController.text.trim()),
          costoPorDia: MonedaInputFormatter.valorDe(
            _costoPorDiaController.text,
          ),
          montoContrato: MonedaInputFormatter.valorDe(
            _montoContratoController.text,
          ),
          observaciones: _observaciones,
        );
      }
    });
    _programarAutoguardado();
  }

  // ================== FINANZAS: totales en vivo ==================

  double get _totalMaterialesActual =>
      _materialesService.calcularTotalMateriales();
  double get _totalManoObraActual => _manoObra?.costo ?? 0;
  double get _totalEquiposActual => _equiposService.calcularTotalEquipos();

  double get _costoDirectoActual => _calculadoraFinanzas.costoDirecto(
    totalMateriales: _totalMaterialesActual,
    totalManoObra: _totalManoObraActual,
    totalEquipos: _totalEquiposActual,
  );

  Map<String, double> get _resultadosActuales =>
      _calculadoraFinanzas.calcularTodo(
        totalMateriales: _totalMaterialesActual,
        totalManoObra: _totalManoObraActual,
        totalEquipos: _totalEquiposActual,
        finanzas: _finanzas,
      );

  void _seleccionarImprevistos(double valor) {
    setState(() {
      _finanzas.porcentajeImprevistos = valor;
      _imprevistosModoOtro = false;
    });
    _programarAutoguardado();
  }

  void _activarImprevistosOtro() {
    setState(() => _imprevistosModoOtro = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focoImprevistosOtro.requestFocus(),
    );
  }

  void _cambiarImprevistosOtro(String texto) {
    final valor = MonedaUtils.aDouble(texto);
    setState(() {
      if (valor != null) _finanzas.porcentajeImprevistos = valor;
    });
    _programarAutoguardado();
  }

  void _seleccionarUtilidad(double valor) {
    setState(() {
      _finanzas.porcentajeUtilidad = valor;
      _utilidadModoOtro = false;
    });
    _programarAutoguardado();
  }

  void _activarUtilidadOtro() {
    setState(() => _utilidadModoOtro = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focoUtilidadOtro.requestFocus(),
    );
  }

  void _cambiarUtilidadOtro(String texto) {
    final valor = MonedaUtils.aDouble(texto);
    setState(() {
      if (valor != null) _finanzas.porcentajeUtilidad = valor;
    });
    _programarAutoguardado();
  }

  void _elegirIVA(bool aplicar) {
    setState(() => _finanzas.aplicarIVA = aplicar);
    _programarAutoguardado();
  }

  // ================== MATERIALES ==================

  Future<void> _abrirAgregarMaterial() async {
    final resultado = await Navigator.push<MaterialPresupuesto>(
      context,
      MaterialPageRoute(builder: (context) => const AgregarMaterialScreen()),
    );
    if (resultado == null) return;
    await _materialesService.agregarMaterialPresupuesto(resultado);
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
  }

  Future<void> _abrirEditarMaterial(MaterialPresupuesto material) async {
    final resultado = await Navigator.push<MaterialPresupuesto>(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarMaterialScreen(materialEditando: material),
      ),
    );
    if (resultado == null) return;
    await _materialesService.actualizarMaterialPresupuesto(resultado);
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
  }

  Future<void> _abrirCatalogo() async {
    final resultado = await Navigator.push<MaterialPresupuesto>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                CatalogoMaterialesScreen(materialesService: _materialesService),
      ),
    );
    if (resultado == null) return;
    await _materialesService.agregarMaterialPresupuesto(resultado);
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
  }

  Future<void> _eliminarMaterial(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar material'),
            content: const Text('¿Seguro que quieres eliminar este material?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
    if (confirmar != true) return;
    await _materialesService.eliminarMaterialPresupuesto(id);
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
  }

  // ================== EQUIPOS ==================

  Future<void> _abrirAgregarEquipo() async {
    final resultado = await Navigator.push<Equipo>(
      context,
      MaterialPageRoute(builder: (context) => const AgregarEquipoScreen()),
    );
    if (resultado == null) return;
    await _equiposService.agregarEquipo(resultado);
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
  }

  Future<void> _abrirEditarEquipo(Equipo equipo) async {
    final resultado = await Navigator.push<Equipo>(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarEquipoScreen(equipoEditando: equipo),
      ),
    );
    if (resultado == null) return;
    await _equiposService.actualizarEquipo(resultado);
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
  }

  Future<void> _eliminarEquipo(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar equipo'),
            content: const Text('¿Seguro que quieres eliminar este equipo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
    if (confirmar != true) return;
    await _equiposService.eliminarEquipo(id);
    if (!mounted) return;
    setState(() {});
    _programarAutoguardado();
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaCreacion,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fechaCreacion && mounted) {
      setState(() => _fechaCreacion = picked);
      _programarAutoguardado();
    }
  }

  // ================== GUARDADO FINAL ==================

  Future<void> _guardarPresupuesto() async {
    setState(() => _guardando = true);
    try {
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
        totalEquipos: equipos.fold<double>(0, (sum, item) => sum + item.total),
        finanzas: _finanzas,
      );

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
                ? 'Actualizamos tu presupuesto'
                : 'Guardamos tu presupuesto',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(presupuesto);
    } catch (e) {
      print('Error al guardar presupuesto: $e');
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos guardar tu presupuesto. Intenta de nuevo.'),
        ),
      );
    }
  }

  // ================== BUILD ==================

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pasos = _pasos;
    final pasoActual = pasos[_pasoIndex];
    final esResumen = pasoActual == _PasoId.resumen;
    final totalPreguntas = pasos.length - 1;

    return PopScope(
      canPop: !_hayCambiosSinGuardar,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final salir = await _confirmarSalida();
        if (salir && mounted) Navigator.of(context).pop();
      },
      child: PreguntaScaffold(
        numero: esResumen ? null : _pasoIndex + 1,
        total: totalPreguntas,
        pregunta: _preguntaDe(pasoActual),
        ayuda: _ayudaDe(pasoActual),
        onAtras: _atras,
        onSiguiente: _puedeAvanzar(pasoActual) ? _siguiente : null,
        onCerrar: _intentarSalir,
        cargando: _guardando,
        textoSiguiente: _textoSiguienteDe(pasoActual),
        contenido: _contenidoDe(pasoActual),
      ),
    );
  }

  String _textoSiguienteDe(_PasoId paso) {
    if (paso == _PasoId.resumen) {
      return _esEdicion ? 'Actualizar presupuesto' : 'Guardar presupuesto';
    }
    return 'Siguiente';
  }

  String _preguntaDe(_PasoId paso) {
    switch (paso) {
      case _PasoId.titulo:
        return '¿Cómo quieres llamar a este presupuesto?';
      case _PasoId.tamano:
        return '¿De qué tamaño es la obra?';
      case _PasoId.materiales:
        return '¿Qué materiales vas a usar?';
      case _PasoId.tieneManoObra:
        return '¿Vas a pagar mano de obra en este trabajo?';
      case _PasoId.tipoPago:
        return '¿Cómo le vas a pagar a tu gente?';
      case _PasoId.rol:
        return '¿Qué tipo de trabajo van a hacer?';
      case _PasoId.cantidadPersonas:
        return '¿Cuántas personas van a trabajar?';
      case _PasoId.diasEstimados:
        return '¿Cuántos días van a trabajar?';
      case _PasoId.costoPorDia:
        return '¿Cuánto le vas a pagar a cada persona por día?';
      case _PasoId.montoContrato:
        return '¿Cuánto va a costar toda la mano de obra?';
      case _PasoId.observaciones:
        return '¿Quieres anotar algo sobre este trabajo?';
      case _PasoId.equipos:
        return '¿Vas a rentar o usar equipo para esta obra?';
      case _PasoId.imprevistos:
        return '¿Cuánto dinero extra quieres guardar por si algo sale mal?';
      case _PasoId.utilidad:
        return '¿Cuánto quieres ganar en este trabajo?';
      case _PasoId.iva:
        return '¿El cliente necesita factura?';
      case _PasoId.resumen:
        return 'Revisa tu presupuesto';
    }
  }

  String? _ayudaDe(_PasoId paso) {
    switch (paso) {
      case _PasoId.titulo:
        return 'Ejemplo: "Remodelación baño Sra. García" o "Casa calle Reforma #45".';
      case _PasoId.tamano:
        return 'Se mide en metros cuadrados (m²). Si no lo sabes, puedes saltarte esta pregunta.';
      case _PasoId.materiales:
        return 'Agrega cada material que necesites comprar, como cemento, arena o pintura. Si no vas a comprar materiales, toca Siguiente.';
      case _PasoId.tieneManoObra:
        return 'Si vas a hacer todo tú mismo, o el precio de los materiales ya incluye la instalación, elige No.';
      case _PasoId.tipoPago:
        return 'Elige "Por día" si les pagas cada jornada que trabajan. Elige "Por contrato" si ya acordaste un precio fijo por todo el trabajo.';
      case _PasoId.rol:
        return 'Ejemplo: Albañil, plomero, ayudante. Si no sabes, déjalo así y se llamará "Personal".';
      case _PasoId.cantidadPersonas:
        return 'Ejemplo: si trabajan 2 albañiles, escribe 2.';
      case _PasoId.diasEstimados:
        return 'Ejemplo: si el trabajo dura 10 días, escribe 10.';
      case _PasoId.costoPorDia:
        return 'Ejemplo: si le pagas \$350 al día a cada persona, escribe 350.';
      case _PasoId.montoContrato:
        return 'El precio total que acordaste, sin importar cuántos días tome.';
      case _PasoId.observaciones:
        return 'Ejemplo: "Incluye materiales" o el nombre del contratista. Puedes dejarlo en blanco.';
      case _PasoId.equipos:
        return 'Ejemplo: andamios, mezcladora, grúa. Si no necesitas equipo, toca Siguiente.';
      case _PasoId.imprevistos:
        return 'Lo normal es 5%. Si dejas 5%, guardas \$500 de cada \$10,000.';
      case _PasoId.utilidad:
        return 'Es tu pago por hacer el trabajo, después de cubrir materiales, mano de obra y el dinero extra.';
      case _PasoId.iva:
        return 'Si pide factura, se suma el 16% de IVA.';
      case _PasoId.resumen:
        return 'Toca cualquier renglón si quieres corregirlo.';
    }
  }

  Widget _contenidoDe(_PasoId paso) {
    switch (paso) {
      case _PasoId.titulo:
        return _pasoTitulo();
      case _PasoId.tamano:
        return _pasoTamano();
      case _PasoId.materiales:
        return _pasoMateriales();
      case _PasoId.tieneManoObra:
        return _pasoTieneManoObra();
      case _PasoId.tipoPago:
        return _pasoTipoPago();
      case _PasoId.rol:
        return _pasoRol();
      case _PasoId.cantidadPersonas:
        return _pasoCantidadPersonas();
      case _PasoId.diasEstimados:
        return _pasoDiasEstimados();
      case _PasoId.costoPorDia:
        return _pasoCostoPorDia();
      case _PasoId.montoContrato:
        return _pasoMontoContrato();
      case _PasoId.observaciones:
        return _pasoObservaciones();
      case _PasoId.equipos:
        return _pasoEquipos();
      case _PasoId.imprevistos:
        return _pasoImprevistos();
      case _PasoId.utilidad:
        return _pasoUtilidad();
      case _PasoId.iva:
        return _pasoIva();
      case _PasoId.resumen:
        return _pasoResumen();
    }
  }

  // ---------- Contenido: información básica ----------

  Widget _pasoTitulo() {
    return CampoValidado(
      fieldKey: _campoTituloKey,
      focusNode: _focoTitulo,
      controller: _tituloController,
      textInputAction: TextInputAction.done,
      autofocus: true,
      style: const TextStyle(fontSize: 20),
      maxLength: _maxTituloPresupuesto,
      decoration: InputDecoration(
        hintText: 'Ej: Remodelación baño Sra. García',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator:
          (value) => Validadores.requerido(
            value,
            campo: 'un título',
            maximo: _maxTituloPresupuesto,
          ),
    );
  }

  Widget _pasoTamano() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoValidado(
            fieldKey: _campoSuperficieKey,
            focusNode: _focoSuperficie,
            controller: _superficieController,
            textInputAction: TextInputAction.done,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              hintText: 'Ej: 90',
              suffixText: 'm²',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return null;
              final superficie = MonedaUtils.aDouble(raw);
              if (superficie == null)
                return 'Escribe un número, por ejemplo 90';
              if (superficie < 0) return 'El tamaño no puede ser negativo';
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                _superficieController.clear();
                _siguiente();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.gray300, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'No sé todavía',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          OpcionesAvanzadas(
            titulo: 'Fecha y estado del presupuesto (opcional)',
            children: [
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
                      minimumSize: const Size(48, 48),
                    ),
                    child: const Text('Cambiar'),
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
                    EstadoPresupuesto.values
                        .map(
                          (estado) => DropdownMenuItem(
                            value: estado,
                            child: Text(estado.toString().split('.').last),
                          ),
                        )
                        .toList(),
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

  // ---------- Contenido: materiales ----------

  Widget _pasoMateriales() {
    final materiales = _materialesService.obtenerMaterialesPresupuesto();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _abrirAgregarMaterial,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar material'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellowPrimary,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _abrirCatalogo,
                icon: const Icon(Icons.library_books),
                label: const Text('Catálogo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.black,
                  side: const BorderSide(color: AppColors.gray300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              materiales.isEmpty
                  ? _estadoVacio(
                    icono: Icons.inventory_2_outlined,
                    texto:
                        'Todavía no agregas materiales. Toca el botón para agregar el primero.',
                  )
                  : ListView.separated(
                    itemCount: materiales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final m = materiales[index];
                      return _tarjetaItem(
                        titulo: m.nombre,
                        subtitulo:
                            '${_formatearCantidad(m.cantidad)} ${m.unidad} × ${MonedaUtils.formatear(m.precioUnitario)}',
                        total: m.total,
                        onEditar: () => _abrirEditarMaterial(m),
                        onEliminar: () => _eliminarMaterial(m.id),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // ---------- Contenido: mano de obra ----------

  Widget _pasoTieneManoObra() {
    return SiNoGrande(valor: _tieneManoObra, onCambiar: _elegirTieneManoObra);
  }

  void _elegirTieneManoObra(bool valor) {
    setState(() => _tieneManoObra = valor);
    _actualizarManoObra();
  }

  Widget _pasoTipoPago() {
    return Column(
      children: [
        OpcionGrande(
          titulo: 'Por día trabajado',
          subtitulo: 'Les pagas cada jornada que trabajan',
          icono: Icons.calendar_today,
          seleccionada: _tipoPago == TipoPago.porDia,
          onTap: () => _elegirTipoPago(TipoPago.porDia),
        ),
        const SizedBox(height: 14),
        OpcionGrande(
          titulo: 'Por contrato',
          subtitulo: 'Ya acordaron un precio fijo por todo el trabajo',
          icono: Icons.assignment_turned_in_outlined,
          seleccionada: _tipoPago == TipoPago.porContrato,
          onTap: () => _elegirTipoPago(TipoPago.porContrato),
        ),
      ],
    );
  }

  void _elegirTipoPago(TipoPago valor) {
    setState(() => _tipoPago = valor);
    _actualizarManoObra();
  }

  Widget _pasoRol() {
    return TextField(
      controller: _rolController,
      focusNode: _focoRol,
      autofocus: true,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        hintText: 'Ej: Albañil (opcional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onChanged: (_) => _actualizarManoObra(),
    );
  }

  Widget _pasoCantidadPersonas() {
    return CampoValidado(
      fieldKey: _campoCantidadKey,
      focusNode: _focoCantidad,
      controller: _cantidadController,
      textInputAction: TextInputAction.done,
      autofocus: true,
      style: const TextStyle(fontSize: 20),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: 'Ej: 2',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator:
          (value) => Validadores.enteroPositivo(
            value,
            campo: 'la cantidad de personas',
          ),
      onChanged: (_) => _actualizarManoObra(),
    );
  }

  Widget _pasoDiasEstimados() {
    return CampoValidado(
      fieldKey: _campoDiasKey,
      focusNode: _focoDias,
      controller: _diasController,
      textInputAction: TextInputAction.done,
      autofocus: true,
      style: const TextStyle(fontSize: 20),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: 'Ej: 10',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator:
          (value) =>
              Validadores.enteroPositivo(value, campo: 'los días estimados'),
      onChanged: (_) => _actualizarManoObra(),
    );
  }

  Widget _pasoCostoPorDia() {
    final personas = int.tryParse(_cantidadController.text) ?? 0;
    final dias = int.tryParse(_diasController.text) ?? 0;
    final costo = MonedaInputFormatter.valorDe(_costoPorDiaController.text);
    final total = personas * dias * costo;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoValidado(
            fieldKey: _campoCostoPorDiaKey,
            focusNode: _focoCostoPorDia,
            controller: _costoPorDiaController,
            textInputAction: TextInputAction.done,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [MonedaInputFormatter()],
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Ej: 350.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator:
                (value) => Validadores.numeroPositivo(
                  value,
                  campo: 'el costo por día',
                ),
            onChanged: (value) {
              setState(() {
                _costoPorDiaSospechoso = Validadores.esSospechosamenteAlto(
                  MonedaInputFormatter.valorDe(value),
                );
              });
              _actualizarManoObra();
            },
          ),
          AdvertenciaMontoAlto(visible: _costoPorDiaSospechoso),
          if (personas > 0 && dias > 0) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$personas personas × $dias días × ${MonedaUtils.formatear(costo)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    MonedaUtils.formatear(total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pasoMontoContrato() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoValidado(
            fieldKey: _campoMontoContratoKey,
            focusNode: _focoMontoContrato,
            controller: _montoContratoController,
            textInputAction: TextInputAction.done,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [MonedaInputFormatter()],
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Ej: 15,000.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator:
                (value) => Validadores.numeroPositivo(
                  value,
                  campo: 'el monto del contrato',
                ),
            onChanged: (value) {
              setState(() {
                _montoContratoSospechoso = Validadores.esSospechosamenteAlto(
                  MonedaInputFormatter.valorDe(value),
                );
              });
              _actualizarManoObra();
            },
          ),
          AdvertenciaMontoAlto(visible: _montoContratoSospechoso),
        ],
      ),
    );
  }

  Widget _pasoObservaciones() {
    return TextField(
      controller: _observacionesController,
      focusNode: _focoObservaciones,
      autofocus: true,
      maxLines: 4,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        hintText: 'Ej: Incluye materiales (opcional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
      ),
      onChanged: (value) {
        _observaciones = value.trim().isEmpty ? null : value.trim();
        _actualizarManoObra();
      },
    );
  }

  // ---------- Contenido: equipos ----------

  Widget _pasoEquipos() {
    final equipos = _equiposService.obtenerEquipos();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _abrirAgregarEquipo,
            icon: const Icon(Icons.add),
            label: const Text('Agregar equipo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellowPrimary,
              foregroundColor: AppColors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              equipos.isEmpty
                  ? _estadoVacio(
                    icono: Icons.construction_outlined,
                    texto:
                        'Todavía no agregas equipos. Toca el botón para agregar el primero.',
                  )
                  : ListView.separated(
                    itemCount: equipos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final e = equipos[index];
                      return _tarjetaItem(
                        titulo: e.nombre,
                        subtitulo:
                            '${e.dias} días × ${MonedaUtils.formatear(e.costoPorDia)}/día',
                        total: e.total,
                        onEditar: () => _abrirEditarEquipo(e),
                        onEliminar: () => _eliminarEquipo(e.id),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // ---------- Contenido: finanzas ----------

  Widget _pasoImprevistos() {
    return SelectorPorcentaje(
      valoresComunes: _valoresImprevistos,
      valorSeleccionado: _finanzas.porcentajeImprevistos,
      modoOtro: _imprevistosModoOtro,
      controladorOtro: _imprevistosOtroController,
      focoOtro: _focoImprevistosOtro,
      base: _costoDirectoActual,
      onSeleccionarComun: _seleccionarImprevistos,
      onActivarOtro: _activarImprevistosOtro,
      onCambiarOtro: _cambiarImprevistosOtro,
    );
  }

  Widget _pasoUtilidad() {
    final base = _resultadosActuales['subtotal'] ?? 0;
    return SelectorPorcentaje(
      valoresComunes: _valoresUtilidad,
      valorSeleccionado: _finanzas.porcentajeUtilidad,
      modoOtro: _utilidadModoOtro,
      controladorOtro: _utilidadOtroController,
      focoOtro: _focoUtilidadOtro,
      base: base,
      onSeleccionarComun: _seleccionarUtilidad,
      onActivarOtro: _activarUtilidadOtro,
      onCambiarOtro: _cambiarUtilidadOtro,
    );
  }

  Widget _pasoIva() {
    return SiNoGrande(valor: _finanzas.aplicarIVA, onCambiar: _elegirIVA);
  }

  // ---------- Contenido: resumen ----------

  Widget _pasoResumen() {
    final resultados = _resultadosActuales;
    final imprevistosPct = _finanzas.porcentajeImprevistos;
    final utilidadPct = _finanzas.porcentajeUtilidad;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_titulo.isNotEmpty) ...[
            Text(
              _titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          _filaResumen(
            'Materiales',
            _totalMaterialesActual,
            onTap: () => _irASeccion(_PasoId.materiales),
          ),
          _filaResumen(
            _manoObra == null ? 'Mano de obra (sin agregar)' : 'Mano de obra',
            _totalManoObraActual,
            onTap: () => _irASeccion(_PasoId.tieneManoObra),
          ),
          _filaResumen(
            'Equipos',
            _totalEquiposActual,
            onTap: () => _irASeccion(_PasoId.equipos),
          ),
          _filaResumen(
            'Dinero extra (${_formatearPorcentaje(imprevistosPct)}%)',
            resultados['imprevistos'] ?? 0,
            onTap: () => _irASeccion(_PasoId.imprevistos),
          ),
          _filaResumen(
            'Tu ganancia (${_formatearPorcentaje(utilidadPct)}%)',
            resultados['utilidad'] ?? 0,
            onTap: () => _irASeccion(_PasoId.utilidad),
          ),
          if (_finanzas.aplicarIVA)
            _filaResumen(
              'IVA (16%)',
              resultados['iva'] ?? 0,
              onTap: () => _irASeccion(_PasoId.iva),
            ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.yellowSoft,
              border: Border.all(color: AppColors.yellowDark, width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  MonedaUtils.formatear(resultados['totalFinal'] ?? 0),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatearPorcentaje(double valor) {
    return valor % 1 == 0 ? valor.toStringAsFixed(0) : valor.toStringAsFixed(1);
  }

  Widget _filaResumen(String etiqueta, double monto, {VoidCallback? onTap}) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(etiqueta, style: const TextStyle(fontSize: 16)),
              ),
              Text(
                MonedaUtils.formatear(monto),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.gray500,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Widgets compartidos de listas ----------

  String _formatearCantidad(double valor) {
    if (valor == valor.roundToDouble()) return valor.toStringAsFixed(0);
    return valor.toString();
  }

  Widget _estadoVacio({required IconData icono, required String texto}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: AppColors.gray500),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.gray700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaItem({
    required String titulo,
    required String subtitulo,
    required double total,
    required VoidCallback onEditar,
    required VoidCallback onEliminar,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  MonedaUtils.formatear(total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditar,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.black,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: onEliminar,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}
