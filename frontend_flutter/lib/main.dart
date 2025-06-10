import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Mejora: incluir el parámetro `Key`

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Digital Agenda')), // Mejora: usar `const`
        body: const Center(
          child: Text('Hola a tu agenda digital desde el frontend!'), // Mejora: usar `const`
        ),
      ),
    );
  }
}

