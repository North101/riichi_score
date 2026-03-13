import 'package:riichi_score/analyzer.dart';
import 'package:riichi_score/round.dart';
import 'package:riichi_score/han.dart';
import 'package:riichi_score/hand.dart';
import 'package:riichi_score/score.dart';
import 'package:riichi_score/seat.dart';
import 'package:riichi_score/rules.dart';
import 'package:riichi_score/tile.dart';
import 'package:riichi_score/win.dart';
import 'package:test/test.dart';

void expectScore(
  HandResult result, {
  required int han,
  int? fu,
  Limit? limit,
  required int total,
}) {
  expect(result.han.value, equals(han));
  if (fu != null) {
    expect(result.fu.value, equals(fu));
  }
  expect(result.score.limit, equals(limit));
  expect(result.score.payment.total, equals(total));
}

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
      final hand = parseHand('12456m234789p99m+3m');

      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
          riichi: Riichi(),
        ),
        hand: hand,
      );

      expect(result, isNotNull);

      expectScore(
        result!,
        han: 1,
        fu: 40,
        limit: null,
        total: 2000,
      );
    });

    test('detects seven pairs hand', () {
      final hand = parseHand('1122m3344p5566s7z+7z');

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

      expectScore(
        result!,
        han: 2,
        fu: 25,
        limit: null,
        total: 2400,
      );
    });

    test('detects thirteen orphans hand', () {
      final hand = parseHand('119m19p19s123456z+7z');

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

      expectScore(
        result!,
        han: 13,
        fu: 0,
        limit: Limit.yakuman,
        total: 48000,
      );
    });

    test('calculates red fives correctly', () {
      final hand = parseHand('111z123m234p4445s+0s');

      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.south),
        seat: const Seat(
          wind: Wind.east,
          agari: Ron(from: Wind.south),
        ),
        hand: hand,
      );

      expect(result, isNotNull);

      expectScore(
        result!,
        han: 2, // yakuhai + aka dora
        fu: 50,
        limit: null,
        total: 4800,
      );
    });

    test('honbaCount points added correctly for ron', () {
      final hand = parseHand('234456m678s234p6m+6m');

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

      expectScore(
        result!,
        han: 2,
        fu: 30,
        limit: null,
        total: 3500,
      );

      expect(result.score.payment.pointsFromHonba, equals(600));
    });

    test('honbaCount points added correctly for tsumo', () {
      final hand = parseHand('123456789m234p1z+1z');

      final result = analyzer.analyze(
        rules: const Rules(honbaPoints: 100),
        round: const Round(wind: Wind.east, honbaCount: 2),
        seat: const Seat(
          wind: Wind.east,
          agari: Tsumo(),
        ),
        hand: hand,
      );

      expect(result, isNotNull);

      expect(result!.score.payment.pointsFromHonba, equals(200));
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

      expectScore(
        result!,
        han: 26,
        limit: Limit.doubleYakuman,
        total: 96000,
      );
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

      expectScore(
        result!,
        han: 26,
        limit: Limit.doubleYakuman,
        total: 96000,
      );
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

      expectScore(
        result!,
        han: 13,
        limit: Limit.yakuman,
        total: 48000,
      );
    });
  });

  group('Dealer vs Non-dealer', () {
    test('dealer hand increases score correctly', () {
      final hand = parseHand('123456789m234p1z+1z');

      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Tsumo(),
        ),
        hand: hand,
      );

      expect(result, isNotNull);

      expect(result!.score.payment.payments[Wind.south]!, equals(2000));
      expect(result.score.payment.payments[Wind.west]!, equals(2000));
      expect(result.score.payment.payments[Wind.north]!, equals(2000));
    });

    test('non-dealer tsumo payment correct', () {
      final hand = parseHand('123456789m234p1z+1z');

      final result = analyzer.analyze(
        rules: rules,
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.south,
          agari: Tsumo(),
        ),
        hand: hand,
      );

      expect(result, isNotNull);

      expect(result!.score.payment.payments[Wind.east]!, equals(2000));
      expect(result.score.payment.payments[Wind.west]!, equals(1000));
      expect(result.score.payment.payments[Wind.north]!, equals(1000));
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

      final dora = result!.han.items
          .whereType<DoraResult>()
          .where((e) => e.dora == .akaDora)
          .fold(0, (sum, value) => sum + value.value);

      expect(dora, equals(2));
    });
  });
}
