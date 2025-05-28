import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Digital Agenda')),
        body:
            Center(child: Text('Hola a tu agenda digital desde el frontend!')),
      ),
    );
  }
}
