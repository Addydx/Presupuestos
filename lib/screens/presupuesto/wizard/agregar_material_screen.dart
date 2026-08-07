import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/advertencia_monto_alto.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard/pregunta_scaffold.dart';

const _unidadesComunes = ['pieza', 'kg', 'bulto', 'litro', 'm', 'm²', 'm³'];

/// Categoría interna asignada a los materiales que el usuario captura a
/// mano (no viene del catálogo). Es un dato de organización que solo se
/// usa internamente (agrupar por categoría en reportes futuros); no forma
/// parte de las preguntas que ve el maestro de obra.
const _categoriaMaterialLibre = 'General';

/// Mini-flujo de "una pregunta por pantalla" para agregar o editar un
/// material del presupuesto: nombre, cantidad + unidad, precio. Al
/// terminar, hace `Navigator.pop` con el [MaterialPresupuesto] resultante;
/// quien lo llama es responsable de guardarlo en el servicio.
class AgregarMaterialScreen extends StatefulWidget {
  final MaterialPresupuesto? materialEditando;

  const AgregarMaterialScreen({super.key, this.materialEditando});

  @override
  State<AgregarMaterialScreen> createState() => _AgregarMaterialScreenState();
}

class _AgregarMaterialScreenState extends State<AgregarMaterialScreen> {
  late int _paso;
  late final List<int> _pasosActivos;

  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioController = TextEditingController();

  final _focoNombre = FocusNode();
  final _focoCantidad = FocusNode();
  final _focoPrecio = FocusNode();
  final _focoUnidadOtro = FocusNode();

  final _keyNombre = GlobalKey<FormFieldState<String>>();
  final _keyCantidad = GlobalKey<FormFieldState<String>>();
  final _keyPrecio = GlobalKey<FormFieldState<String>>();

  String? _unidad;
  bool _unidadModoOtro = false;
  final _unidadOtroController = TextEditingController();
  bool _precioSospechoso = false;

  bool get _esEdicion => widget.materialEditando != null;
  bool get _esCatalogo =>
      _esEdicion && !widget.materialEditando!.esPersonalizado;

