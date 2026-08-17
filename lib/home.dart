import 'package:autoleitura/login.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //centerTitle: true,
      //title: const Text('TESTE API BANCO - INÍCIO'),
      //backgroundColor:
      //  Color.fromARGB(255, 0, 0, 0), // Manter a app bar no azul
      //),
      backgroundColor: const Color.fromARGB(255, 217, 230, 247),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/seja_bem_vindo.png',
              width: 200,
              height: 200,
            ),
            Material(
              color: const Color.fromARGB(255, 15, 76, 129), // Azul mais claro
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "Clique para inserir seu código",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
