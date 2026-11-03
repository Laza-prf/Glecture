class Book {
  final String id;
  final String titre;
  final String? auteur;
  final String? cheminFichier;

  Book({
    required this.id,
    required this.titre,
    this.auteur,
    this.cheminFichier,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      titre: json['titre'] ?? '',
      auteur: json['auteur'],
      cheminFichier: json['chemin_fichier'],
    );
  }
}

class ChapterSummary {
  final String id;
  final int numero;
  final String titre;

  ChapterSummary({
    required this.id,
    required this.numero,
    required this.titre,
  });

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    return ChapterSummary(
      id: json['id'].toString(),
      numero: json['numero'] ?? 0,
      titre: json['titre'] ?? '',
    );
  }
}

class BookDetail {
  final Book book;
  final List<ChapterSummary> chapitres;

  BookDetail({required this.book, required this.chapitres});

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    final chapitresJson = (json['chapitres'] as List?) ?? [];
    return BookDetail(
      book: Book.fromJson(json),
      chapitres: chapitresJson
          .map((e) => ChapterSummary.fromJson(e))
          .toList()
        ..sort((a, b) => a.numero.compareTo(b.numero)),
    );
  }
}