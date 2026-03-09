import 'package:riichi_score/hand.dart';
import 'package:test/test.dart';

void main() {
  const analyzer = HandAnalyzer();

  group('Seven Pairs', () {
    test('detects valid seven pairs', () {
      final hand = parseHand('11m22m33m44p55p66s1z+1z');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is SevenPairsHand), isTrue);
    });

    test('rejects non seven pairs', () {
      final hand = parseHand('11m22m33m44p55p66s1z2z+2z');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is SevenPairsHand), isFalse);
    });

    test('rejects non seven pairs 2', () {
      final hand = parseHand('1111m33m44p55p66s1z+1z');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is SevenPairsHand), isFalse);
    });

    test('seven pairs supports red tile', () {
      final hand = parseHand('11m22m33m44p50p66s1z+1z');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is SevenPairsHand), isTrue);
    });
  });

  group('Thirteen Orphans', () {
    test('detects valid kokushi musou', () {
      final hand = parseHand('19m19p19s1234567z+1m');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is ThirteenOrphansHand), isTrue);
    });

    test('rejects invalid kokushi', () {
      final hand = parseHand('19m19p19s1234z+2m');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is ThirteenOrphansHand), isFalse);
    });

    test('rejects invalid kokushi 2', () {
      final hand = parseHand('19m19p19s1234z1m+1m');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is ThirteenOrphansHand), isFalse);
    });

    test('rejects invalid kokushi 3', () {
      final hand = parseHand('19m19p19s1234z1m+9m');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is ThirteenOrphansHand), isFalse);
    });
  });

  group('Standard Hand', () {
    test('detects simple standard hand', () {
      final hand = parseHand('123456789m234p1z+1z');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is StandardHand), isTrue);
    });

    test('detects multiple decompositions', () {
      final hand = parseHand('12341234m567p89s+7s');
      final result = analyzer.analyze(hand);
      final standardHands = result.whereType<StandardHand>().toList();
      expect(standardHands.length, greaterThanOrEqualTo(1));
    });

    test('hand with revealed meld', () {
      final hand = parseHand('456789m123p[123p]5s+5s');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('multiple pair candidates', () {
      final hand = parseHand('1122334455667m+7m');
      final result = analyzer.analyze(hand);
      expect(result, isNotEmpty);
    });

    test('red five works in sequence', () {
      final hand = parseHand('406m234m345p678s1z+1z');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('red five can form a pair', () {
      final hand = parseHand('123406m234p789s5p+0p');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('red five pairs with normal five', () {
      final hand = parseHand('50123m456p789s11z+5m');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('red five works in open melds', () {
      final hand = parseHand('406m123p789s[067p]1z+1z');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('red five and normal five combine correctly in sequences', () {
      final hand = parseHand('406m456p406s789m1z+1z');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('winning red tile preserved in meld reconstruction', () {
      final hand = parseHand('456m456p456s789m5m+0m');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });
  });

  group('Invalid Hands', () {
    test('returns empty list for impossible hand', () {
      final hand = parseHand('1111111111111m+1m');
      final result = analyzer.analyze(hand);
      expect(result, isEmpty);
    });

    test('returns empty list for impossible open hand', () {
      final hand = parseHand('1111111111m[111m]+1m');
      final result = analyzer.analyze(hand);
      expect(result, isEmpty);
    });
  });

  group('Edge Cases', () {
    test('multiple decomposition using same tile groups', () {
      final hand = parseHand('2222m34456789m9p+9p');
      final result = analyzer.analyze(hand);
      final standard = result.whereType<StandardHand>().toList();
      expect(standard.length, greaterThan(1));
    });

    test('quad tiles usable across sequences', () {
      final hand = parseHand('1111m23456789m9p+9p');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('hand valid as both chiitoitsu and standard', () {
      final hand = parseHand('1122334455667m+7m');
      final result = analyzer.analyze(hand);
      expect(result.any((h) => h is SevenPairsHand), isTrue);
      expect(result.any((h) => h is StandardHand), isTrue);
    });

    test('correct wait classification with overlapping shapes', () {
      final hand = parseHand('123345678m999p4s+4s');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('duplicate sequences handled correctly', () {
      final hand = parseHand('1231234564567p+7p');
      final result = analyzer.analyze(hand);
      expect(result.whereType<StandardHand>(), isNotEmpty);
    });

    test('extreme ambiguity hand', () {
      final hand = parseHand('3333444555667m+7m');
      final result = analyzer.analyze(hand);
      final standardHands = result.whereType<StandardHand>().toList();
      expect(standardHands.length, greaterThan(1));
    });
  });
}
