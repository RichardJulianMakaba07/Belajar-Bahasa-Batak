import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pembelajaran_bahasa_batak/features/learning/domain/entities/batak_word.dart';
import 'package:pembelajaran_bahasa_batak/features/learning/presentation/cubit/sentence_cubit.dart';

void main() {
  test('sentence questions are created only from dictionary phrases', () {
    final random = Random(1);
    final phrase = SentenceQuestion.fromEntry(
      const BatakWord(word: 'mulak tu jabu', meaning: 'pulang ke rumah'),
      random,
    );
    final word = SentenceQuestion.fromEntry(
      const BatakWord(word: 'Horas', meaning: 'Salam'),
      random,
    );
    final multiDefinition = SentenceQuestion.fromEntry(
      const BatakWord(word: 'mulak; tu jabu', meaning: 'pulang'),
      random,
    );

    expect(phrase, isNotNull);
    expect(phrase!.answer, ['mulak', 'tu', 'jabu']);
    expect(phrase.hint, 'Artinya: pulang ke rumah');
    expect(word, isNull);
    expect(multiDefinition, isNull);
  });
}
