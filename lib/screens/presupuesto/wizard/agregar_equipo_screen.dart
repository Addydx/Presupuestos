import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/advertencia_monto_alto.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard/pregunta_scaffold.dart';

/// Mini-flujo de "una pregunta por pantalla" para agregar o editar un
/// equipo rentado del presupuesto: nombre, días, costo por día. Al
/// terminar, hace `Navigator.pop` con el [Equipo] resultante; quien lo
/// llama es responsable de guardarlo en el servicio.
class AgregarEquipoScreen extends StatefulWidget {
  final Equipo? equipoEditando;

  const AgregarEquipoScreen({super.key, this.equipoEditando});

  @override
  State<AgregarEquipoScreen> createState() => _AgregarEquipoScreenState();
}

class _AgregarEquipoScreenState extends State<AgregarEquipoScreen> {
  static const int _totalPasos = 3;
  int _paso = 0;

  final _nombreController = TextEditingController();
  final _diasController = TextEditingController();
  final _costoPorDiaController = TextEditingController();

  final _focoNombre = FocusNode();
  final _focoDias = FocusNode();
  final _focoCostoPorDia = FocusNode();

  final _keyNombre = GlobalKey<FormFieldState<String>>();
  final _keyDias = GlobalKey<FormFieldState<String>>();
  final _keyCostoPorDia = GlobalKey<FormFieldState<String>>();

  bool _costoSospechoso = false;

  @override
  void initState() {
    super.initState();
    final e = widget.equipoEditando;
    if (e != null) {
      _nombreController.text = e.nombre;
      _diasController.text = e.dias.toString();
      _costoPorDiaController.text = MonedaInputFormatter.textoInicial(
        e.costoPorDia,
      );
    } else {
      _diasController.text = '1';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enfocarPasoActual();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _diasController.dispose();
    _costoPorDiaController.dispose();
    _focoNombre.dispose();
    _focoDias.dispose();
    _focoCostoPorDia.dispose();
    super.dispose();
  }

  void _enfocarPasoActual() {
    switch (_paso) {
      case 0:
        _focoNombre.requestFocus();
      case 1:
        _focoDias.requestFocus();
      case 2:
        _focoCostoPorDia.requestFocus();
    }
  }

  int get _diasValor => int.tryParse(_diasController.text.trim()) ?? 0;
  double get _costoValor =>
      MonedaInputFormatter.valorDe(_costoPorDiaController.text);
  double get _totalCalculado => _diasValor * _costoValor;

  bool get _puedeAvanzar {
    switch (_paso) {
      case 0:
        return _nombreController.text.trim().isNotEmpty;
      case 1:
        return Validadores.enteroPositivo(
              _diasController.text,
              campo: 'los días',
            ) ==
            null;
      case 2:
        return Validadores.numeroPositivo(
              _costoPorDiaController.text,
              campo: 'el costo',
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
    if (_paso == _totalPasos - 1) {
      _guardar();
      return;
    }
    setState(() => _paso++);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enfocarPasoActual());
  }

  void _guardar() {
    final nombre = _nombreController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final equipo = Equipo(
      id: widget.equipoEditando?.id,
      nombre: nombre,
      dias: _diasValor,
      costoPorDia: _costoValor,
    );
    Navigator.of(context).pop(equipo);
  }

  @override
  Widget build(BuildContext context) {
    return PreguntaScaffold(
      numero: _paso + 1,
      total: _totalPasos,
      pregunta: _pregunta,
      ayuda: _ayuda,
      onAtras: _atras,
      onSiguiente: _puedeAvanzar ? _siguiente : null,
      onCerrar: () => Navigator.of(context).pop(),
      textoSiguiente: _paso == _totalPasos - 1 ? 'Guardar equipo' : 'Siguiente',
      contenido: _contenido,
    );
  }

  String get _pregunta {
    switch (_paso) {
      case 0:
        return '¿Qué equipo vas a usar?';
      case 1:
        return '¿Cuántos días lo vas a usar?';
      case 2:
        return '¿Cuánto cuesta por día?';
    }
    return '';
  }

  String? get _ayuda {
    switch (_paso) {
      case 0:
        return 'Ejemplo: Andamio, mezcladora, grúa.';
      case 1:
        return 'Ejemplo: si lo vas a usar 5 días, escribe 5.';
      case 2:
        final nombre = _nombreController.text.trim();
        return 'Lo que cuesta rentarlo un solo día.'
            '${nombre.isEmpty ? '' : ' ($nombre)'}';
    }
    return null;
  }

  Widget get _contenido {
    switch (_paso) {
      case 0:
        return _pasoNombre();
      case 1:
        return _pasoDias();
      case 2:
        return _pasoCosto();
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
        hintText: 'Ej: Andamio',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      maxLength: 80,
      validator:
          (v) => Validadores.requerido(
            v,
            campo: 'el nombre del equipo',
            maximo: 80,
          ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _pasoDias() {
    return CampoValidado(
      fieldKey: _keyDias,
      focusNode: _focoDias,
      controller: _diasController,
      textInputAction: TextInputAction.done,
      autofocus: true,
      style: const TextStyle(fontSize: 20),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: 'Ej: 5',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (v) => Validadores.enteroPositivo(v, campo: 'los días'),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _pasoCosto() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoValidado(
            fieldKey: _keyCostoPorDia,
            focusNode: _focoCostoPorDia,
            controller: _costoPorDiaController,
            textInputAction: TextInputAction.done,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [MonedaInputFormatter()],
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Ej: 500.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator:
                (v) => Validadores.numeroPositivo(v, campo: 'el costo por día'),
            onChanged: (v) {
              setState(() {
                _costoSospechoso = Validadores.esSospechosamenteAlto(
                  MonedaInputFormatter.valorDe(v),
                );
              });
            },
          ),
          AdvertenciaMontoAlto(visible: _costoSospechoso),
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
                  'Total de este equipo',
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
