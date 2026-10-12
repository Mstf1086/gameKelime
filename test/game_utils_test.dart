import 'package:flutter_test/flutter_test.dart';

import 'package:game_kelime/core/utils/game_utils.dart';

void main() {
  test('Türkçe olmayan klavye harfleri cevaba göre normalize edilir', () {
    // "AĞAÇ" cevabında g→ğ, c→ç kabul edilir; doğrusu döner.
    expect(GameUtils.normalizeLetterForAnswer('g', 'AĞAÇ'), 'Ğ');
    expect(GameUtils.normalizeLetterForAnswer('G', 'AĞAÇ'), 'Ğ');
    expect(GameUtils.normalizeLetterForAnswer('c', 'AĞAÇ'), 'Ç');
    expect(GameUtils.normalizeLetterForAnswer('a', 'AĞAÇ'), 'A');
    // Doğrudan cevapta olan harf aynen döner.
    expect(GameUtils.normalizeLetterForAnswer('ğ', 'AĞAÇ'), 'Ğ');
    // Cevapta olmayan harf yanlış tahmin olarak aynen döner.
    expect(GameUtils.normalizeLetterForAnswer('b', 'AĞAÇ'), 'B');
    // Harf olmayan girdiler yok sayılır.
    expect(GameUtils.normalizeLetterForAnswer(' ', 'AĞAÇ'), isNull);
    expect(GameUtils.normalizeLetterForAnswer('1', 'AĞAÇ'), isNull);
  });
}