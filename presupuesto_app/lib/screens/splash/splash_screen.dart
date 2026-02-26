import 'package:flutter/material.dart';
import 'dart:async';

import 'package:presupuesto_app/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    //esto es para ejecutar el codigo cuando se inicia la pantalla
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    //esto es para simular una carga de datos o alguna tarea que se deba realizar antes de mostrar la pantalla principal
    //en este casom mostrar gif de carga por 3 segundos
    await Future.delayed(Duration(seconds: 3));

    //despues de la carga, navegar a la pantala principal
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    //esto es para construir la pantalla de carga, en este caso un gif de carga centrado
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/images/loading.gif',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
