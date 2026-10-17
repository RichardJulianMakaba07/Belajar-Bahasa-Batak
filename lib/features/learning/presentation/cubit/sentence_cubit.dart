import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/batak_word.dart';

class SentenceQuestion extends Equatable {
  final List<String> words;
  final List<String> answer;
  final String hint;

  const SentenceQuestion({
    required this.words,
    required this.answer,
    this.hint = 'Pikirkan urutan kalimat yang paling natural.',
  });

  static SentenceQuestion? fromEntry(BatakWord entry, Random random) {
    final phrase = entry.word.trim();
    if (phrase.contains(RegExp(r'[;:()\d]'))) return null;

    final answer = phrase
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    if (answer.length < 2 || answer.length > 6) return null;

    var shuffled = [...answer]..shuffle(random);
    for (var attempt = 0; attempt < 5 && _sameOrder(shuffled, answer); attempt++) {
      shuffled = [...answer]..shuffle(random);
    }

    return SentenceQuestion(
      words: shuffled,
      answer: answer,
      hint: 'Artinya: ${entry.meaning}',
    );
  }

  static bool _sameOrder(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [words, answer, hint];
}

class SelectedWord extends Equatable {
  final int id;
  final String text;

  const SelectedWord(this.id, this.text);

  @override
  List<Object?> get props => [id, text];
}

class SentenceState extends Equatable {
  final List<SentenceQuestion> questions;
  final int index;
  final List<SelectedWord> bank;
  final List<SelectedWord> selected;
  final bool? result;
  final Set<int> solved;
  final Duration duration;
  final bool finished;

  const SentenceState({
    required this.questions,
    required this.index,
    required this.bank,
    required this.selected,
    required this.result,
    required this.solved,
    required this.duration,
    required this.finished,
  });

  SentenceQuestion get current => questions[index];
  bool get isLast => questions.isNotEmpty && index == questions.length - 1;

  @override
  List<Object?> get props => [
        questions,
        index,
        bank,
        selected,
        result,
        solved,
        duration,
        finished,
      ];
}

class SentenceCubit extends Cubit<SentenceState> {
  final Stopwatch _stopwatch = Stopwatch();

  SentenceCubit(List<SentenceQuestion> questions)
      : super(
          SentenceState(
            questions: questions,
            index: 0,
            bank: const [],
            selected: const [],
            result: null,
            solved: <int>{},
            duration: Duration.zero,
            finished: false,
          ),
        ) {
    _stopwatch.start();
    if (questions.isNotEmpty) _loadQuestion();
  }

  static List<SentenceQuestion> questionsFromWords(
    List<BatakWord> words, {
    int count = 5,
  }) {
    final random = Random();
    final questions = words
        .map((word) => SentenceQuestion.fromEntry(word, random))
        .whereType<SentenceQuestion>()
        .toList()
      ..shuffle(random);
    return questions.take(count).toList();
  }

  void _loadQuestion() {
    final question = state.current;
    emit(
      SentenceState(
        questions: state.questions,
        index: state.index,
        bank: [
          for (var i = 0; i < question.words.length; i++)
            SelectedWord(i, question.words[i]),
        ],
        selected: const [],
        result: null,
        solved: state.solved,
        duration: state.duration,
        finished: false,
      ),
    );
  }

  void pick(SelectedWord word) {
    final bank = [...state.bank]..remove(word);
    final selected = [...state.selected, word];

    emit(
      SentenceState(
        questions: state.questions,
        index: state.index,
        bank: bank,
        selected: selected,
        result: null,
        solved: state.solved,
        duration: state.duration,
        finished: false,
      ),
    );
  }

  void unpick(SelectedWord word) {
    final selected = [...state.selected]..remove(word);
    final bank = [...state.bank, word]
      ..sort((a, b) => a.id.compareTo(b.id));

    emit(
      SentenceState(
        questions: state.questions,
        index: state.index,
        bank: bank,
        selected: selected,
        result: null,
        solved: state.solved,
        duration: state.duration,
        finished: false,
      ),
    );
  }

  void reset() => _loadQuestion();

  void check() {
    final user = state.selected.map((word) => word.text).join(' ');
    final correct = state.current.answer.join(' ');
    final ok = user == correct;

    final solved = {...state.solved};
    if (ok) solved.add(state.index);

    emit(
      SentenceState(
        questions: state.questions,
        index: state.index,
        bank: state.bank,
        selected: state.selected,
        result: ok,
        solved: solved,
        duration: state.duration,
        finished: false,
      ),
    );
  }

  void next() {
    if (state.isLast) {
      finish();
      return;
    }
    final nextIndex = state.index + 1;
    emit(
      SentenceState(
        questions: state.questions,
        index: nextIndex,
        bank: const [],
        selected: const [],
        result: null,
        solved: state.solved,
        duration: state.duration,
        finished: false,
      ),
    );
    _loadQuestion();
  }

  void finish() {
    _stopwatch.stop();
    emit(
      SentenceState(
        questions: state.questions,
        index: state.index,
        bank: state.bank,
        selected: state.selected,
        result: state.result,
        solved: state.solved,
        duration: _stopwatch.elapsed,
        finished: true,
      ),
    );
  }

  void restart() {
    _stopwatch
      ..reset()
      ..start();
    emit(
      SentenceState(
        questions: state.questions,
        index: 0,
        bank: const [],
        selected: const [],
        result: null,
        solved: const {},
        duration: Duration.zero,
        finished: false,
      ),
    );
    _loadQuestion();
  }

  @override
  Future<void> close() {
    _stopwatch.stop();
    return super.close();
  }
}
