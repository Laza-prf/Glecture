import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthResult {
  final String token;
  final String nom;
  final String email;
  final int id;
  AuthResult({required this.token, required this.nom, required this.email, required this.id});
}

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api/auth';

  Future<AuthResult> inscription({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/inscription'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nom': nom, 'email': email, 'motDePasse': motDePasse}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) {
      return AuthResult(
        token: data['token'],
        nom: data['utilisateur']['nom'],
        email: data['utilisateur']['email'],
        id: data['utilisateur']['id'],
      );
    }
    throw Exception(data['erreur'] ?? 'Erreur lors de l\'inscription');
  }

  Future<AuthResult> connexion({required String email, required String motDePasse}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/connexion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'motDePasse': motDePasse}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return AuthResult(
        token: data['token'],
        nom: data['utilisateur']['nom'],
        email: data['utilisateur']['email'],
        id: data['utilisateur']['id'],
      );
    }
    throw Exception(data['erreur'] ?? 'Identifiants incorrects');
  }
}