import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> labels = [];

  // Modifier taille d'entrée
  final int inputSize = 128;
  final int numChannels = 3;

  Future<void> loadModel({String modelPath = 'assets/model.tflite', String labelsPath = 'assets/labels.txt'}) async {
    // Charger le .tflite depuis les assets
    final modelData = await rootBundle.load(modelPath);
    final modelBytes = modelData.buffer.asUint8List();
    _interpreter = Interpreter.fromBuffer(modelBytes);

    // Charger les labels
    final rawLabels = await rootBundle.loadString(labelsPath);
    labels = rawLabels.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    print('TFLite model loaded, labels: ${labels.length}');
  }

  /// Prétraite l'image (File) pour correspondre à l'entrée du modèle:
  /// - decode,
  /// - resize (inputSize x inputSize),
  /// - normalise en float32 [0..1],
  /// - construit un input 4D : [1, inputSize, inputSize, 3]
  List<List<List<List<double>>>> _preprocess(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception("Impossible de décoder l'image");
    }

    // Convertir/exif orientation handled by `image` package automatically on many formats.
    final img.Image resized = img.copyResize(image, width: inputSize, height: inputSize);

    // Créer le tensor d'entrée : [1][H][W][C]
    final input = List.generate(1, (_) =>
        List.generate(inputSize, (_) =>
            List.generate(inputSize, (_) =>
                List.filled(numChannels, 0.0)
            )
        )
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);

        // Normaliser en 0..1
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return input;
  }

  /// Exécute le modèle sur une image File et retourne la liste (label, score) triée par score descendant.
  Future<List<Map<String, dynamic>>> predict(File image) async {
    if (_interpreter == null) {
      throw Exception('Interpreter not loaded. Call loadModel() first.');
    }

    // Prétraiter
    final input = _preprocess(image);

    // Préparer le buffer de sortie: [1, numClasses]
    final numClasses = labels.length;
    final output = List.generate(1, (_) => List.filled(numClasses, 0.0));

    // Lancer l'inférence
    _interpreter!.run(input, output);

    // output[0] contient les probabilités pour chaque classe
    final List<double> scores = List<double>.from(output[0]);

    // Construire list (label,score)
    final results = <Map<String, dynamic>>[];
    for (int i = 0; i < numClasses; i++) {
      results.add({
        'label': labels[i],
        'score': scores[i],
      });
    }

    // Trier par score décroissant et renvoyer top3
    results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return results.take(3).toList();
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
