import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/annotation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<List<Book>> getLivres() async {
    final res = await http.get(Uri.parse('$baseUrl/livres'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Book.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du chargement des livres');
  }

  Future<BookDetail> getLivreDetail(String livreId) async {
    final res = await http.get(Uri.parse('$baseUrl/livres/$livreId'));
    if (res.statusCode == 200) {
      return BookDetail.fromJson(jsonDecode(res.body));
    }
    throw Exception('Erreur lors du chargement du livre');
  }

  Future<Chapter> getChapitre(String chapitreId) async {
    final res = await http.get(Uri.parse('$baseUrl/livres/chapitre/$chapitreId'));
    if (res.statusCode == 200) {
      return Chapter.fromJson(jsonDecode(res.body));
    }
    throw Exception('Erreur lors du chargement du chapitre');
  }

  Future<List<Annotation>> getAnnotations(String chapitreId) async {
    final res = await http.get(Uri.parse('$baseUrl/annotations/$chapitreId'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Annotation.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du chargement des annotations');
  }

  Future<void> uploadLivre({
    required String titre,
    String? auteur,
    required String filePath,
    required String fileName,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/livres/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['titre'] = titre;
    if (auteur != null && auteur.isNotEmpty) request.fields['auteur'] = auteur;
    request.files.add(await http.MultipartFile.fromPath('fichier', filePath, filename: fileName));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['erreur'] ?? 'Erreur lors de l\'upload du livre');
    }
  }

  // Nouvelle méthode ajoutée pour la suppression
  Future<void> deleteLivre(String bookId, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/livres/$bookId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      final data = jsonDecode(res.body);
      throw Exception(data['erreur'] ?? 'Erreur lors de la suppression du livre');
    }
  }
}