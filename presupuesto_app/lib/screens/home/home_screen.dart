import 'package:flutter/material.dart';
import 'package:presupuesto_app/screens/settings/settings_screen.dart';
import 'package:presupuesto_app/screens/presupuesto/presupuesto_screen.dart';
import 'package:presupuesto_app/screens/proyectos/proyectos_screens.dart';
import 'package:presupuesto_app/screens/presupuesto/new_presupuesto_scrren.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lógica simple para el número de proyectos activos
  int _activeProjects = 5; // Número de proyectos activos (puedes cambiarlo dinámicamente)

  final List<Widget> _screens = [
    const Center(child: Text('Que onda ')),
    const PresupuestoScreen(),
    const ProyectosScreens(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Hola bienvenido'
              : _currentIndex == 1
                  ? 'Presupuestos'
                  : _currentIndex == 2
                      ? 'Proyectos'
                      : 'Configuraciones',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: Column(
        children: [
          if (_currentIndex == 0) // Mostrar las tarjetas solo en la pantalla de inicio
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoCard(
                    title: 'Proyectos Activos',
                    value: '$_activeProjects',
                    color: Colors.blue,
                  ),
                  _InfoCard(
                    title: 'Próximamente',
                    value: '...',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewPresupuestoScrren()),
          );
        },
        backgroundColor: Colors.white, //color del boton
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xFFE5E5E5)), //borde del boton
        ),
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 7, 255, 11),
        ), //color del icono del boton
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6, //espacio entre el boton y el bottom app bar
        color: Colors.white, //color del bottom app bar
        clipBehavior:
            Clip.antiAlias, //para que el boton se vea bien con el bottom app bar
        elevation: 6, //sobra del bottom app bar
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: '',
                index: 0,
                currentIndex: _currentIndex,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.wallet,
                label: '',
                index: 1,
                currentIndex: _currentIndex,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.folder,
                label: '',
                index: 2,
                currentIndex: _currentIndex,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.settings,
                label: '',
                index: 3,
                currentIndex: _currentIndex,
                onTap: () => setState(() => _currentIndex = 3),
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
