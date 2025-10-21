import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReMarket',
      debugShowCheckedModeBanner: false, // Opcional: quita la cinta de "Debug"
      theme: ThemeData(
        // Habilitamos Material 3
        useMaterial3: true,
        // Usamos un color base, Material 3 generará el resto de la paleta
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),

        // Definimos el estilo de las tarjetas globalmente
        cardTheme: CardThemeData(
          elevation: 2,
          // Bordes redondeados consistentes con tu app de Kotlin
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          // Usamos un color de superficie más sutil
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),

        // Estilo de la barra de navegación
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0, // Quitamos la sombra para un look más M3
          scrolledUnderElevation: 4, // Sombra al hacer scroll
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(
            color: Colors.black87,
          ),
        ),

        // Estilo para los campos de texto
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
          ),
        ),

        // Estilo de los botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}