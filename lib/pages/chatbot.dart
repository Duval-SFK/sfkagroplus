import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'meteo.dart';
import 'profil.dart';
import '../services/auth_service.dart';
import '../services/tflite_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  int _selectedIndex = 1; // 0 = Météo, 1 = Chatbot (par défaut), 2 = Profil

  // Liste des pages
  final List<Widget> _pages = [
    const ChatbotContent(), // contenu du chatbot
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _selectedIndex == 0
                ? "Météo"
                : _selectedIndex == 1
                ? "Chatbot"
                : "Profil",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Section aide à venir...")),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          if (index == 0) {
            final fields = await AuthService.getUserFields();

            if (!context.mounted || fields == null || fields.isEmpty) return;

            final field = fields[0];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MeteoPage(
                  latitude: double.parse(field['latitude'].toString()),
                  longitude: double.parse(field['longitude'].toString()),
                  locationName: field['name'],
                ),
              ),
            );
          } else if (index == 1) {
            //Page Chatbot
            setState(() {
              _selectedIndex == 1;
            });
          } else if (index == 2) {
            //Page Profil
            setState(() {
              _selectedIndex == 2;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Météo"),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chatbot",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}

class ChatbotContent extends StatefulWidget {
  const ChatbotContent({super.key});

  @override
  State<ChatbotContent> createState() => _ChatbotContentState();
}

class _ChatbotContentState extends State<ChatbotContent> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final TFLiteService _tfliteService = TFLiteService();

  File? _selectedImage;

  Future<void> _sendImageMessage(File imageFile, {String? text}) async {
    final _ = _controller.text.trim();
    //if (_controller.text.trim().isEmpty && _selectedImage == null) return;
    if (_controller.text.trim().isEmpty) {
      // Bloquer l’envoi si pas de texte
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ajoutez un texte avant d'envoyer une image")),
      );
      return;
    }

    setState(() {
      // Message de l'utilisateur
      _messages.add({
        "role": "user",
        "text": _controller.text.trim(),
        "image": _selectedImage,
      });
      _controller.clear();
      _selectedImage = null;
    });

    //Charger modèle
    await _tfliteService.loadModel();
    List<Map<String, dynamic>> prediction = await _tfliteService.predict(
      imageFile,
    );

    // Simuler une réponse de l'IA
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({
          "data": 0, // bot
          "message": "Résultat de l'analyse : $prediction",
          "image": null,
        });
      });
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _sendImageMessage(_selectedImage!, text: _controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Zone des messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg["role"] == "user";

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (msg["image"] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          msg["image"],
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (msg["text"].isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.green[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg["text"]),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // Zone de saisie + bouton caméra
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_camera, color: Colors.green),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo, color: Colors.green),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Poser une question",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () {
                      if (_selectedImage != null) {
                        _sendImageMessage(
                          _selectedImage!,
                          text: _controller.text,
                        );
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
