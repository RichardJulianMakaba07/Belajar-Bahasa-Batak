import '../repositories/learning_repository.dart';

class RecordExerciseUseCase {
  final LearningRepository repository;
  const RecordExerciseUseCase(this.repository);

  Future<void> call({
    required int correct,
    required int total,
    required int reviewedWords,
    required int xp,
  }) {
    return repository.recordExercise(
      correct: correct,
      total: total,
      reviewedWords: reviewedWords,
      xp: xp,
    );
  }
}
