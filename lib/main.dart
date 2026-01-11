import 'package:flutter/material.dart';
import 'pages/connexion.dart';
import 'pages/inscription.dart';
import 'pages/chatbot.dart';
import 'pages/profil.dart';
import 'pages/parametres.dart';

void main() async {
  runApp(const SFKAgroApp());
}

class SFKAgroApp extends StatelessWidget {
  const SFKAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFKAgro+',
      debugShowCheckedModeBanner: false,

      themeMode: ThemeMode.system, // Light/dark auto selon le téléphone
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green.shade700,
        scaffoldBackgroundColor: Colors.grey.shade100,
        colorScheme: ColorScheme.light(
          primary: Colors.green.shade700,
          secondary: Colors.amber.shade600, // or
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green.shade500,
        scaffoldBackgroundColor: Colors.grey.shade900,
        colorScheme: ColorScheme.dark(
          primary: Colors.green.shade500,
          secondary: Colors.amber.shade400,
        ),
      ),
      routes: {
        '/connexion': (context) => const ConnexionPage(),
        '/inscription': (context) => const InscriptionPage(),
        '/chatbot': (context) => const ChatbotPage(),
        '/profil': (context) => const ProfilPage(),
        '/parametres': (context) => const ParametresPage(),
      },
    );
  }
}
