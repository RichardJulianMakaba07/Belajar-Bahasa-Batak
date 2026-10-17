import '../../domain/entities/batak_word.dart';

class BatakWordModel extends BatakWord {
  const BatakWordModel({
    required super.word,
    required super.meaning,
    super.isLearned,
  });

  factory BatakWordModel.fromJson(Map<String, dynamic> json) {
    return BatakWordModel(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      isLearned: (json['isLearned'] as bool?) ?? false,
    );
  }

  /// Dokumen koleksi `dict_entries` di Firestore.
  ///
  /// Data kamus dua arah: bila `sourceLang` == `btk`, `headword` adalah kata
  /// Batak dan `definitions` artinya. Bila `ind`, `definitions` berisi kata
  /// Batak dan `headword` berisi artinya dalam bahasa Indonesia.
  factory BatakWordModel.fromDictEntry(Map<String, dynamic> data) {
    final headword = (data['headword'] as String? ?? '').trim();
    final definitions =
        _cleanDefinitions(data['definitions'] as String? ?? '');
    final headwordIsBatak =
        (data['sourceLang'] as String?)?.toLowerCase() == 'btk';

    return BatakWordModel(
      word: headwordIsBatak ? headword : definitions,
      meaning: headwordIsBatak ? definitions : headword,
    );
  }

  /// "1. tiasi; 2. kuabaikan: hutiasi" -> "tiasi; kuabaikan: hutiasi"
  static String _cleanDefinitions(String raw) {
    return raw
        .split(';')
        .map((part) => part.trim().replaceFirst(RegExp(r'^\d+\.\s*'), ''))
        .where((part) => part.isNotEmpty)
        .join('; ');
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'meaning': meaning,
        'isLearned': isLearned,
      };
}