  @override
  void initState() {
    super.initState();
    // Un material que vino del catálogo mantiene nombre/unidad fijos: se
    // salta la pregunta de nombre y la de unidad (solo cantidad y precio).
    _pasosActivos = _esCatalogo ? [1, 2] : [0, 1, 2];
    _paso = 0;

    final m = widget.materialEditando;
    if (m != null) {
      _nombreController.text = m.nombre;
      _cantidadController.text = _formatearCantidad(m.cantidad);
      _precioController.text = MonedaInputFormatter.textoInicial(
        m.precioUnitario,
      );
      _unidad = m.unidad;
      _unidadModoOtro = !_unidadesComunes.contains(m.unidad);
      if (_unidadModoOtro) _unidadOtroController.text = m.unidad;
    } else {
      _cantidadController.text = '1';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enfocarPasoActual();
    });
  }

  String _formatearCantidad(double valor) {
    if (valor == valor.roundToDouble()) return valor.toStringAsFixed(0);
    return valor.toString();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _unidadOtroController.dispose();
    _focoNombre.dispose();
    _focoCantidad.dispose();
    _focoPrecio.dispose();
    _focoUnidadOtro.dispose();
    super.dispose();
  }

  void _enfocarPasoActual() {
    switch (_pasosActivos[_paso]) {
      case 0:
        _focoNombre.requestFocus();
      case 1:
        _focoCantidad.requestFocus();
      case 2:
        _focoPrecio.requestFocus();
    }
  }

  double get _cantidadValor =>
      MonedaUtils.aDouble(_cantidadController.text) ?? 0;
  double get _precioValor =>
      MonedaInputFormatter.valorDe(_precioController.text);
  double get _totalCalculado => _cantidadValor * _precioValor;

  bool get _cantidadValida =>
      Validadores.numeroPositivo(
        _cantidadController.text,
        campo: 'la cantidad',
      ) ==
      null;

  /// El usuario ya escribió una cantidad correcta pero todavía no toca
  /// ningún chip de unidad: sin este aviso, "Siguiente" se queda gris sin
  /// que se vea por qué.
  bool get _cantidadCompletaSinUnidad =>
      _cantidadValida && _unidad == null && !_unidadModoOtro;

  bool get _puedeAvanzar {
    switch (_pasosActivos[_paso]) {
      case 0:
        return _nombreController.text.trim().isNotEmpty;
      case 1:
        final unidadValida =
            _unidad != null ||
            (_unidadModoOtro && _unidadOtroController.text.trim().isNotEmpty);
        return _cantidadValida && unidadValida;
      case 2:
        return Validadores.numeroPositivo(
              _precioController.text,
              campo: 'el precio',
            ) ==
            null;
    }
    return false;
  }

  void _atras() {
    if (_paso == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _paso--);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enfocarPasoActual());
  }

  void _siguiente() {
    if (!_puedeAvanzar) return;
    if (_paso == _pasosActivos.length - 1) {
      _guardar();
      return;
    }
    setState(() => _paso++);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enfocarPasoActual());
  }

  void _guardar() {
    final unidadFinal =
        _unidadModoOtro
            ? _unidadOtroController.text.trim()
            : (_unidad ?? widget.materialEditando?.unidad ?? '');
    final nombre = _nombreController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final material = MaterialPresupuesto(
      id: widget.materialEditando?.id,
      nombre: _esCatalogo ? widget.materialEditando!.nombre : nombre,
      categoria: widget.materialEditando?.categoria ?? _categoriaMaterialLibre,
      unidad: unidadFinal,
      cantidad: _cantidadValor,
      precioUnitario: _precioValor,
      esPersonalizado: widget.materialEditando?.esPersonalizado ?? true,
      materialCatalogoId: widget.materialEditando?.materialCatalogoId,
    );
    Navigator.of(context).pop(material);
  }

  @override
  Widget build(BuildContext context) {
    final pasoId = _pasosActivos[_paso];
    return PreguntaScaffold(
      numero: _paso + 1,
      total: _pasosActivos.length,
      pregunta: _preguntaPara(pasoId),
      ayuda: _ayudaPara(pasoId),
      onAtras: _atras,
      onSiguiente: _puedeAvanzar ? _siguiente : null,
      onCerrar: () => Navigator.of(context).pop(),
      textoSiguiente:
          _paso == _pasosActivos.length - 1 ? 'Guardar material' : 'Siguiente',
      contenido: _contenidoPara(pasoId),
    );
  }

  String _preguntaPara(int pasoId) {
    switch (pasoId) {
      case 0:
        return '¿Qué material vas a agregar?';
      case 1:
        return '¿Cuánto vas a necesitar?';
      case 2:
        return '¿Cuánto cuesta cada unidad?';
    }
    return '';
  }

  String? _ayudaPara(int pasoId) {
    switch (pasoId) {
      case 0:
        return 'Ejemplo: Cemento, arena, pintura, ladrillo.';
      case 1:
        return 'Escribe la cantidad y toca la unidad. Ejemplo: 50 bultos de cemento.';
      case 2:
        final nombre =
            _esCatalogo
                ? widget.materialEditando!.nombre
                : _nombreController.text.trim();
        final unidad =
            _unidadModoOtro ? _unidadOtroController.text.trim() : _unidad;
        final referencia =
            unidad == null || unidad.isEmpty ? '' : ' por $unidad';
        return 'Precio de una sola unidad$referencia, no el total.'
            '${nombre.isEmpty ? '' : ' ($nombre)'}';
    }
    return null;
  }

  Widget _contenidoPara(int pasoId) {
    switch (pasoId) {
      case 0:
        return _pasoNombre();
      case 1:
        return _pasoCantidadUnidad();
      case 2:
        return _pasoPrecio();
    }
    return const SizedBox.shrink();
  }

  Widget _pasoNombre() {
    return CampoValidado(
      fieldKey: _keyNombre,
      focusNode: _focoNombre,
      controller: _nombreController,
      textInputAction: TextInputAction.done,
      autofocus: true,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        hintText: 'Ej: Cemento',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      maxLength: 60,
      validator:
          (v) => Validadores.requerido(v, campo: 'el nombre', maximo: 60),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _pasoCantidadUnidad() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoValidado(
            fieldKey: _keyCantidad,
            focusNode: _focoCantidad,
            controller: _cantidadController,
            textInputAction: TextInputAction.done,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              hintText: 'Ej: 50',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator:
                (v) => Validadores.numeroPositivo(v, campo: 'la cantidad'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          const Text(
            '¿En qué unidad?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final u in _unidadesComunes)
                _ChipUnidad(
                  texto: u,
                  seleccionado: !_unidadModoOtro && _unidad == u,
                  onTap: () {
                    setState(() {
                      _unidad = u;
                      _unidadModoOtro = false;
                    });
                  },
                ),
              _ChipUnidad(
                texto: 'Otro',
                seleccionado: _unidadModoOtro,
                onTap: () {
                  setState(() => _unidadModoOtro = true);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _focoUnidadOtro.requestFocus(),
                  );
                },
              ),
            ],
          ),
          if (_cantidadCompletaSinUnidad) ...[
            const SizedBox(height: 8),
            const Text(
              'Elige una unidad',
              style: TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ],
          if (_unidadModoOtro) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _unidadOtroController,
              focusNode: _focoUnidadOtro,
              decoration: InputDecoration(
                hintText: 'Ej: rollo, saco, caja',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pasoPrecio() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoValidado(
            fieldKey: _keyPrecio,
            focusNode: _focoPrecio,
            controller: _precioController,
            textInputAction: TextInputAction.done,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [MonedaInputFormatter()],
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Ej: 250.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (v) => Validadores.numeroPositivo(v, campo: 'el precio'),
            onChanged: (v) {
              setState(() {
                _precioSospechoso = Validadores.esSospechosamenteAlto(
                  MonedaInputFormatter.valorDe(v),
                );
              });
            },
          ),
          AdvertenciaMontoAlto(visible: _precioSospechoso),
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
                const Text(
                  'Total de este material',
                  style: TextStyle(fontSize: 13, color: AppColors.gray700),
                ),
                const SizedBox(height: 4),
                Text(
                  MonedaUtils.formatear(_totalCalculado),
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
      ),
    );
  }
}

class _ChipUnidad extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipUnidad({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado ? AppColors.yellowPrimary : AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: seleccionado ? AppColors.yellowDark : AppColors.gray300,
              width: seleccionado ? 2 : 1.5,
            ),
          ),
          child: Text(
            texto,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
