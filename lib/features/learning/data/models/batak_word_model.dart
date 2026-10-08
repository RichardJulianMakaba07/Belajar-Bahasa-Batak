import '../../domain/entities/batak_word.dart';

class BatakWordModel extends BatakWord {
  const BatakWordModel({
    required super.word,
    required super.meaning,
    super.isLearned,
  });

  factory BatakWordModel.fromJson(Map<String, dynamic> json) {
    return BatakWordModel(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      isLearned: (json['isLearned'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'meaning': meaning,
        'isLearned': isLearned,
      };
}
