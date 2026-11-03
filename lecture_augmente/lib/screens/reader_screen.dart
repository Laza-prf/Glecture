import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/reading_provider.dart';
import '../widgets/tappable_text.dart';
import '../widgets/summary_panel.dart';
import '../widgets/definition_popup.dart';

class ReaderScreen extends StatefulWidget {
  final List<ChapterSummary> chapitres;
  final int index;
  final String livreTitre;

  const ReaderScreen({
    super.key,
    required this.chapitres,
    required this.index,
    required this.livreTitre,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late int _index;
  bool _isLoadingChapter = true;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    setState(() => _isLoadingChapter = true);
    await context
        .read<ReadingProvider>()
        .openChapter(widget.chapitres[_index].id);
    if (mounted) setState(() => _isLoadingChapter = false);
  }

  void _onWordTap(String word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DefinitionPopup(word: word),
    );
  }

  void _nextChapter() {
    if (_index < widget.chapitres.length - 1) {
      setState(() => _index++);
      _loadChapter();
    }
  }

  void _previousChapter() {
    if (_index > 0) {
      setState(() => _index--);
      _loadChapter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ReadingProvider>();
    final chapter = provider.currentChapter;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.livreTitre,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Bouton IA mis en valeur avec une puce (Chip)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              elevation: 0,
              avatar: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Résumé', style: TextStyle(fontSize: 12)),
              onPressed: chapter == null
                  ? null
                  : () {
                      context.read<ReadingProvider>().generateSummary();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => const SummaryPanel(),
                      );
                    },
            ),
          ),
        ],
      ),
      body: _isLoadingChapter
          ? const Center(child: CircularProgressIndicator())
          : chapter == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Chapitre introuvable.',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Surtitre : Numéro du chapitre
                      Text(
                        'CHAPITRE ${_index + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Titre principal du chapitre
                      Text(
                        chapter.titre.isNotEmpty
                            ? chapter.titre
                            : 'Chapitre ${chapter.numero}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      // Zone de lecture textuelle
                      DefaultTextStyle(
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontSize: 17,
                          height: 1.7, // Espacement de ligne optimal pour la lecture
                          letterSpacing: 0.3,
                        ),
                        child: TappableText(
                          text: chapter.contenu,
                          onWordTap: _onWordTap,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

      // Barre de navigation inférieure épurée
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _index > 0 ? _previousChapter : null,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                tooltip: 'Chapitre précédent',
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_index + 1} sur ${widget.chapitres.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    _index < widget.chapitres.length - 1 ? _nextChapter : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                tooltip: 'Chapitre suivant',
              ),
            ],
          ),
        ),
      ),
    );
  }
}