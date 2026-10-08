import '../entities/batak_word.dart';
import '../entities/learning_progress.dart';

abstract interface class LearningRepository {
  Future<List<BatakWord>> getAllWords();

  Future<List<BatakWord>> getLearnedWords();

  Future<List<BatakWord>> searchNewWords(String query);

  Future<LearningProgress> getProgress();

  Stream<LearningProgress> watchProgress();

  Future<void> markLearned(BatakWord word);

  Future<void> recordExercise({
    required int correct,
    required int total,
    required int reviewedWords,
    required int xp,
  });
}
