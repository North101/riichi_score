import 'package:riichi_score/dora.dart';
import 'package:riichi_score/round.dart';
import 'package:riichi_score/tile.dart';
import 'package:test/test.dart';

import '../helpers/tile_factory.dart';

void main() {
  group('DoraCount', () {
    test('returns fixed dora counts', () {
      const dora = DoraCount(
        dora: 3,
        uraDora: 2,
      );

      const tiles = [
        man1,
        man2,
        man3,
      ];

      expect(dora.countDora(tiles), 3);
      expect(dora.countUraDora(tiles), 2);
    });

    test('counts aka dora automatically', () {
      const dora = DoraCount(
        dora: 0,
        uraDora: 0,
      );

      const tiles = [
        manRed5,
        pinRed5,
        souRed5,
        man1,
      ];

      expect(dora.countAkaDora(tiles), 3);
    });

    test('aka dora override works', () {
      const dora = DoraCount(
        dora: 0,
        uraDora: 0,
        akaDora: 5,
      );

      const tiles = [
        manRed5,
      ];

      expect(dora.countAkaDora(tiles), 5);
    });
  });

  group('DoraTiles', () {
    test('counts single dora indicator', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man3, // indicator 3m -> dora 4m
        ],
        uraDora: const [],
      );

      const tiles = [
        man4,
        man4,
        man5,
      ];

      expect(dora.countDora(tiles), 2);
    });

    test('counts multiple indicators', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man3,
          man3,
        ],
        uraDora: const [],
      );

      const tiles = [
        man4,
        man4,
      ];

      expect(dora.countDora(tiles), 4);
    });

    test('counts ura dora', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [],
        uraDora: const [
          pin6, // indicator 6p -> dora 7p
        ],
      );

      const tiles = [
        pin7,
        pin7,
        pin8,
      ];

      expect(dora.countUraDora(tiles), 2);
    });

    test('handles mixed tiles correctly', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man3, // -> 4m
          pin4, // -> 5p
        ],
        uraDora: const [],
      );

      const tiles = [
        man4,
        pin5,
        pin5,
        sou3,
      ];

      expect(dora.countDora(tiles), 3);
    });

    test('returns zero when no match', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man3,
        ],
        uraDora: const [],
      );

      const tiles = [
        pin1,
        pin2,
        pin3,
      ];

      expect(dora.countDora(tiles), 0);
    });

    group('Aka Dora', () {
      test('counts red fives', () {
        final dora = DoraTiles.fromIndicatorTiles(
          dora: const [],
          uraDora: const [],
        );

        const tiles = [
          manRed5,
          pinRed5,
          souRed5,
          man5,
        ];

        expect(dora.countAkaDora(tiles), 3);
      });
    });
  });

  group('round', () {
    test('delegates dora counting', () {
      const dora = DoraCount(
        dora: 2,
        uraDora: 1,
      );

      const round = Round(
        wind: Wind.east,
        dora: dora,
      );

      const tiles = [
        man1,
      ];

      expect(round.countDora(tiles), 2);
      expect(round.countUraDora(tiles), 1);
    });

    test('delegates aka dora counting', () {
      const round = Round(
        wind: Wind.east,
      );

      const tiles = [
        manRed5,
        manRed5,
        man5,
      ];

      expect(round.countAkaDora(tiles), 2);
    });
  });

  group('Dora indicator wrap-around', () {
    test('indicator multiplicity stacks', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man3, // two indicators -> 4m
          man3, // two indicators -> 4m
        ],
        uraDora: const [],
      );

      const tiles = [
        man4,
        man4,
        man4,
      ];

      expect(dora.countDora(tiles), 6);
    });

    test('suit wrap-around indicator', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man9, // indicator 9m → dora 1m
        ],
        uraDora: const [],
      );

      const tiles = [
        man1,
        man1,
        man2,
      ];

      expect(dora.countDora(tiles), 2);
    });

    test('wind indicator cycle', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          north, // indicator North → East
        ],
        uraDora: const [],
      );

      const tiles = [
        east,
        east,
        south,
      ];

      expect(dora.countDora(tiles), 2);
    });

    test('dragon indicator cycle', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          red, // indicator Red → White
        ],
        uraDora: const [],
      );

      const tiles = [
        white,
        white,
        green,
      ];

      expect(dora.countDora(tiles), 2);
    });

    test('mixed wraparound indicators', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man9, // → 1m
          north, // → East
          red, // → White
        ],
        uraDora: const [],
      );

      const tiles = <Tile>[
        man1,
        east,
        white,
        white,
      ];

      expect(dora.countDora(tiles), 4);
    });

    test('red tile still counts as dora', () {
      final dora = DoraTiles.fromIndicatorTiles(
        dora: const [
          man4, // indicator 4m → 5m
        ],
        uraDora: const [],
      );

      const tiles = [
        manRed5,
        man5,
      ];

      expect(dora.countDora(tiles), 2);
      expect(dora.countAkaDora(tiles), 1);
    });
  });
}
