import 'package:get_it/get_it.dart';

import '../../features/learning/data/datasources/learning_local_data_source.dart';
import '../../features/learning/data/repositories/learning_repository_impl.dart';
import '../../features/learning/domain/repositories/learning_repository.dart';
import '../../features/learning/domain/usecases/get_all_words_use_case.dart';
import '../../features/learning/domain/usecases/get_learned_words_use_case.dart';
import '../../features/learning/domain/usecases/get_progress_use_case.dart';
import '../../features/learning/domain/usecases/mark_learned_use_case.dart';
import '../../features/learning/domain/usecases/record_exercise_use_case.dart';
import '../../features/learning/domain/usecases/search_new_words_use_case.dart';
import '../../features/learning/presentation/cubit/learning_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

void configureDependencies() {
  if (sl.isRegistered<LearningRepository>()) return;

  sl.registerLazySingleton<LearningLocalDataSource>(
    LearningLocalDataSource.new,
  );
  sl.registerLazySingleton<LearningRepository>(
    () => LearningRepositoryImpl(sl<LearningLocalDataSource>()),
  );

  sl.registerLazySingleton(
    () => GetAllWordsUseCase(sl<LearningRepository>()),
  );
  sl.registerLazySingleton(
    () => GetLearnedWordsUseCase(sl<LearningRepository>()),
  );
  sl.registerLazySingleton(
    () => SearchNewWordsUseCase(sl<LearningRepository>()),
  );
  sl.registerLazySingleton(
    () => GetProgressUseCase(sl<LearningRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkLearnedUseCase(sl<LearningRepository>()),
  );
  sl.registerLazySingleton(
    () => RecordExerciseUseCase(sl<LearningRepository>()),
  );

  sl.registerFactory(
    () => LearningCubit(
      getAllWords: sl(),
      getLearnedWords: sl(),
      searchNewWords: sl(),
      getProgress: sl(),
      markLearned: sl(),
      recordExercise: sl(),
      progressStream: sl<LearningRepository>().watchProgress(),
    ),
  );

  sl.registerFactory(ProfileCubit.new);
}
