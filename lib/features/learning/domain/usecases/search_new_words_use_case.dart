import '../entities/batak_word.dart';
import '../repositories/learning_repository.dart';

class SearchNewWordsUseCase {
  final LearningRepository repository;
  const SearchNewWordsUseCase(this.repository);

  Future<List<BatakWord>> call(String query) => repository.searchNewWords(query);
}
