import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  static const String wsUrl = 'ws://localhost:5000';

  void connect({
    String? token,
    required void Function(String texte) onResumeChunk,
    required void Function() onResumeTermine,
    void Function(String message)? onErreur,
  }) {
    final uri = token != null && token.isNotEmpty
        ? Uri.parse('$wsUrl?token=$token')
        : Uri.parse(wsUrl);

    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        switch (data['type']) {
          case 'resume_chunk':
            onResumeChunk(data['texte']);
            break;
          case 'resume_termine':
            onResumeTermine();
            break;
          case 'erreur':
            onErreur?.call(data['message'] ?? 'Erreur inconnue');
            break;
        }
      },
      onError: (error) => onErreur?.call('Erreur WebSocket : $error'),
    );
  }

  void demanderResume(String chapitreId, String contenu) {
    _channel?.sink.add(jsonEncode({
      'type': 'demander_resume',
      'chapitreId': chapitreId,
      'contenu': contenu,
    }));
  }

  void dispose() {
    _channel?.sink.close();
  }
}