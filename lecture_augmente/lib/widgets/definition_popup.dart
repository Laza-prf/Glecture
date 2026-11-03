import 'package:flutter/material.dart';
import '../services/dictionary_service.dart';

class DefinitionPopup extends StatefulWidget {
  final String word;
  const DefinitionPopup({super.key, required this.word});

  @override
  State<DefinitionPopup> createState() => _DefinitionPopupState();
}

class _DefinitionPopupState extends State<DefinitionPopup> {
  final DictionaryService _service = DictionaryService();
  String? _definition;
  bool _isLoading = true;
  bool _estUneErreur = false;

  // Mots-clés simples permettant de distinguer une vraie définition
  // d'un message d'erreur renvoyé par le backend (quota, API indisponible...).
  static const _motsErreur = ['introuvable', 'erreur', 'trop de définitions'];

  @override
  void initState() {
    super.initState();
    _fetchDefinition();
  }

  Future<void> _fetchDefinition() async {
    setState(() {
      _isLoading = true;
      _estUneErreur = false;
    });

    final def = await _service.getDefinition(widget.word);

    if (mounted) {
      final texteMinuscule = def.toLowerCase();
      setState(() {
        _definition = def;
        _estUneErreur = _motsErreur.any((mot) => texteMinuscule.contains(mot));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.word,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              if (_estUneErreur && !_isLoading)
                Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Text(
              _definition ?? 'Définition non trouvée',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: _estUneErreur ? Colors.red.shade400 : null,
              ),
            ),
          if (_estUneErreur && !_isLoading) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _fetchDefinition,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}