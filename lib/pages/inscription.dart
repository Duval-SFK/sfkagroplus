import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  int _currentStep = 0;

  // Contrôleurs des champs
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _cultureController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _localisationController = TextEditingController();

  // Pour validation des étapes
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_formKeys[_currentStep].currentState!.validate()) {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              // Dernière étape → soumission
              _submitForm();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          } else {
            Navigator.pop(context);
          }
        },

        controlsBuilder: (BuildContext context, ControlsDetails details) {
          // On vérifie si on est à la dernière étape (Confirmation)
          final bool isLastStep = _currentStep == 2;

          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLastStep ? "S'inscrire" : 'Continuer'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(isLastStep ? 'Annuler' : 'Retour'),
                ),
              ],
            ),
          );
        },

        steps: [
          // Étape 1 : infos personnelles
          Step(
            title: const Text("Informations personnelles"),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKeys[0],
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(labelText: "Nom complet"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre nom";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre email";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Email invalide";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre mot de passe";
                      }
                      if (value.length < 6) {
                        return "Le mot de passe doit contenir au moins 6 caractères";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          // Étape 2 : infos agricoles
          Step(
            title: const Text("Informations agricoles"),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKeys[1],
              child: Column(
                children: [
                  TextFormField(
                    controller: _cultureController,
                    decoration: const InputDecoration(
                      labelText: "Type de culture (ex: maïs, tomates)",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Veuillez entrer votre culture" : null,
                  ),
                  TextFormField(
                    controller: _surfaceController,
                    decoration: const InputDecoration(
                      labelText: "Superficie du champ (en mètres carrés)",
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer la superficie";
                      }
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return "Veuillez entrer un nombre valide";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _localisationController,
                    decoration: const InputDecoration(
                      labelText: "Localisation de votre champ",
                    ),
                    validator: (value) => value!.isEmpty
                        ? "Veuillez entrer la localisation"
                        : null,
                  ),
                ],
              ),
            ),
          ),

          // Étape 3 : confirmation
          Step(
            title: const Text("Confirmation"),
            isActive: _currentStep >= 2,
            content: Form(
              key: _formKeys[2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationText("Nom : ", _nomController.text),
                  _buildConfirmationText("Email : ", _emailController.text),
                  _buildConfirmationText("Culture : ", _cultureController.text),
                  _buildConfirmationText("Superficie en m² : ", _surfaceController.text),
                  _buildConfirmationText("Localisation : ", _localisationController.text),
                  const SizedBox(height: 10),
                  const Text("Si tout est correct, cliquez sur 'S'inscrire'"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKeys[_currentStep].currentState!.validate()) return;

    // rassembler les valeurs
    final name = _nomController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final culture = _cultureController.text.trim();
    final surface = _surfaceController.text.trim();
    final location = _localisationController.text.trim();

    // afficher loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await AuthService.registerUser(
        name: name,
        email: email,
        password: password,
        culture: culture,
        surface: surface,
        location: location,
      );

      // fermer loader
      Navigator.of(context).pop();

      // l'utilisateur est automatiquement connecté par Firebase -> on redirige
      Navigator.pushReplacementNamed(context, '/chatbot');
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inscription : $e')),
      );
    }
  }
}

