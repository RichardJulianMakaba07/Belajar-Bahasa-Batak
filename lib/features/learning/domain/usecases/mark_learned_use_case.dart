import '../entities/batak_word.dart';
import '../repositories/learning_repository.dart';

class MarkLearnedUseCase {
  final LearningRepository repository;
  const MarkLearnedUseCase(this.repository);

  Future<void> call(BatakWord word) => repository.markLearned(word);
}
