import 'dart:async';

import '../models/batak_word_model.dart';
import '../../domain/entities/learning_progress.dart';

class LearningLocalDataSource {
  LearningLocalDataSource() {
    _refreshDerivedLearnedFlags();
  }

  static const _rawWords = <Map<String, dynamic>>[
    {'word': 'Horas', 'meaning': 'Halo / salam'},
    {'word': 'Mauliate', 'meaning': 'Terima kasih'},
    {'word': 'Amang', 'meaning': 'Bapak / ayah'},
    {'word': 'Inang', 'meaning': 'Ibu'},
    {'word': 'Boru', 'meaning': 'Anak perempuan'},
    {'word': 'Bere', 'meaning': 'Keponakan'},
    {'word': 'Lae', 'meaning': 'Ipar laki-laki'},
    {'word': 'Eda', 'meaning': 'Ipar perempuan'},
    {'word': 'Dame', 'meaning': 'Damai'},
    {'word': 'Tulang', 'meaning': 'Paman'},
    {'word': 'Mangan', 'meaning': 'Makan'},
    {'word': 'Pasu-pasu', 'meaning': 'Berkat'},
  ];

  final Set<String> _learnedWords = {
    'Horas',
    'Mauliate',
    'Amang',
    'Inang',
    'Dame',
  };

  LearningProgress _progress = const LearningProgress.initial();
  final StreamController<LearningProgress> _progressController =
      StreamController<LearningProgress>.broadcast();

  List<BatakWordModel> _refreshDerivedLearnedFlags() {
    return _rawWords
        .map(
          (json) => BatakWordModel.fromJson({
            ...json,
            'isLearned': _learnedWords.contains(json['word']),
          }),
        )
        .toList();
  }

  Future<List<BatakWordModel>> getAllWords() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _refreshDerivedLearnedFlags();
  }

  Future<List<BatakWordModel>> getLearnedWords() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _refreshDerivedLearnedFlags().where((word) => word.isLearned).toList();
  }

  Future<List<BatakWordModel>> searchNewWords(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    return _refreshDerivedLearnedFlags()
        .where(
          (word) =>
              !word.isLearned &&
              (word.word.toLowerCase().contains(normalized) ||
                  word.meaning.toLowerCase().contains(normalized)),
        )
        .toList();
  }

  Future<LearningProgress> getProgress() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _progress;
  }

  Stream<LearningProgress> watchProgress() => _progressController.stream;

  Future<void> markLearned(BatakWordModel word) async {
    if (_learnedWords.add(word.word)) {
      final nextCount = _progress.learnedCount + 1;
      _progress = _progress.copyWith(learnedCount: nextCount);
      _progressController.add(_progress);
    }
  }

  Future<void> recordExercise({
    required int correct,
    required int total,
    required int reviewedWords,
    required int xp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final nextXp = _progress.xp + xp;
    final nextLevel = (nextXp ~/ 500) + 1;
    _progress = _progress.copyWith(xp: nextXp, level: nextLevel);
    _progressController.add(_progress);
  }

  Future<void> dispose() => _progressController.close();
}
