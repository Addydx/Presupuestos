import 'package:flutter/material.dart';
import 'package:presupuesto_app/screens/proyectos/proyectos_screens.dart';
import 'package:presupuesto_app/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; //esto sirve para saber el index de la pantalla actual

  final List<Widget> _screens = const [ProyectosScreens(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //scafold es un widget que nos permite crear una estructura basica de una pantalla
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, //esto es para saber el index actual
        onTap: (index) {
          setState(() {
            _currentIndex = index; //esto es para cambiar el index actual
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'configuración',
          ),
        ],
      ),
    );
  }
}
