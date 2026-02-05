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
          _currentIndex == 0 ? 'Hola bienvenido' : _currentIndex == 1 ? 'Presupuestos' : _currentIndex == 2 ? 'Proyectos' : 'Configuraciones',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: _screens[_currentIndex],
      floatingActionButtonLocation: 
          FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewPresupuestoScrren(),
                )
              );
            },
            backgroundColor: Colors.white,//color del boton
            elevation: 0,
            highlightElevation: 0,
            shape: const CircleBorder(
              side: BorderSide(color: Color( 0xFFE5E5E5)),//borde del boton
            ),
            child: const Icon(Icons.add, color: Colors.amber,),//icono del boton y su color del boton
            ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),//esto es para hacer un notch en el bottom app bar
        notchMargin: 6,//esto sirve para darle un margen al notch
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        elevation: 6,//esto es para darle una sombra al bottom app bar 
      )
    );
  }
}
