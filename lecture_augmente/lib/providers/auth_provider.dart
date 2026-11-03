import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  String? token;
  String? nom;
  String? email;
  bool isLoading = true;

  bool get isLoggedIn => token != null;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    nom = prefs.getString('nom');
    email = prefs.getString('email');
    isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('token', token!);
    if (nom != null) await prefs.setString('nom', nom!);
    if (email != null) await prefs.setString('email', email!);
  }

  Future<void> connexion(String email, String motDePasse) async {
    final result = await _service.connexion(email: email, motDePasse: motDePasse);
    token = result.token;
    nom = result.nom;
    this.email = result.email;
    await _persist();
    notifyListeners();
  }

  Future<void> inscription(String nom, String email, String motDePasse) async {
    final result = await _service.inscription(nom: nom, email: email, motDePasse: motDePasse);
    token = result.token;
    this.nom = result.nom;
    this.email = result.email;
    await _persist();
    notifyListeners();
  }

  Future<void> deconnexion() async {
    token = null;
    nom = null;
    email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}