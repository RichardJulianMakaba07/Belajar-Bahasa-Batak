import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/batak_word.dart';
import '../../domain/entities/learning_progress.dart';
import '../../domain/usecases/get_all_words_use_case.dart';
import '../../domain/usecases/get_learned_words_use_case.dart';
import '../../domain/usecases/get_progress_use_case.dart';
import '../../domain/usecases/mark_learned_use_case.dart';
import '../../domain/usecases/record_exercise_use_case.dart';
import '../../domain/usecases/search_new_words_use_case.dart';

sealed class LearningState extends Equatable {
  const LearningState();

  @override
  List<Object?> get props => [];
}

final class LearningInitial extends LearningState {}

final class LearningLoading extends LearningState {}

final class LearningLoaded extends LearningState {
  final List<BatakWord> words;
  final List<BatakWord> learnedWords;
  final List<BatakWord> newWords;
  final LearningProgress progress;

  const LearningLoaded({
    required this.words,
    required this.learnedWords,
    required this.newWords,
    required this.progress,
  });

  LearningLoaded copyWith({
    List<BatakWord>? words,
    List<BatakWord>? learnedWords,
    List<BatakWord>? newWords,
    LearningProgress? progress,
  }) {
    return LearningLoaded(
      words: words ?? this.words,
      learnedWords: learnedWords ?? this.learnedWords,
      newWords: newWords ?? this.newWords,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [words, learnedWords, newWords, progress];
}

final class LearningError extends LearningState {
  final String message;

  const LearningError(this.message);

  @override
  List<Object?> get props => [message];
}

class LearningCubit extends Cubit<LearningState> {
  final GetAllWordsUseCase getAllWords;
  final GetLearnedWordsUseCase getLearnedWords;
  final SearchNewWordsUseCase searchNewWords;
  final GetProgressUseCase getProgress;
  final MarkLearnedUseCase markLearned;
  final RecordExerciseUseCase recordExercise;
  final Stream<LearningProgress> progressStream;

  StreamSubscription<LearningProgress>? _progressSubscription;
  int _searchRequestId = 0;

  LearningCubit({
    required this.getAllWords,
    required this.getLearnedWords,
    required this.searchNewWords,
    required this.getProgress,
    required this.markLearned,
    required this.recordExercise,
    required this.progressStream,
  }) : super(LearningInitial()) {
    _progressSubscription = progressStream.listen(_onProgressChanged);
  }

  Future<void> load() async {
    emit(LearningLoading());
    try {
      final results = await Future.wait<Object>([
        getAllWords(),
        getLearnedWords(),
        getProgress(),
      ]);

      final words = results[0] as List<BatakWord>;
      final learned = results[1] as List<BatakWord>;
      final progress = results[2] as LearningProgress;

      emit(
        LearningLoaded(
          words: words,
          learnedWords: learned,
          newWords: words.where((item) => !item.isLearned).toList(),
          progress: progress,
        ),
      );
    } catch (e) {
      emit(
        LearningError(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> search(String query) async {
    final id = ++_searchRequestId;
    if (state is! LearningLoaded) return;

    final current = state as LearningLoaded;
    if (query.trim().isEmpty) {
      emit(current.copyWith(newWords: const []));
      return;
    }

    try {
      final result = await searchNewWords(query);
      if (id != _searchRequestId || isClosed) return;
      emit(current.copyWith(newWords: result));
    } catch (_) {
      if (id == _searchRequestId) {
        emit(current.copyWith(newWords: const []));
      }
    }
  }

  Future<void> setLearned(BatakWord word) async {
    await markLearned(word);
    await _refreshKeepingState();
  }

  Future<void> saveExerciseResult({
    required int correct,
    required int total,
    required int reviewedWords,
    required int xp,
  }) async {
    await recordExercise(
      correct: correct,
      total: total,
      reviewedWords: reviewedWords,
      xp: xp,
    );
    await _refreshKeepingState();
  }

  Future<void> _refreshKeepingState() async {
    if (state is! LearningLoaded) {
      await load();
      return;
    }

    final current = state as LearningLoaded;
    try {
      final learned = await getLearnedWords();
      final progress = await getProgress();
      emit(
        current.copyWith(
          learnedWords: learned,
          progress: progress,
          newWords: current.words
              .map(
                (word) => learned.any((item) => item.word == word.word)
                    ? word.copyWith(isLearned: true)
                    : word.copyWith(isLearned: false),
              )
              .toList(),
        ),
      );
    } catch (_) {
      // State lama tetap dipakai; data berikutnya bisa dimuat ulang.
    }
  }

  void _onProgressChanged(LearningProgress progress) {
    final current = state;
    if (current is LearningLoaded) {
      emit(current.copyWith(progress: progress));
    }
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
