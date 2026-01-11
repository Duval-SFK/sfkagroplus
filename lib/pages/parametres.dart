import 'package:flutter/material.dart';

class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Paramètres')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Bienvenue sur SFKAgro+"),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inscription');
              },
              child: const Text("Aller à l'inscription"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chatbot');
              },
              child: const Text("Aller au Chatbot"),
            ),
          ],
        ),
      ),
    );
  }
}
