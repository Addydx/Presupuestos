import 'package:flutter/material.dart';

/// Paleta industrial centralizada. Ningún widget debe usar un [Color]
/// literal: todos consumen estos tokens o el [ColorScheme] derivado de ellos.
///
/// Regla crítica: el amarillo es SUPERFICIE (botones, chips, progreso,
/// paso activo), nunca texto/ícono sobre fondo claro. Siempre se combina
/// con texto/íconos en [AppColors.black], nunca en blanco.
abstract final class AppColors {
  // Amarillo industrial (acento/marca)
  static const Color yellowPrimary = Color(0xFFFFC300);
  static const Color yellowDark = Color(0xFFD9A400); // hover/pressed
  static const Color yellowSoft = Color(0xFFFFF3CC); // fondos sutiles, badges

  // Negros y grises
  static const Color black = Color(0xFF101010); // superficies oscuras, appbar
  static const Color gray900 = Color(0xFF1E1E1E);
  static const Color gray700 = Color(0xFF3D3D3D); // texto secundario en claro
  static const Color gray500 = Color(0xFF757575);
  static const Color gray300 = Color(0xFFD6D6D6); // bordes, divisores
  static const Color gray100 = Color(0xFFF2F2F2); // fondo de tarjetas/inputs
  static const Color white = Color(0xFFFFFFFF);

  // Semánticos (fondo sólido). Contraste de texto verificado (ver tabla WCAG):
  // success/error/info -> texto white; warning -> texto black.
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  /// Color de texto/ícono legible (WCAG AA) sobre una superficie semántica sólida.
  static Color onSemantic(Color semantic) {
    return semantic == warning ? black : white;
  }
}
