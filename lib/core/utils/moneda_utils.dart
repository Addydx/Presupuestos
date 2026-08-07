import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formato de moneda mexicana (es_MX): separador de miles con coma,
/// 2 decimales, símbolo de peso.
///
/// Toda la UI debe mostrar montos con [MonedaUtils.formatear] en vez de
/// interpolar `\$` + `toStringAsFixed(2)` a mano, para que el formato sea
/// consistente en toda la app.
abstract final class MonedaUtils {
  static final NumberFormat _formato = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formatea un monto para mostrarlo, ej. 12345.6 -> "\$12,345.60".
  static String formatear(double valor) => _formato.format(valor);

  /// Convierte texto escrito por el usuario a double. Acepta tanto punto
  /// como coma decimal y normaliza internamente. Devuelve null si el
  /// texto no representa un número válido.
  static double? aDouble(String texto) {
    var limpio = texto.replaceAll(RegExp(r'[^\d.,-]'), '').trim();
    if (limpio.isEmpty) return null;

    if (limpio.contains(',') && limpio.contains('.')) {
      // El separador que aparece al final es el decimal; el otro es de miles.
      final ultimaComa = limpio.lastIndexOf(',');
      final ultimoPunto = limpio.lastIndexOf('.');
      if (ultimaComa > ultimoPunto) {
        limpio = limpio.replaceAll('.', '').replaceAll(',', '.');
      } else {
        limpio = limpio.replaceAll(',', '');
      }
    } else if (limpio.contains(',')) {
      limpio = limpio.replaceAll(',', '.');
    }

    return double.tryParse(limpio);
  }
}

/// [TextInputFormatter] para campos de monto en pesos: formatea en vivo con
/// separador de miles y 2 decimales mientras el usuario escribe dígitos
/// (los últimos 2 dígitos son siempre los centavos, estilo "caja
/// registradora"). Este enfoque evita saltos de cursor al insertar
/// separadores de miles en medio del texto.
class MonedaInputFormatter extends TextInputFormatter {
  const MonedaInputFormatter();

  static final NumberFormat _formatoSinSimbolo =
      NumberFormat.decimalPattern('es_MX')
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 2;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitos.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final centavos = int.parse(digitos);
    final valor = centavos / 100;
    final texto = _formatoSinSimbolo.format(valor);

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  /// Extrae el valor numérico de un texto ya formateado por este formatter.
  static double valorDe(String textoFormateado) {
    final digitos = textoFormateado.replaceAll(RegExp(r'[^\d]'), '');
    if (digitos.isEmpty) return 0;
    return int.parse(digitos) / 100;
  }

  /// Texto inicial formateado para precargar un campo con un valor existente.
  static String textoInicial(double valor) {
    if (valor <= 0) return '';
    return _formatoSinSimbolo.format(valor);
  }
}
