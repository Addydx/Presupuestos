import 'package:flutter/material.dart';
import 'package:presupuesto_app/screens/settings/settings_screen.dart';
import 'package:presupuesto_app/screens/proyectos/proyectos_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lógica simple para el número de proyectos activos
  int _activeProjects =
      5; // Número de proyectos activos (puedes cambiarlo dinámicamente)

  final List<Widget> _screens = [
    const Center(child: Text('Que onda ')),
    const ProyectosScreens(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Inicio'
              : _currentIndex == 1
              ? 'Proyectos'
              : 'Configuraciones',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4682B4), Color(0xFF2E5F8A)],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        toolbarHeight: 64,
        actions: [
          if (_currentIndex ==
              3) // Mostrar un botón de ayuda solo en Configuraciones
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                // Acción del botón de ayuda
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Ayuda'),
                        content: const Text(
                          'Aquí puedes configurar tu aplicación.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_currentIndex ==
              0) // Mostrar las tarjetas solo en la pantalla de inicio
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoCard(
                    title: 'Proyectos Activos',
                    value: '$_activeProjects',
                    color: const Color(0xFF4682B4), // Azul acero
                  ),
                  _InfoCard(
                    title: 'Próximamente',
                    value: '...',
                    color: const Color(0xFF228B22), // Verde progreso
                  ),
                ],
              ),
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6, // Espacio entre el botón y el bottom app bar
        color: const Color(0xFF4682B4), // Azul acero
        clipBehavior:
            Clip.antiAlias, // Para que el botón se vea bien con el bottom app bar
        elevation: 6, // Sombra del bottom app bar
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Inicio',
                index: 0,
                currentIndex: _currentIndex,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.folder,
                label: 'Proyectos',
                index: 1,
                currentIndex: _currentIndex,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.settings,
                label: 'Configuración',
                index: 2,
                currentIndex: _currentIndex,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = index == currentIndex ? Colors.blue : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
