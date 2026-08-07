import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';

/// Aviso no bloqueante para montos que probablemente sean un error de
/// dedo (ej. un material a \$99,999,999). Solo advierte, nunca impide
/// guardar.
class AdvertenciaMontoAlto extends StatelessWidget {
  final bool visible;
  final String mensaje;

  const AdvertenciaMontoAlto({
    super.key,
    required this.visible,
    this.mensaje = 'Este monto parece muy alto. Verifica que sea correcto.',
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
