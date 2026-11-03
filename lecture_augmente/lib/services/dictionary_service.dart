import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  // Adapte l'adresse selon où tourne l'app :
  //   - Linux desktop (flutter run -d linux)      -> http://localhost:5000/api/definitions
  //   - Émulateur Android (flutter run -d emulator-5554) -> http://10.0.2.2:5000/api/definitions
  //   - Vrai téléphone Android (même WiFi que le PC)      -> http://IP_DU_PC:5000/api/definitions
  static const String baseUrl = 'http://localhost:5000/api/definitions';

  Future<String> getDefinition(String word) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/${Uri.encodeComponent(word)}'));
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data['definition'] ?? 'Définition non trouvée';
      }

      // Affiche le vrai message renvoyé par le backend (quota dépassé,
      // erreur Gemini, etc.) au lieu d'un texte générique qui cache la cause.
      return data['erreur'] ?? 'Définition introuvable pour "$word"';
    } catch (e) {
      return 'Erreur lors de la récupération de la définition';
    }
  }
}