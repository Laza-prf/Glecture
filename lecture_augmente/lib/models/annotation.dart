class Annotation {
  final String id;
  final String utilisateurId;
  final String chapitreId;
  final int positionDebut;
  final int positionFin;
  final String type; // ex: 'surlignage'
  final String? contenuNote;

  Annotation({
    required this.id,
    required this.utilisateurId,
    required this.chapitreId,
    required this.positionDebut,
    required this.positionFin,
    required this.type,
    this.contenuNote,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'].toString(),
      utilisateurId: json['utilisateur_id']?.toString() ?? json['utilisateurId']?.toString() ?? '',
      chapitreId: json['chapitre_id']?.toString() ?? json['chapitreId']?.toString() ?? '',
      positionDebut: json['position_debut'] ?? json['positionDebut'] ?? 0,
      positionFin: json['position_fin'] ?? json['positionFin'] ?? 0,
      type: json['type'] ?? 'surlignage',
      contenuNote: json['contenu_note'] ?? json['contenuNote'],
    );
  }
}