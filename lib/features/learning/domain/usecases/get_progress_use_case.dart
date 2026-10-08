import '../entities/learning_progress.dart';
import '../repositories/learning_repository.dart';

class GetProgressUseCase {
  final LearningRepository repository;
  const GetProgressUseCase(this.repository);

  Future<LearningProgress> call() => repository.getProgress();
}
