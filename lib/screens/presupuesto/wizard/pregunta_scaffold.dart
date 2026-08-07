import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';

/// Layout compartido por cada pantalla del flujo "una pregunta por
/// pantalla": encabezado con el número de pregunta, la pregunta en letra
/// grande, una línea de ayuda con un ejemplo, el contenido específico de
/// esa pregunta y, fijos abajo (siempre visibles por encima del teclado),
/// los botones Atrás/Siguiente.
///
/// [numero] y [total] son 1-based. Si [numero] es `null` (pantalla de
/// resumen final, que no es "una pregunta más") no se muestra el contador.
class PreguntaScaffold extends StatelessWidget {
  final int? numero;
  final int total;
  final String pregunta;
  final String? ayuda;
  final Widget contenido;
  final VoidCallback? onAtras;
  final VoidCallback? onSiguiente;
  final String textoSiguiente;
  final bool cargando;
  final VoidCallback? onCerrar;

  const PreguntaScaffold({
    super.key,
    required this.numero,
    required this.total,
    required this.pregunta,
    this.ayuda,
    required this.contenido,
    required this.onAtras,
    required this.onSiguiente,
    this.textoSiguiente = 'Siguiente',
    this.cargando = false,
    this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        leading:
            onCerrar == null
                ? null
                : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Salir',
                  onPressed: onCerrar,
                ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (numero != null)
                Text(
                  'Pregunta $numero de $total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                pregunta,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  height: 1.2,
                ),
              ),
              if (ayuda != null) ...[
                const SizedBox(height: 8),
                Text(
                  ayuda!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.gray700,
                    height: 1.3,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Expanded(child: contenido),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Material(
        color: AppColors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                if (onAtras != null) ...[
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: cargando ? null : onAtras,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.black,
                          side: const BorderSide(
                            color: AppColors.gray300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Atrás',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: cargando ? null : onSiguiente,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellowPrimary,
                        disabledBackgroundColor: AppColors.gray300,
                        foregroundColor: AppColors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          cargando
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.black,
                                  ),
                                ),
                              )
                              : Text(
                                textoSiguiente,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
