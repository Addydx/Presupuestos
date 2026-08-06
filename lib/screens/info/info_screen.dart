import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información'), elevation: 0),
      body: Container(
        decoration: const BoxDecoration(color: AppColors.gray100),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gray900, AppColors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.home_repair_service,
                    color: AppColors.white,
                    size: 40,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Presupuesto App',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Aplicación enfocada en crear presupuestos claros, rápidos y ordenados para trabajos de construcción.',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _InfoCard(
              title: '¿Para quién es esta app?',
              icon: Icons.groups_2_outlined,
              content:
                  'Si eres constructor, contratista, maestro de obra o albañil, esta página es para ti. La aplicación te ayuda a organizar materiales, mano de obra, equipos y costos finales en un solo presupuesto.',
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: '¿Qué puedes hacer?',
              icon: Icons.checklist_rtl_outlined,
              content:
                  'Puedes crear proyectos, registrar presupuestos, calcular materiales, capturar mano de obra, agregar equipos rentados, aplicar utilidad, imprevistos e IVA, y luego revisar el resumen final de forma ordenada.',
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Objetivo',
              icon: Icons.track_changes_outlined,
              content:
                  'Reducir errores al cotizar trabajos de construcción y facilitar que cada presupuesto quede guardado, editable y listo para presentarse al cliente.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.yellowSoft,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: Icon(icon, color: AppColors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
