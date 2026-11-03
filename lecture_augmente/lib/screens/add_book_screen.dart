import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reading_provider.dart';
import '../services/api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titreController = TextEditingController();
  final _auteurController = TextEditingController();
  final ApiService _api = ApiService();

  PlatformFile? _fichier;
  bool _isUploading = false;
  String? _erreur;

  @override
  void dispose() {
    _titreController.dispose();
    _auteurController.dispose();
    super.dispose();
  }

  Future<void> _choisirFichier() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fichier = result.files.first;
        _erreur = null;
      });
    }
  }

  Future<void> _envoyer() async {
    if (_titreController.text.trim().isEmpty) {
      setState(() => _erreur = 'Le titre est obligatoire');
      return;
    }
    if (_fichier == null || _fichier!.path == null) {
      setState(() => _erreur = 'Choisis un fichier .txt ou .pdf');
      return;
    }

    final token = context.read<AuthProvider>().token;
    if (token == null) {
      setState(() => _erreur = 'Connecte-toi avant d\'ajouter un livre');
      return;
    }

    setState(() {
      _isUploading = true;
      _erreur = null;
    });

    try {
      await _api.uploadLivre(
        titre: _titreController.text.trim(),
        auteur: _auteurController.text.trim(),
        filePath: _fichier!.path!,
        fileName: _fichier!.name,
        token: token,
      );
      if (mounted) {
        await context.read<ReadingProvider>().loadBooks();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _erreur = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un livre'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre d'instruction
            Text(
              'Importer un nouveau document',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Remplissez les détails et sélectionnez un fichier au format TXT ou PDF.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Champ Titre
            TextField(
              controller: _titreController,
              decoration: InputDecoration(
                labelText: 'Titre du livre *',
                prefixIcon: const Icon(Icons.title_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Champ Auteur
            TextField(
              controller: _auteurController,
              decoration: InputDecoration(
                labelText: 'Auteur (Optionnel)',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Zone d'import de fichier
            InkWell(
              onTap: _choisirFichier,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _fichier == null
                      ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _fichier == null
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : Colors.green.shade400,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _fichier == null
                            ? theme.colorScheme.primaryContainer
                            : Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _fichier == null
                            ? Icons.cloud_upload_outlined
                            : Icons.insert_drive_file_rounded,
                        color: _fichier == null
                            ? theme.colorScheme.primary
                            : Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fichier == null
                                ? 'Sélectionner un fichier'
                                : _fichier!.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _fichier == null
                                  ? theme.textTheme.bodyMedium?.color
                                  : Colors.green.shade900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fichier == null
                                ? 'Formats acceptés : .txt, .pdf'
                                : 'Fichier prêt à l\'envoi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _fichier == null
                                  ? Colors.grey[600]
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),

            // Message d'erreur
            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _erreur!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Bouton de validation
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _envoyer,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_upload_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Importer le livre',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}