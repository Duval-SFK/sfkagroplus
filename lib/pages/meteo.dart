import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'meteo_service.dart';

class MeteoPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const MeteoPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _loading = true;
  String _error = '';
  String? _locationName;

  // Charger dès l’ouverture de la page
  @override
  void initState() {
    super.initState();
    _getWeatherForUserLocation();
  }

  /// Récupère la localisation du champ de l'utilisateur
  /// puis lance la récupération de la météo.
  Future<void> _getWeatherForUserLocation() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      // 3. Récupérer les données météo pour cette localisation
      final data = await _weatherService.fetchWeather(
        widget.latitude,
        widget.longitude,
      );

      setState(() {
        _weatherData = data;
        _locationName = widget.locationName;
      });
    } catch (e) {
      setState(() {
        _error = "Erreur : ${e.toString()}";
      });
      print(_error); // Pour le débogage
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Retourne une icône en fonction de la description météo
  IconData _getWeatherIcon(String description) {
    if (description.contains('Pluie')) return Icons.grain_rounded;
    if (description.contains('Nuage')) return Icons.cloud_outlined;
    if (description.contains('Soleil') || description.contains('clair')) {
      return Icons.wb_sunny_outlined;
    }
    if (description.contains('Orage')) return Icons.thunderstorm_outlined;
    if (description.contains('Neige')) return Icons.ac_unit_rounded;
    return Icons.wb_sunny_outlined; // Icône par défaut
  }

  /// Met la première lettre en majuscule
  String _capitalize(String text) {
    if (text.isEmpty) return "";
    return toBeginningOfSentenceCase(text) ?? text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Météo')),
      body: Container(
        // Fond en dégradé pour un look plus moderne
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.green.shade300],
          ),
        ),
        child: Center(child: _buildWeatherContent()),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_loading) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (_error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "Impossible de récupérer la météo.\n$_error",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    if (_weatherData == null) {
      return const Text(
        "Données météo non disponibles.",
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }

    final temp = _weatherData!['main']['temp'].toStringAsFixed(1);
    final description = _weatherData!['weather'][0]['description'];
    final humidity = _weatherData!['main']['humidity'];
    final windSpeed = _weatherData!['wind']['speed'];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nom de la ville
          Text(
            _locationName ?? 'Ma Météo',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Icône météo principale
          Icon(_getWeatherIcon(description), size: 100, color: Colors.white),
          const SizedBox(height: 10),

          // Température
          Text(
            "$temp°C",
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black26,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          // Description du temps
          Text(
            _capitalize(description),
            style: const TextStyle(fontSize: 22, color: Colors.white70),
          ),

          // Informations additionnelles (humidité et vent)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoColumn(
                Icons.water_drop_outlined,
                "Humidité",
                "$humidity%",
              ),
              _buildInfoColumn(Icons.air_rounded, "Vent", "$windSpeed m/s"),
            ],
          ),
        ],
      ),
    );
  }

  // Widget réutilisable pour afficher une information (icône, label, valeur)
  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
