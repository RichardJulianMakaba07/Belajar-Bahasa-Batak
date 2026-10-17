import '../../domain/entities/batak_word.dart';
import '../../domain/entities/learning_progress.dart';
import '../../domain/repositories/learning_repository.dart';
import '../datasources/learning_local_data_source.dart';
import '../datasources/learning_remote_data_source.dart';
import '../models/batak_word_model.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningLocalDataSource local;
  final LearningRemoteDataSource remote;

  const LearningRepositoryImpl({required this.local, required this.remote});

  List<BatakWord> _withLearnedFlags(List<BatakWordModel> words) {
    final learned = local.learnedKeys;
    return words
        .map((word) => word.copyWith(isLearned: learned.contains(word.word)))
        .toList();
  }

  @override
  Future<List<BatakWord>> getAllWords() async =>
      _withLearnedFlags(await remote.getWords());

  @override
  Future<List<BatakWord>> getLearnedWords() => local.getLearnedWords();

  @override
  Future<List<BatakWord>> searchNewWords(String query) async =>
      _withLearnedFlags(await remote.searchWords(query));

  @override
  Future<LearningProgress> getProgress() => local.getProgress();

  @override
  Stream<LearningProgress> watchProgress() => local.watchProgress();

  @override
  Future<void> markLearned(BatakWord word) {
    return local.markLearned(
      BatakWordModel(word: word.word, meaning: word.meaning, isLearned: true),
    );
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
