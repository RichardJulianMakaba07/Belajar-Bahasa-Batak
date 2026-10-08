import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizWord extends Equatable {
  final String word;
  final String meaning;

  const QuizWord({required this.word, required this.meaning});

  @override
  List<Object?> get props => [word, meaning];
}

class QuizQuestion extends Equatable {
  final String word;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
  });

  @override
  List<Object?> get props => [word, options, correctIndex];
}

class QuizState extends Equatable {
  final List<QuizQuestion> questions;
  final int index;
  final int? selected;
  final int score;
  final List<bool> answers;
  final Duration duration;
  final bool finished;
  final bool hintOpen;

  const QuizState({
    required this.questions,
    required this.index,
    required this.selected,
    required this.score,
    required this.answers,
    required this.duration,
    required this.finished,
    required this.hintOpen,
  });

  const QuizState.initial()
      : questions = const [],
        index = 0,
        selected = null,
        score = 0,
        answers = const [],
        duration = Duration.zero,
        finished = false,
        hintOpen = true;

  QuizQuestion get current => questions[index];
  bool get answered => selected != null;
  bool get isLast => questions.isNotEmpty && index == questions.length - 1;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? index,
    int? selected,
    bool clearSelected = false,
    int? score,
    List<bool>? answers,
    Duration? duration,
    bool? finished,
    bool? hintOpen,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      index: index ?? this.index,
      selected: clearSelected ? null : (selected ?? this.selected),
      score: score ?? this.score,
      answers: answers ?? this.answers,
      duration: duration ?? this.duration,
      finished: finished ?? this.finished,
      hintOpen: hintOpen ?? this.hintOpen,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        index,
        selected,
        score,
        answers,
        duration,
        finished,
        hintOpen,
      ];
}

class QuizCubit extends Cubit<QuizState> {
  final Stopwatch _stopwatch = Stopwatch();

  QuizCubit(List<QuizWord> words, {int questionCount = 10})
      : super(QuizState.initial()) {
    final random = Random();
    final pool = [...words]..shuffle(random);
    final picked = pool.take(min(questionCount, pool.length)).toList();

    final questions = picked.map((word) {
      final distractors = words
          .where((item) => item.meaning != word.meaning)
          .map((item) => item.meaning)
          .toSet()
          .toList()
        ..shuffle(random);

      final options = [word.meaning, ...distractors.take(3)]..shuffle(random);
      return QuizQuestion(
        word: word.word,
        options: options,
        correctIndex: options.indexOf(word.meaning),
      );
    }).toList();

    emit(
      QuizState.initial().copyWith(
        questions: questions,
      ),
    );
    _stopwatch.start();
  }

  void selectOption(int index) {
    if (state.finished || state.answered || state.questions.isEmpty) return;

    final correct = index == state.current.correctIndex;
    final answers = [...state.answers, correct];

    emit(
      state.copyWith(
        selected: index,
        score: state.score + (correct ? 1 : 0),
        answers: answers,
      ),
    );
  }

  void next() {
    if (!state.answered || state.questions.isEmpty) return;
    if (state.isLast) {
      finish();
      return;
    }

    emit(
      state.copyWith(
        index: state.index + 1,
        clearSelected: true,
      ),
    );
  }

  void toggleHint() {
    emit(state.copyWith(hintOpen: !state.hintOpen));
  }

  void finish() {
    if (state.finished) return;
    _stopwatch.stop();
    emit(
      state.copyWith(
        duration: _stopwatch.elapsed,
        finished: true,
      ),
    );
  }

  void restart() {
    // Recreate by using the same question bank in its existing order; this
    // keeps the UI intact while resetting all ephemeral exercise state.
    _stopwatch
      ..reset()
      ..start();
    emit(
      QuizState(
        questions: state.questions,
        index: 0,
        selected: null,
        score: 0,
        answers: const [],
        duration: Duration.zero,
        finished: false,
        hintOpen: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _stopwatch.stop();
    return super.close();
  }
}
