class Chapter {
  final String id;
  final String livreId;
  final int numero;
  final String titre;
  final String contenu;

  Chapter({
    required this.id,
    required this.livreId,
    required this.numero,
    required this.titre,
    required this.contenu,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'].toString(),
      livreId: json['livre_id'].toString(),
      numero: json['numero'] ?? 0,
      titre: json['titre'] ?? '',
      contenu: json['contenu'] ?? '',
    );
  }
}