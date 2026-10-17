import 'dart:async';

import '../models/batak_word_model.dart';
import '../../domain/entities/learning_progress.dart';

/// Menyimpan status belajar di memori perangkat (hilang saat aplikasi
/// ditutup). Daftar kata sendiri kini berasal dari Firestore.
class LearningLocalDataSource {
  final Map<String, BatakWordModel> _learned = {};

  LearningProgress _progress = const LearningProgress.initial();
  final StreamController<LearningProgress> _progressController =
      StreamController<LearningProgress>.broadcast();

  Set<String> get learnedKeys => _learned.keys.toSet();

  Future<List<BatakWordModel>> getLearnedWords() async {
    return _learned.values
        .map(
          (word) => BatakWordModel(
            word: word.word,
            meaning: word.meaning,
            isLearned: true,
          ),
        )
        .toList();
  }

  Future<LearningProgress> getProgress() async => _progress;

  Stream<LearningProgress> watchProgress() => _progressController.stream;

  Future<void> markLearned(BatakWordModel word) async {
    if (_learned.containsKey(word.word)) return;

    _learned[word.word] = word;
    _progress = _progress.copyWith(learnedCount: _progress.learnedCount + 1);
    _progressController.add(_progress);
  }

  Future<void> recordExercise({
    required int correct,
    required int total,
    required int reviewedWords,
    required int xp,
  }) async {
    final nextXp = _progress.xp + xp;
    final nextLevel = (nextXp ~/ 500) + 1;
    _progress = _progress.copyWith(
      xp: nextXp,
      level: nextLevel,
      correctAnswers: _progress.correctAnswers + correct,
      totalAnswers: _progress.totalAnswers + total,
      perfectExercises: _progress.perfectExercises +
          (total > 0 && correct == total ? 1 : 0),
    );
    _progressController.add(_progress);
  }

  Future<void> dispose() => _progressController.close();
}
