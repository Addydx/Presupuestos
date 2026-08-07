import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';

/// Selector de porcentaje mediante botones grandes con los valores más
/// comunes + un botón "Otro" que abre un campo. El usuario nunca escribe
/// un porcentaje a mano salvo que elija "Otro". Siempre muestra el
/// resultado en pesos en vivo debajo (el usuario entiende pesos, no
/// porcentajes).
///
/// Todo el estado (qué botón está activo, el texto de "Otro") lo posee el
/// llamador — este widget es de exhibición pura para que el wizard pueda
/// restaurarlo desde un borrador sin duplicar lógica de estado.
class SelectorPorcentaje extends StatelessWidget {
  final List<double> valoresComunes;
  final double? valorSeleccionado;
  final bool modoOtro;
  final TextEditingController controladorOtro;
  final FocusNode focoOtro;
  final double base;
  final ValueChanged<double> onSeleccionarComun;
  final VoidCallback onActivarOtro;
  final ValueChanged<String> onCambiarOtro;

  const SelectorPorcentaje({
    super.key,
    required this.valoresComunes,
    required this.valorSeleccionado,
    required this.modoOtro,
    required this.controladorOtro,
    required this.focoOtro,
    required this.base,
    required this.onSeleccionarComun,
    required this.onActivarOtro,
    required this.onCambiarOtro,
  });

  @override
  Widget build(BuildContext context) {
    final montoResultante =
        valorSeleccionado == null ? null : base * (valorSeleccionado! / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final valor in valoresComunes)
              _BotonPorcentaje(
                texto: '${valor.toStringAsFixed(0)}%',
                seleccionado: !modoOtro && valorSeleccionado == valor,
                onTap: () => onSeleccionarComun(valor),
              ),
            _BotonPorcentaje(
              texto: 'Otro',
              seleccionado: modoOtro,
              onTap: onActivarOtro,
            ),
          ],
        ),
        if (modoOtro) ...[
          const SizedBox(height: 16),
          TextField(
            controller: controladorOtro,
            focusNode: focoOtro,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              suffixText: '%',
              hintText: 'Ej: 8',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: onCambiarOtro,
          ),
        ],
        const SizedBox(height: 20),
        if (montoResultante != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${valorSeleccionado!.toStringAsFixed(valorSeleccionado! % 1 == 0 ? 0 : 1)}% = ${MonedaUtils.formatear(montoResultante)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
      ],
    );
  }
}

class _BotonPorcentaje extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  const _BotonPorcentaje({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado ? AppColors.yellowPrimary : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56, minWidth: 88),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado ? AppColors.yellowDark : AppColors.gray300,
              width: seleccionado ? 2 : 1.5,
            ),
          ),
          child: Text(
            texto,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
