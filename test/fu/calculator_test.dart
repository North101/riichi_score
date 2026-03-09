import 'package:riichi_score/context.dart';
import 'package:riichi_score/fu.dart';
import 'package:riichi_score/round.dart';
import 'package:riichi_score/hand.dart';
import 'package:riichi_score/seat.dart';
import 'package:riichi_score/rules.dart';
import 'package:riichi_score/tile.dart';
import 'package:riichi_score/win.dart';
import 'package:test/test.dart';

import '../helpers/tile_factory.dart';

void main() {
  const calculator = FuCalculator();

  group('FuCalculator', () {
    test('seven pairs hand returns sevenPairs fu', () {
      final hand = SevenPairsHand(
        pairs: [
          PairSequence.from(man1),
          PairSequence.from(pin2),
          PairSequence.from(sou3),
          PairSequence.from(man4),
          PairSequence.from(pin5),
          PairSequence.from(sou5),
          PairSequence.from(man7),
        ],
        winningTile: man7,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(
          wind: Wind.east,
        ),
        seat: const Seat(
          agari: Ron(from: Wind.south),
          wind: Wind.east,
          riichi: null,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final breakdown = calculator.calculate(context);
      expect(breakdown.items, contains(FuReason.sevenPairs));
      expect(breakdown.value, equals(25));
    });

    test('pinfu tsumo returns base fu only', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(man7),
          ClosedChiiSequence.from(man1),
        ],
        pair: PairSequence.from(west),
        winningTile: man4,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(
          wind: Wind.east,
        ),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
          riichi: null,
        ),
        structure: hand,
        waits: const {Ryanmen()},
      );

      final breakdown = calculator.calculate(context);
      expect(breakdown.items, contains(FuReason.base));
      expect(breakdown.items, isNot(contains(FuReason.closedRon)));
      expect(breakdown.value, equals(20));
    });

    test('closed ron adds closedRon fu', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(man1),
          ClosedChiiSequence.from(pin2),
          ClosedChiiSequence.from(sou3),
          ClosedChiiSequence.from(man4),
        ],
        pair: PairSequence.from(red),
        winningTile: red,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(
          wind: Wind.south,
        ),
        seat: const Seat(
          agari: Ron(from: Wind.south),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final breakdown = calculator.calculate(context);
      expect(breakdown.items, contains(FuReason.closedRon));
      expect(breakdown.items, contains(FuReason.tankiWait));
      expect(breakdown.items, contains(FuReason.tripletTerminalClosed));
    });

    test('dragon pair adds valuePair fu', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(pin1),
          ClosedChiiSequence.from(sou2),
        ],
        pair: PairSequence.from(green),
        winningTile: green,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(
          wind: Wind.south,
        ),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final breakdown = calculator.calculate(context);
      expect(breakdown.items, contains(FuReason.valuePair));
    });

    test('round wind or seat wind pair adds valuePair fu', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(pin1),
          ClosedChiiSequence.from(sou2),
        ],
        pair: PairSequence.from(east),
        winningTile: east,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.east),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final breakdown = calculator.calculate(context);
      // valuePair counted once for each match (round or seat wind)
      expect(breakdown.items.where((r) => r == FuReason.valuePair).length, 2);
    });
  });

  group('FuCalculator - meld fu', () {
    test('closed simple pon adds tripletSimpleClosed', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(man5),
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(man7),
        ],
        pair: PairSequence.from(man2),
        winningTile: man2,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final result = calculator.calculate(context);

      expect(result.items, contains(FuReason.tripletSimpleClosed));
    });

    test('closed terminal pon adds tripletTerminalClosed', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(man1),
          ClosedChiiSequence.from(man2),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(man7),
        ],
        pair: PairSequence.from(man3),
        winningTile: man3,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final result = calculator.calculate(context);

      expect(result.items, contains(FuReason.tripletTerminalClosed));
    });
  });

  group('FuCalculator - wait fu', () {
    test('tanki wait adds fu', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(man7),
          ClosedChiiSequence.from(pin1),
        ],
        pair: PairSequence.from(red),
        winningTile: red,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final result = calculator.calculate(context);

      expect(result.items, contains(FuReason.tankiWait));
    });

    test('kanchan wait adds fu', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(man7),
          ClosedChiiSequence.from(pin1),
        ],
        pair: PairSequence.from(man2),
        winningTile: man2,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Kanchan()},
      );

      final result = calculator.calculate(context);

      expect(result.items, contains(FuReason.kanchanWait));
    });
  });

  group('FuCalculator - value pair', () {
    test('dragon pair adds valuePair', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(pin1),
          ClosedChiiSequence.from(sou2),
        ],
        pair: PairSequence.from(green),
        winningTile: green,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final result = calculator.calculate(context);

      expect(result.items, contains(FuReason.valuePair));
    });

    test('round wind pair adds valuePair', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(pin1),
          ClosedChiiSequence.from(sou2),
        ],
        pair: PairSequence.from(east),
        winningTile: east,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final result = calculator.calculate(context);

      expect(result.items, contains(FuReason.valuePair));
    });
  });

  group('FuCalculator - pinfu interaction', () {
    test('pinfu tsumo only base fu', () {
      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          agari: Tsumo(),
          wind: Wind.east,
        ),
        structure: StandardHand(
          melds: [
            ClosedChiiSequence.from(man1),
            ClosedChiiSequence.from(man4),
            ClosedChiiSequence.from(man7),
            ClosedChiiSequence.from(pin1),
          ],
          pair: PairSequence.from(sou2),
          winningTile: sou2,
        ),
        waits: const {Ryanmen()},
      );

      final result = calculator.calculate(context);

      expect(result.items, equals([FuReason.base]));
      expect(result.value, equals(20));
    });
  });
}
