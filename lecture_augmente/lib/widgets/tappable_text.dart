import 'package:flutter/material.dart';

/// Widget de lecture avec définition tactile.
///
/// Utilise SelectableText plutôt qu'un calcul manuel de position par pixels :
/// Flutter gère nativement et précisément la sélection de mot (double-tap ou
/// appui long), quels que soient la longueur du texte, le wrapping des
/// lignes, ou les réglages d'accessibilité (taille de police système).
///
/// Geste : double-tap (ou appui long + léger glissement) sur un mot pour
/// en afficher la définition.
class TappableText extends StatelessWidget {
  final String text;
  final void Function(String word) onWordTap;

  const TappableText({
    super.key,
    required this.text,
    required this.onWordTap,
  });

  void _handleSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    if (selection.isCollapsed) return;

    final debut = selection.start.clamp(0, text.length);
    final fin = selection.end.clamp(0, text.length);
    if (debut >= fin) return;

    final mot = text.substring(debut, fin).trim();
    if (mot.isEmpty) return;

    onWordTap(mot);
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: const TextStyle(fontSize: 17, height: 1.6),
      onSelectionChanged: _handleSelectionChanged,
    );
  }
}