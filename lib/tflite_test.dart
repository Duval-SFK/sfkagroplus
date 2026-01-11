import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/tflite_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();
  final TFLiteService _service = TFLiteService();

  File? _image;
  List<Map<String, dynamic>>? _predictions;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _service.loadModel();
    setState(() => _modelLoaded = true);
  }

  Future<void> _pickImage() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return;
    final file = File(picked.path);

    setState(() {
      _image = file;
      _predictions = null;
    });

    final preds = await _service.predict(file);
    setState(() => _predictions = preds);
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SFKAgro+ — Test TFLite')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_modelLoaded) CircularProgressIndicator(),
              if (_modelLoaded)
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Prendre une photo'),
                ),
              SizedBox(height: 16),
              if (_image != null)
                Image.file(_image!, width: 200, height: 200, fit: BoxFit.cover),
              SizedBox(height: 16),
              if (_predictions != null)
                ..._predictions!.map(
                  (p) => Text(
                    "${p['label']} : ${(p['score'] * 100).toStringAsFixed(1)}%",
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
