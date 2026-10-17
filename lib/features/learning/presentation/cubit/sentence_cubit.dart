import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SentenceQuestion extends Equatable {
  final List<String> words;
  final List<String> answer;
  final String hint;

  const SentenceQuestion({
    required this.words,
    required this.answer,
    this.hint = 'Pikirkan urutan kalimat yang paling natural.',
  });

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
  bool get isLast => index == questions.length - 1;

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

  SentenceCubit()
      : super(
          const SentenceState(
            questions: [
              SentenceQuestion(
                words: ['aku', 'mauliate', 'hamu', 'HORAS', 'ma'],
                answer: ['HORAS', 'mauliate', 'ma', 'hamu'],
              ),
              SentenceQuestion(
                words: ['hita', 'ahu', 'ma', 'mangan'],
                answer: ['mangan', 'ma', 'hita'],
              ),
              SentenceQuestion(
                words: ['tu', 'dang', 'jabu', 'ahu', 'mulak'],
                answer: ['mulak', 'ahu', 'tu', 'jabu'],
              ),
              SentenceQuestion(
                words: ['Batak', 'hamu', 'halak', 'ahu'],
                answer: ['ahu', 'halak', 'Batak'],
              ),
              SentenceQuestion(
                words: ['huboto', 'mauliate', 'dang'],
                answer: ['dang', 'huboto'],
              ),
            ],
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
    _loadQuestion();
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
