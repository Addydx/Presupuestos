import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/services/equipos_service.dart';
import 'package:presupuesto_app/services/materiales_service.dart';
import 'package:presupuesto_app/services/presupuestos_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final bool _darkModeEnabled = false;
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'), elevation: 0),
      body: Container(
        color: AppColors.gray100,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Sección de perfil
            _buildProfileSection(context),
            const SizedBox(height: 24),
            // Sección de preferencias
            _buildPreferencesSection(context),
            const SizedBox(height: 24),
            // Sección de información
            _buildInformationSection(context),
            const SizedBox(height: 24),
            // Sección de peligro
            _buildDangerSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perfil',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.yellowPrimary, AppColors.yellowDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellowDark.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 40, color: AppColors.black),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Usuario Presupuesto App',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.gray700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Preferencias',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          // Moneda
          _buildSettingTile(
            context,
            icon: Icons.currency_exchange_outlined,
            title: 'Moneda por defecto',
            subtitle: _selectedCurrency,
            onTap: () => _showCurrencyDialog(context),
          ),
          const Divider(height: 1, indent: 56),
          // Modo oscuro
          _buildSettingTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Modo oscuro',
            subtitle: 'Próximamente',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: null,
              activeThumbColor: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Información',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            context,
            icon: Icons.info_outlined,
            title: 'Acerca de',
            subtitle: 'Información de la aplicación',
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'Ayuda',
            subtitle: 'Contacto y soporte',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDangerSection(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Peligro',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            context,
            icon: Icons.delete_outline,
            title: 'Eliminar todos los datos',
            subtitle: 'Esta acción no se puede deshacer',
            titleColor: AppColors.error,
            onTap: () => _showDeleteConfirmDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: titleColor ?? AppColors.black, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: titleColor ?? AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray700),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.gray300,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Seleccionar Moneda'),
            content: SingleChildScrollView(
              child: RadioGroup<String>(
                groupValue: _selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value ?? 'USD';
                  });
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      ['USD', 'EUR', 'COP', 'MXN', 'ARS', 'CLP']
                          .map(
                            (currency) => RadioListTile<String>(
                              title: Text(currency),
                              value: currency,
                              activeColor: AppColors.black,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Acerca de'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Presupuesto App'),
                SizedBox(height: 8),
                Text(
                  'Aplicación profesional para la gestión de presupuestos en proyectos de construcción.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  'Versión: 1.0.0',
                  style: TextStyle(fontSize: 12, color: AppColors.gray700),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Eliminar todos los datos'),
            content: const Text(
              'Esta acción eliminará permanentemente todos tus proyectos y presupuestos. '
              '¿Estás seguro de que deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await _eliminarTodosLosDatos();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _eliminarTodosLosDatos() async {
    try {
      final presupuestosService = PresupuestosService();
      await presupuestosService.limpiarTodos();

      final proyectosBox = Hive.box<Proyecto>('proyectos');
      await proyectosBox.clear();

      await MaterialesService().limpiarMaterialesPresupuesto();
      await EquiposService().limpiarEquipos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos eliminados correctamente'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar datos: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
