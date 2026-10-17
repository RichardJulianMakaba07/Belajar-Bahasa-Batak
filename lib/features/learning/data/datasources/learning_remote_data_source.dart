import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/batak_word_model.dart';

/// Sumber data kamus dari Cloud Firestore (koleksi `dict_entries`).
class LearningRemoteDataSource {
  LearningRemoteDataSource(this._firestore);

  static const collectionName = 'dict_entries';
  static const _pageSize = 500;

  final FirebaseFirestore _firestore;
  Future<List<BatakWordModel>>? _catalog;

  CollectionReference<Map<String, dynamic>> get _entries =>
      _firestore.collection(collectionName);

  /// Kamus dibaca per halaman agar setiap fitur kosakata menggunakan entri
  /// Firestore, bukan daftar contoh yang tertanam di aplikasi.
  Future<List<BatakWordModel>> getWords() => _getCatalog();

  Future<List<BatakWordModel>> _getCatalog() async {
    final cached = _catalog;
    if (cached != null) return cached;

    final request = _fetchCatalog();
    _catalog = request;
    try {
      return await request;
    } catch (_) {
      _catalog = null;
      rethrow;
    }
  }

  Future<List<BatakWordModel>> _fetchCatalog() async {
    final words = <String, BatakWordModel>{};
    DocumentSnapshot<Map<String, dynamic>>? lastDocument;

    while (true) {
      var query = _entries
          .where('sourceLang', whereIn: const ['btk', 'ind'])
          .orderBy(FieldPath.documentId)
          .limit(_pageSize);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final page = await query.get();
      for (final document in page.docs) {
        final data = document.data();
        if (_isDeleted(data)) continue;

        final word = BatakWordModel.fromDictEntry(data);
        if (word.word.isEmpty || word.meaning.isEmpty) continue;
        final key = '${word.word.toLowerCase()}\u0000'
            '${word.meaning.toLowerCase()}';
        words.putIfAbsent(key, () => word);
      }

      if (page.docs.length < _pageSize) break;
      lastDocument = page.docs.last;
    }

    final result = words.values.toList()
      ..sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
    return result;
  }

  static bool _isDeleted(Map<String, dynamic> data) {
    final deletedAt = data['deletedAt'];
    return deletedAt != null && deletedAt.toString().isNotEmpty;
  }

  /// Mencari di seluruh kamus, baik pada kata Batak maupun artinya. Definisi
  /// CSV dapat memuat nomor urut dan beberapa terjemahan dalam satu teks,
  /// sehingga pencarian dilakukan pada katalog Firestore yang sudah dimuat.
  Future<List<BatakWordModel>> searchWords(String query, {int limit = 30}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final words = await _getCatalog();
    final matches = words.where((word) =>
        word.word.toLowerCase().contains(q) ||
        word.meaning.toLowerCase().contains(q)).toList()
      ..sort((a, b) {
        final aRank = _matchRank(a, q);
        final bRank = _matchRank(b, q);
        if (aRank != bRank) return aRank.compareTo(bRank);
        return a.word.toLowerCase().compareTo(b.word.toLowerCase());
      });
    return matches.take(limit).toList();
  }

  static int _matchRank(BatakWordModel word, String query) {
    final batak = word.word.toLowerCase();
    final meaning = word.meaning.toLowerCase();
    if (batak == query) return 0;
    if (batak.startsWith(query)) return 1;
    if (meaning == query) return 2;
    if (meaning.startsWith(query)) return 3;
    return 4;
  }
}
