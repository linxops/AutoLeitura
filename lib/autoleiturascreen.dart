import 'package:autoleitura/home.dart';
import 'package:flutter/material.dart';

class AutoLeituraScreen extends StatefulWidget {
  const AutoLeituraScreen({super.key});

  @override
  _AutoLeituraScreenState createState() => _AutoLeituraScreenState();
}

class _AutoLeituraScreenState extends State<AutoLeituraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 0.5).animate(_controller);

    _controller.forward().whenComplete(() {
      // Navegue para a próxima tela após a conclusão da animação
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Home(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(
        //title: const Text('Autoleitura'),
        //),
        backgroundColor: const Color.fromARGB(255, 217, 230, 247),
        body: Center(
          child: FadeTransition(
            opacity: _animation,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
