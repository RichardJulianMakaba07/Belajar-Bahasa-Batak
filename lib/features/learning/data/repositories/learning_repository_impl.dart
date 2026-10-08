import '../../domain/entities/batak_word.dart';
import '../../domain/entities/learning_progress.dart';
import '../../domain/repositories/learning_repository.dart';
import '../datasources/learning_local_data_source.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningLocalDataSource local;

  const LearningRepositoryImpl(this.local);

  @override
  Future<List<BatakWord>> getAllWords() => local.getAllWords();

  @override
  Future<List<BatakWord>> getLearnedWords() => local.getLearnedWords();

  @override
  Future<List<BatakWord>> searchNewWords(String query) => local.searchNewWords(query);

  @override
  Future<LearningProgress> getProgress() => local.getProgress();

  @override
  Stream<LearningProgress> watchProgress() => local.watchProgress();

  @override
  Future<void> markLearned(BatakWord word) async {
    final model = await local.getAllWords().then(
          (items) => items.firstWhere(
            (item) => item.word == word.word,
            orElse: () => throw StateError('Kata tidak ditemukan.'),
          ),
        );
    await local.markLearned(model);
  }

  @override
  Future<void> recordExercise({
    required int correct,
    required int total,
    required int reviewedWords,
    required int xp,
  }) {
    return local.recordExercise(
      correct: correct,
      total: total,
      reviewedWords: reviewedWords,
      xp: xp,
    );
  }
}
