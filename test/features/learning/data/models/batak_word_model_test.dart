import 'package:flutter_test/flutter_test.dart';
import 'package:pembelajaran_bahasa_batak/features/learning/data/models/batak_word_model.dart';

void main() {
  group('BatakWordModel.fromDictEntry', () {
    test('maps Indonesian-source CSV entries to Batak word and meaning', () {
      final word = BatakWordModel.fromDictEntry({
        'headword': 'abang',
        'definitions':
            '1. angkang; 2. abang dari ibu: tulang; 3. abang dari ayah: amang tua',
        'sourceLang': 'ind',
        'targetLang': 'btk',
      });

      expect(
        word.word,
        'angkang; abang dari ibu: tulang; abang dari ayah: amang tua',
      );
      expect(word.meaning, 'abang');
    });

    test('keeps Batak-source headwords and removes numbered senses', () {
      final word = BatakWordModel.fromDictEntry({
        'headword': 'abai',
        'definitions': '1. tiasi; 2. kuabaikan: hutiasi',
        'sourceLang': 'btk',
        'targetLang': 'ind',
      });

      expect(word.word, 'abai');
      expect(word.meaning, 'tiasi; kuabaikan: hutiasi');
    });
  });
}
