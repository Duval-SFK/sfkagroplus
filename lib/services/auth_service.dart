import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl =
      'http://localhost:3000'; // URL de votre backend local
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<void> signOut() async {
    await storage.delete(key: 'jwt_token');
  }

  static Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
    required String culture,
    required String surface,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'culture': culture,
        'surface': surface,
        'location': location,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Méthode pour vérifier le token (stockez-le localement)
  static bool isTokenValid(String token) {
    return !JwtDecoder.isExpired(token);
  }

  static Future<void> saveSession({
    required String uid,
    required String token,
  }) async {
    await storage.write(key: 'uid', value: uid);
    await storage.write(key: 'jwt_token', value: token);
  }

  // Récupérer le profil utilisateur
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = await storage.read(key: 'uid');
    final token = await storage.read(key: 'jwt_token');

    if (uid == null || token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user/$uid'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      await signOut();
      return null;
    }
  }

  // Récupérer les champs agricoles de l'utilisateur
  static Future<List<dynamic>?> getUserFields() async {
    final uid = await storage.read(key: 'uid');
    final token = await storage.read(key: 'jwt_token');

    if (uid == null || token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user/$uid/fields'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Récupérer les analyses TFLite de l'utilisateur
  static Future<List<dynamic>?> getUserAnalyses(
    String uid,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$uid/analyses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
