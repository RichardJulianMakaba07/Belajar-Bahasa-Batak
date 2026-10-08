import 'package:equatable/equatable.dart';

class BatakWord extends Equatable {
  final String word;
  final String meaning;
  final bool isLearned;

  const BatakWord({
    required this.word,
    required this.meaning,
    this.isLearned = false,
  });

  BatakWord copyWith({bool? isLearned}) {
    return BatakWord(
      word: word,
      meaning: meaning,
      isLearned: isLearned ?? this.isLearned,
    );
  }

  @override
  List<Object?> get props => [word, meaning, isLearned];
}
