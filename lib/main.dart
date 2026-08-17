import 'package:autoleitura/autoleiturascreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AutoLeituraApp());
}

class AutoLeituraApp extends StatelessWidget {
  const AutoLeituraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Leitura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: const AutoLeituraScreen(),
    );
  }
}
