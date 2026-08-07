import 'package:presupuesto_app/core/utils/moneda_utils.dart';

/// Validadores reutilizables para los formularios de la app. Todos
/// devuelven un mensaje de error accionable en español (qué pasó y cómo
/// arreglarlo) o `null` si el valor es válido.
abstract final class Validadores {
  static String? requerido(
    String? value, {
    required String campo,
    int? maximo,
  }) {
    final texto = (value ?? '').trim();
    if (texto.isEmpty) {
      return 'Ingresa $campo';
    }
    if (maximo != null && texto.length > maximo) {
      return '$campo no puede superar $maximo caracteres';
    }
    return null;
  }

  static String? numeroPositivo(
    String? value, {
    required String campo,
    bool permitirCero = false,
  }) {
    final texto = (value ?? '').trim();
    if (texto.isEmpty) {
      return 'Ingresa $campo';
    }
    final numero = MonedaUtils.aDouble(texto);
    if (numero == null) {
      return 'Escribe solo números aquí';
    }
    if (permitirCero ? numero < 0 : numero <= 0) {
      return permitirCero
          ? '$campo no puede ser negativo'
          : 'Escribe un número mayor a cero';
    }
    return null;
  }

  static String? enteroPositivo(String? value, {required String campo}) {
    final texto = (value ?? '').trim();
    if (texto.isEmpty) {
      return 'Ingresa $campo';
    }
    final numero = int.tryParse(texto);
    if (numero == null) {
      return 'Ingresa un número entero válido en $campo';
    }
    if (numero <= 0) {
      return 'Escribe un número mayor a cero';
    }
    return null;
  }

  static String? porcentaje(String? value, {required String campo}) {
    final texto = (value ?? '').trim();
    if (texto.isEmpty) {
      return 'Ingresa $campo';
    }
    final numero = MonedaUtils.aDouble(texto);
    if (numero == null) {
      return 'Ingresa un número válido en $campo';
    }
    if (numero < 0 || numero > 100) {
      return '$campo debe estar entre 0 y 100';
    }
    return null;
  }

  /// `true` si el valor es tan alto que probablemente sea un error de
  /// dedo (ej. un material a \$99,999,999). Se usa solo para mostrar una
  /// advertencia visible — NUNCA para bloquear el guardado.
  static bool esSospechosamenteAlto(double valor, {double umbral = 99999999}) {
    return valor > umbral;
  }
}
