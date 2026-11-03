import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class ReadingProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final WebSocketService _ws = WebSocketService();

  List<Book> books = [];
  BookDetail? currentBookDetail;
  Chapter? currentChapter;
  String streamingSummary = '';
  bool isLoadingSummary = false;
  String? summaryError;

  Future<void> loadBooks() async {
    books = await _api.getLivres();
    notifyListeners();
  }

  Future<void> loadBookDetail(String livreId) async {
    currentBookDetail = await _api.getLivreDetail(livreId);
    notifyListeners();
  }

  Future<void> openChapter(String chapitreId) async {
    currentChapter = await _api.getChapitre(chapitreId);
    streamingSummary = '';
    summaryError = null;
    notifyListeners();
  }

  Future<void> deleteBook(String bookId, String token) async {
    await _api.deleteLivre(bookId, token);
    books.removeWhere((book) => book.id == bookId);
    notifyListeners();
  }

  void generateSummary() {
    if (currentChapter == null) return;
    streamingSummary = '';
    isLoadingSummary = true;
    summaryError = null;
    notifyListeners();

    _ws.connect(
      onResumeChunk: (texte) {
        streamingSummary += texte;
        notifyListeners();
      },
      onResumeTermine: () {
        isLoadingSummary = false;
        notifyListeners();
      },
      onErreur: (message) {
        summaryError = message;
        isLoadingSummary = false;
        notifyListeners();
      },
    );

    _ws.demanderResume(currentChapter!.id, currentChapter!.contenu);
  }

  @override
  void dispose() {
    _ws.dispose();
    super.dispose();
  }
}