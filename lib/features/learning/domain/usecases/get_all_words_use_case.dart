import '../entities/batak_word.dart';
import '../repositories/learning_repository.dart';

class GetAllWordsUseCase {
  final LearningRepository repository;
  const GetAllWordsUseCase(this.repository);

  Future<List<BatakWord>> call() => repository.getAllWords();
}
