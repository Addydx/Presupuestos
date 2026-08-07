import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';

/// Tarjeta grande y tocable para elegir entre pocas opciones, en vez de un
/// dropdown. Seleccionada = fondo amarillo + texto/ícono negro (regla de
/// contraste de [AppColors]); no seleccionada = fondo blanco con borde
/// gris.
class OpcionGrande extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData? icono;
  final bool seleccionada;
  final VoidCallback onTap;

  const OpcionGrande({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.icono,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionada ? AppColors.yellowPrimary : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: seleccionada ? AppColors.yellowDark : AppColors.gray300,
              width: seleccionada ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              if (icono != null) ...[
                Icon(icono, color: AppColors.black, size: 28),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitulo!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (seleccionada)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.black,
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dos botones grandes de Sí/No, en vez de un [Switch] — más claro para
/// alguien sin experiencia con apps.
class SiNoGrande extends StatelessWidget {
  final bool? valor;
  final ValueChanged<bool> onCambiar;
  final String textoSi;
  final String textoNo;

  const SiNoGrande({
    super.key,
    required this.valor,
    required this.onCambiar,
    this.textoSi = 'Sí',
    this.textoNo = 'No',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BotonSiNo(
            texto: textoSi,
            seleccionado: valor == true,
            onTap: () => onCambiar(true),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _BotonSiNo(
            texto: textoNo,
            seleccionado: valor == false,
            onTap: () => onCambiar(false),
          ),
        ),
      ],
    );
  }
}

class _BotonSiNo extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  const _BotonSiNo({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado ? AppColors.yellowPrimary : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: seleccionado ? AppColors.yellowDark : AppColors.gray300,
              width: seleccionado ? 2 : 1.5,
            ),
          ),
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
