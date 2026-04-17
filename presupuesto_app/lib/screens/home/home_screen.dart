import 'package:flutter/material.dart';
import 'package:presupuesto_app/screens/info/info_screen.dart';
import 'package:presupuesto_app/screens/proyectos/proyectos_screens.dart';
import 'package:presupuesto_app/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; //esto sirve para saber el index de la pantalla actual

  final List<Widget> _screens = const [
    ProyectosScreens(),
    InfoScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? Icons.work : Icons.work_outline),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.info : Icons.info_outline,
            ),
            label: 'Información',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.settings : Icons.settings_outlined,
            ),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
