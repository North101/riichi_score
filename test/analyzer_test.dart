import 'package:riichi_score/analyzer.dart';
import 'package:riichi_score/round.dart';
import 'package:riichi_score/han.dart';
import 'package:riichi_score/hand.dart';
import 'package:riichi_score/seat.dart';
import 'package:riichi_score/rules.dart';
import 'package:riichi_score/tile.dart';
import 'package:riichi_score/win.dart';
import 'package:test/test.dart';

void main() {
  const rules = Rules();
  const analyzer = MahjongAnalyzer();

  group('MahjongAnalyzer', () {
    test('returns null for empty hand', () {
      final hand = parseHand('+1m');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNull);
    });

    test('detects standard hand correctly', () {
      final hand = parseHand('123456789m234p1z+1z');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.han.value, greaterThan(0));
      expect(result.fu.value, greaterThan(0));
      expect(result.score.payment.total, greaterThan(0));
    });

    test('detects seven pairs hand', () {
      final hand = parseHand('112233445566p1z+1z');
      final results = analyzer.analyzeStructures(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
        structures: analyzer.handAnalyzer.analyze(hand),
      );
      expect(results, isNotEmpty);
      expect(results.any((r) => r.context.structure is SevenPairsHand), isTrue);
    });

    test('detects thirteen orphans hand', () {
      final hand = parseHand('19m19p19s1234567z+1m');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.context.structure is ThirteenOrphansHand, isTrue);
    });

    test('calculates red fives correctly', () {
      final hand = parseHand('123406789m234p1z+1z');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(
        result!.han.items
            .whereType<DoraResult>()
            .where((e) => e.dora == .akaDora)
            .fold(0, (sum, value) => sum + value.value),
        equals(1),
      );
    });

    test('honbaCount points added correctly for ron', () {
      final hand = parseHand('123456789m234p1z+1z');
      final result = analyzer.analyze(
        rules: const Rules(honbaPoints: 100),
        round: const Round(wind: Wind.east, honbaCount: 2),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.score.payment.pointsFromHonba, 600);
    });

    test('honbaCount points added correctly for tsumo', () {
      final hand = parseHand('123456789m234p1z+1z');
      final result = analyzer.analyze(
        rules: const Rules(honbaPoints: 100),
        round: const Round(wind: Wind.east, honbaCount: 2),
        seat: const Seat(wind: Wind.east, agari: Tsumo()),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.score.payment.pointsFromHonba, 200);
    });

    test('chooses best structure when multiple possible', () {
      final hand = parseHand('12341234m567p89s+7s');
      final results = analyzer.analyzeStructures(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
        structures: analyzer.handAnalyzer.analyze(hand),
      );
      expect(results, isNotEmpty);

      final best = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(best, isNotNull);
      expect(
        best?.score.payment.total,
        equals(results.reduce((a, b) => a.compareTo(b) > 0 ? a : b).score.payment.total),
      );
    });

    test('handles impossible hands', () {
      final hand = parseHand('1111111111111m+1m');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNull);
    });
  });

  group('Yakuman and Double Yakuman', () {
    test('detects Suuankou Tanki', () {
      final hand = parseHand('111222333444m1z+1z');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.han.items.whereType<YakuResult>().any((y) => y.yaku == YakuType.suuankou), isTrue);
      expect(result.han.value, equals(26));
    });

    test('detects Junsei Chuuren Poutou', () {
      final hand = parseHand('1112345678999m+5m');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.han.items.whereType<YakuResult>().any((y) => y.yaku == YakuType.chuurenPoutou), isTrue);
      expect(result.han.value, equals(26));
    });

    test('normal Chuuren Poutou is single yakuman', () {
      final hand = parseHand('1111234678999m+5m');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.han.items.whereType<YakuResult>().any((y) => y.yaku == YakuType.chuurenPoutou), isTrue);
      expect(result.han.value, equals(13));
    });
  });

  group('Dealer vs Non-dealer', () {
    test('dealer hand increases score correctly', () {
      final hand = parseHand('123456789m234p1z+1z');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(wind: Wind.south, agari: Tsumo()),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(
        result!.score.payment.payments[Wind.east]!,
        greaterThan(result.score.payment.payments[Wind.west]!),
      );
    });

    test('non-dealer tsumo payment correct', () {
      final hand = parseHand('123456789m234p1z+1z');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(wind: Wind.south, agari: Tsumo()),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(result!.score.payment.payments[Wind.east]!, greaterThan(0));
      expect(result.score.payment.payments[Wind.west]!, greaterThan(0));
    });
  });

  group('Multiple structures', () {
    test('chooses highest scoring structure', () {
      final hand = parseHand('12341234m567p89s+7s');
      final structures = analyzer.handAnalyzer.analyze(hand).toList();

      final results = analyzer.analyzeStructures(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
        structures: structures,
      );

      final best = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );

      expect(best, isNotNull);
      expect(
        best!.score.payment.total,
        equals(results.map((r) => r.score.payment.total).reduce((a, b) => a > b ? a : b)),
      );
    });
  });

  group('Extreme hands', () {
    test('handles multiple red fives correctly', () {
      final hand = parseHand('334405m440566p1z+1z');
      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );
      expect(result, isNotNull);
      expect(
        result!.han.items
            .whereType<DoraResult>()
            .where((e) => e.dora == .akaDora)
            .fold(0, (sum, value) => sum + value.value),
        equals(2),
      );
    });
  });
}
