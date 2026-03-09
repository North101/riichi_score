import 'package:riichi_score/context.dart';
import 'package:riichi_score/round.dart';
import 'package:riichi_score/hand.dart';
import 'package:riichi_score/seat.dart';
import 'package:riichi_score/rules.dart';
import 'package:riichi_score/tile.dart';
import 'package:riichi_score/win.dart';
import 'package:riichi_score/han.dart';
import 'package:test/test.dart';

import '../helpers/tile_factory.dart';

void main() {
  group('Basic yaku', () {
    test('menzen tsumo', () {
      final hand = _sequenceHand();

      final context = _context(
        structure: hand,
        agari: const Tsumo(),
      );

      final yaku = const MenzenTsumoYaku();

      expect(yaku.matches(context), true);

      final result = yaku.evaluate(context).single;
      expect(result.value, 1);
      expect(result.yaku, YakuType.menzenTsumo);
    });

    test('riichi', () {
      final context = _context(
        riichi: const Riichi(),
      );

      final yaku = const RiichiYaku();

      expect(yaku.matches(context), true);
      expect(yaku.evaluate(context).single.value, 1);
    });

    test('double riichi', () {
      final context = _context(
        riichi: const DoubleRiichi(),
      );

      final yaku = const DoubleRiichiYaku();

      expect(yaku.matches(context), true);
      expect(yaku.evaluate(context).single.value, 2);
    });

    test('ippatsu', () {
      final context = _context(
        riichi: const Riichi(ippatsu: true),
      );

      final yaku = const IppatsuYaku();

      expect(yaku.matches(context), true);
      expect(yaku.evaluate(context).single.value, 1);
    });
  });

  group('Composition yaku', () {
    test('tanyao', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man2),
          ClosedChiiSequence.from(man5),
          ClosedChiiSequence.from(pin3),
          ClosedChiiSequence.from(sou4),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = _context(
        structure: hand,
        waits: {const Ryanmen()},
      );

      expect(const TanyaoYaku().matches(context), true);
    });

    test('tanyao fails with terminal', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1), // contains terminal
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(pin2),
          ClosedChiiSequence.from(sou3),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = _context(
        structure: hand,
        waits: {const Ryanmen()},
      );

      expect(const TanyaoYaku().matches(context), false);
    });

    test('pinfu', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(pin2),
          ClosedChiiSequence.from(sou3),
        ],
        pair: PairSequence.from(pin7),
        winningTile: pin7,
      );

      final context = _context(
        structure: hand,
        waits: {const Ryanmen()},
      );

      expect(const PinfuYaku().matches(context), true);
    });

    test('pinfu does not apply to open hand', () {
      final hand = StandardHand(
        melds: [
          OpenChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(pin2),
          ClosedChiiSequence.from(sou3),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = _context(
        structure: hand,
        waits: {const Ryanmen()},
      );

      expect(const PinfuYaku().matches(context), false);
    });

    test('iipeikou', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(pin3),
          ClosedChiiSequence.from(sou4),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = _context(
        structure: hand,
        waits: {const Ryanmen()},
      );

      expect(const IipeikouYaku().matches(context), true);
    });
  });

  test('iipeikou fails if hand open', () {
    final hand = StandardHand(
      melds: [
        OpenChiiSequence.from(man1),
        ClosedChiiSequence.from(man1),
        ClosedChiiSequence.from(pin3),
        ClosedChiiSequence.from(sou4),
      ],
      pair: PairSequence.from(pin6),
      winningTile: pin6,
    );

    final context = _context(
      structure: hand,
      waits: {const Ryanmen()},
    );

    expect(const IipeikouYaku().matches(context), false);
  });

  group('Triplet yaku', () {
    test('toitoi', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(man1),
          ClosedPonSequence.from(man3),
          ClosedPonSequence.from(pin5),
          ClosedPonSequence.from(sou7),
        ],
        pair: PairSequence.from(red),
        winningTile: red,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const ToitoiYaku().matches(context), true);
    });

    test('toitoi fails with sequence', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(man1),
          ClosedPonSequence.from(man3),
          ClosedPonSequence.from(pin5),
          ClosedChiiSequence.from(sou3), // sequence
        ],
        pair: PairSequence.from(red),
        winningTile: red,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const ToitoiYaku().matches(context), false);
    });

    test('sanankou', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(man1),
          ClosedPonSequence.from(pin3),
          ClosedPonSequence.from(sou7),
          OpenPonSequence.from(red),
        ],
        pair: PairSequence.from(man2),
        winningTile: man2,
      );

      final context = _context(
        structure: hand,
        waits: {const Tanki()},
      );

      expect(const SanankouYaku().matches(context), true);
    });

    test('sanankou with ron', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(man1),
          ClosedPonSequence.from(pin3),
          ClosedPonSequence.from(sou7),
          ClosedChiiSequence.from(man4),
        ],
        pair: PairSequence.from(pin2),
        winningTile: pin2,
      );

      final context = _context(
        structure: hand,
        waits: {const Shanpon()},
        agari: const Ron(from: Wind.south),
      );

      expect(const SanankouYaku().matches(context), true);
    });
  });

  group('Flush yaku', () {
    test('honitsu', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedPonSequence.from(man7),
          ClosedPonSequence.from(red),
        ],
        pair: PairSequence.from(man2),
        winningTile: man2,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const HonitsuYaku().matches(context), true);
    });

    test('chinitsu', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedPonSequence.from(man7),
          ClosedPonSequence.from(man9),
        ],
        pair: PairSequence.from(man2),
        winningTile: man2,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const ChinitsuYaku().matches(context), true);
    });

    test('honitsu fails without honours', () {
      final hand = StandardHand(
        melds: [
          ClosedChiiSequence.from(man1),
          ClosedChiiSequence.from(man4),
          ClosedChiiSequence.from(man7),
          ClosedPonSequence.from(man9),
        ],
        pair: PairSequence.from(man2),
        winningTile: man2,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const HonitsuYaku().matches(context), false);
    });
  });

  group('Yakuhai', () {
    test('yakuhai seat wind', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(east),
          ClosedChiiSequence.from(man2),
          ClosedChiiSequence.from(pin3),
          ClosedChiiSequence.from(sou4),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          wind: Wind.east,
          agari: Tsumo(),
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const YakuhaiYaku().matches(context), true);
    });

    test('yakuhai round wind', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(south),
          ClosedChiiSequence.from(man2),
          ClosedChiiSequence.from(pin3),
          ClosedChiiSequence.from(sou4),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.south),
        seat: const Seat(
          wind: Wind.east,
          agari: Tsumo(),
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const YakuhaiYaku().matches(context), true);
    });

    test('yakuhai seat+round wind', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(east),
          ClosedChiiSequence.from(man2),
          ClosedChiiSequence.from(pin3),
          ClosedChiiSequence.from(sou4),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = Context(
        rules: const Rules(),
        round: const Round(wind: Wind.east),
        seat: const Seat(
          wind: Wind.east,
          agari: Tsumo(),
        ),
        structure: hand,
        waits: const {Tanki()},
      );

      final yaku = const YakuhaiYaku();
      final result = yaku.evaluate(context);

      expect(result.length, 2);
    });

    test('multiple yakuhai stack', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(red),
          ClosedPonSequence.from(green),
          ClosedChiiSequence.from(man2),
          ClosedChiiSequence.from(pin3),
        ],
        pair: PairSequence.from(pin6),
        winningTile: pin6,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      final yaku = const YakuhaiYaku();
      final result = yaku.evaluate(context);

      expect(result.length, 2);
    });
  });

  test('chiitoitsu fails with melds', () {
    final hand = _sequenceHand();

    final context = _context(structure: hand);

    expect(const ChiitoitsuYaku().matches(context), false);
  });

  group('Yakuman', () {
    test('daisangen', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(white),
          ClosedPonSequence.from(green),
          ClosedPonSequence.from(red),
          ClosedChiiSequence.from(man1),
        ],
        pair: PairSequence.from(man2),
        winningTile: man2,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const DaisangenYaku().matches(context), true);
    });

    test('tsuuiisou', () {
      final hand = StandardHand(
        melds: [
          ClosedPonSequence.from(white),
          ClosedPonSequence.from(green),
          ClosedPonSequence.from(east),
          ClosedPonSequence.from(south),
        ],
        pair: PairSequence.from(west),
        winningTile: west,
      );

      final context = _context(
        structure: hand,
        waits: const {Tanki()},
      );

      expect(const TsuuiisouYaku().matches(context), true);
    });

    test('kokushi musou', () {
      final terminalOrHonorTiles = tiles.where((e) => e.isTerminalOrHonor);
      final context = _context(
        structure: ThirteenOrphansHand(
          singles: terminalOrHonorTiles.take(12),
          pair: PairSequence.from(terminalOrHonorTiles.last),
          winningTile: terminalOrHonorTiles.last,
        ),
        waits: const {KokushiMusoJusanmen()},
      );

      expect(const KokushiMusouYaku().matches(context), true);
    });

    test('kokushi 13 wait', () {
      final terminalOrHonorTiles = tiles.where((e) => e.isTerminalOrHonor);
      final context = _context(
        structure: ThirteenOrphansHand(
          singles: terminalOrHonorTiles.take(12),
          pair: PairSequence.from(terminalOrHonorTiles.last),
          winningTile: terminalOrHonorTiles.last,
        ),
        waits: const {KokushiMusoJusanmen()},
      );

      final result = const KokushiMusouYaku().evaluate(context);

      expect(result.single.value, 26);
    });
  });
}

Context _context({
  HandStructure? structure,
  Set<Wait>? waits,
  Agari agari = const Tsumo(),
  Riichi? riichi,
}) {
  return Context(
    rules: const Rules(),
    round: const Round(wind: Wind.east),
    seat: Seat(
      agari: agari,
      wind: Wind.south,
      riichi: riichi,
    ),
    structure: structure ?? _sequenceHand(),
    waits: waits ?? const {},
  );
}

StandardHand _sequenceHand() {
  return StandardHand(
    melds: [
      ClosedChiiSequence.from(man1),
      ClosedChiiSequence.from(man4),
      ClosedChiiSequence.from(pin2),
      ClosedChiiSequence.from(sou3),
    ],
    pair: PairSequence.from(man2),
    winningTile: man2,
  );
}
