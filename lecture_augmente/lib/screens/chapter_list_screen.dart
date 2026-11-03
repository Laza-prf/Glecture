 import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';

import 'reader_screen.dart';


class ChapterListScreen extends StatefulWidget {

final String livreId;

final String titre;


const ChapterListScreen({super.key, required this.livreId, required this.titre});


@override

State<ChapterListScreen> createState() => _ChapterListScreenState();

}


class _ChapterListScreenState extends State<ChapterListScreen> {

bool _isLoading = true;

String? _error;


@override

void initState() {

super.initState();

_load();

}


Future<void> _load() async {

try {

await context.read<ReadingProvider>().loadBookDetail(widget.livreId);

} catch (e) {

_error = 'Impossible de charger les chapitres.';

} finally {

if (mounted) setState(() => _isLoading = false);

}

}


@override

Widget build(BuildContext context) {

final detail = context.watch<ReadingProvider>().currentBookDetail;


return Scaffold(

appBar: AppBar(title: Text(widget.titre)),

body: _isLoading

? const Center(child: CircularProgressIndicator())

: _error != null

? Center(child: Text(_error!))

: detail == null || detail.chapitres.isEmpty

? const Center(child: Text('Aucun chapitre trouvé.'))

: ListView.builder(

itemCount: detail.chapitres.length,

itemBuilder: (context, index) {

final chapitre = detail.chapitres[index];

return ListTile(

leading: CircleAvatar(child: Text('${chapitre.numero}')),

title: Text(chapitre.titre.isNotEmpty

? chapitre.titre

: 'Chapitre ${chapitre.numero}'),

onTap: () {

Navigator.push(

context,

MaterialPageRoute(

builder: (_) => ReaderScreen(

chapitres: detail.chapitres,

index: index,

livreTitre: widget.titre,

),

),

);

},

);

},

),

);

}

}