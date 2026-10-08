import '../entities/batak_word.dart';
import '../repositories/learning_repository.dart';

class GetLearnedWordsUseCase {
  final LearningRepository repository;
  const GetLearnedWordsUseCase(this.repository);

  Future<List<BatakWord>> call() => repository.getLearnedWords();
}
