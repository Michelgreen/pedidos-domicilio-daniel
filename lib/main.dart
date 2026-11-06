import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'screens/home_screen.dart';

/// Punto de entrada principal de la aplicación móvil y web
/// Proyecto: Aplicación de Pedidos de Comida a Domicilio
/// Alumno: Daniel Michel Cruz Verde
/// Materia: Desarrollo Móvil Integral - Docente: Dolores Abril Sánchez Camacho
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase con el proyecto pedidos-domicilio-daniel
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PedidosDomicilioApp());
}

class PedidosDomicilioApp extends StatelessWidget {
  const PedidosDomicilioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CruzVerde Delivery - Pedidos a Domicilio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD84315),
          primary: const Color(0xFFD84315),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
