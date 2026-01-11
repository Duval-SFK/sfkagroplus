import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "fa3aab9b98525070e400beaba1659418";

  Future<Map<String, dynamic>?> fetchWeather(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=fr",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
