import '/tile.dart';
import 'hand.dart';
import 'sequence.dart';
import 'structure.dart';

extension on Map<TileId, List<Tile>> {
  Tile take(
    TileId id,
    Tile winningTile, {
    required bool preferWinning,
  }) {
    final tiles = this[id]!;

    final index = preferWinning
        ? tiles.indexWhere((t) => identical(t, winningTile))
        : tiles.indexWhere((t) => !identical(t, winningTile));

    return tiles.removeAt(index != -1 ? index : 0);
  }
}

class HandAnalyzer {
  const HandAnalyzer();

  Iterable<HandStructure> analyze(Hand hand) sync* {
    if (_buildCounts(hand.tiles).any((e) => e > 4)) return;

    final tiles = [
      ...hand.concealed,
      hand.winningTile,
    ];

    final counts = _buildCounts(tiles);
    final groups = _groupTiles(tiles);

    final kokushi = _detectThirteenOrphans(hand, counts, groups);
    if (kokushi != null) yield kokushi;

    final chiitoi = _detectSevenPairs(hand, counts, groups);
    if (chiitoi != null) yield chiitoi;

    yield* _detectStandardHands(hand, counts, groups);
  }

  // -------------------------
  // Tile grouping
  // -------------------------

  Map<TileId, List<Tile>> _groupTiles(Iterable<Tile> tiles) {
    final map = <TileId, List<Tile>>{};

    for (final tile in tiles) {
      map.putIfAbsent(tile.id, () => []).add(tile);
    }

    return map;
  }

  List<int> _buildCounts(Iterable<Tile> tiles) {
    final counts = List<int>.filled(34, 0);

    for (final tile in tiles) {
      counts[tile.id.index]++;
    }

    return counts;
  }

  // -------------------------
  // Seven pairs
  // -------------------------

  SevenPairsHand? _detectSevenPairs(
    Hand hand,
    List<int> counts,
    Map<TileId, List<Tile>> groups,
  ) {
    if (hand.revealed.any((m) => m.isNotEmpty)) return null;

    int pairs = 0;

    for (final c in counts) {
      if (c == 2) {
        pairs++;
      } else if (c != 0) {
        return null;
      }
    }

    if (pairs != 7) return null;

    return SevenPairsHand(
      pairs: [
        for (final g in groups.values) PairSequence(tiles: g.toList()),
      ],
      winningTile: hand.winningTile,
    );
  }

  // -------------------------
  // Kokushi
  // -------------------------

  static const _orphans = [0, 8, 9, 17, 18, 26, 27, 28, 29, 30, 31, 32, 33];

  ThirteenOrphansHand? _detectThirteenOrphans(
    Hand hand,
    List<int> counts,
    Map<TileId, List<Tile>> groups,
  ) {
    if (hand.revealed.any((m) => m.isNotEmpty)) return null;

    int pairIndex = -1;

    for (final i in _orphans) {
      if (counts[i] == 0) return null;
      if (counts[i] == 2) pairIndex = i;
    }

    if (pairIndex == -1) return null;

    final singles = groups.values.where((e) => e.length == 1).map((e) => e.first);
    final pair = PairSequence(
      tiles: groups.values.where((e) => e.length == 2).single,
    );
    return ThirteenOrphansHand(
      singles: singles,
      pair: pair,
      winningTile: hand.winningTile,
    );
  }

  // -------------------------
  // Standard hands
  // -------------------------

  Iterable<StandardHand> _detectStandardHands(
    Hand hand,
    List<int> counts,
    Map<TileId, List<Tile>> groups,
  ) sync* {
    for (int i = 0; i < 34; i++) {
      if (counts[i] < 2) continue;

      final working = [...counts];
      working[i] -= 2;

      final melds = <List<int>>[];

      for (final result in _searchMelds(working, melds, hand.revealed.length)) {
        for (final pairPrefersWinning in const [true, false]) {
          final tilePool = {
            for (final e in groups.entries) e.key: [...e.value],
          };

          final pairId = TileId.byIndex[i];

          final pair = PairSequence(
            tiles: [
              tilePool.take(pairId, hand.winningTile, preferWinning: pairPrefersWinning),
              tilePool.take(pairId, hand.winningTile, preferWinning: pairPrefersWinning),
            ],
          );

          final meldSequences = <MeldSequence>[];

          for (final meld in result) {
            if (meld[0] == meld[1]) {
              final id = TileId.byIndex[meld[0]];

              meldSequences.add(
                ClosedPonSequence(
                  tiles: [
                    tilePool.take(id, hand.winningTile, preferWinning: !pairPrefersWinning),
                    tilePool.take(id, hand.winningTile, preferWinning: !pairPrefersWinning),
                    tilePool.take(id, hand.winningTile, preferWinning: !pairPrefersWinning),
                  ],
                ),
              );
            } else {
              final a = TileId.byIndex[meld[0]];
              final b = TileId.byIndex[meld[1]];
              final c = TileId.byIndex[meld[2]];

              meldSequences.add(
                ClosedChiiSequence(
                  tiles: [
                    tilePool.take(a, hand.winningTile, preferWinning: !pairPrefersWinning) as Tile<SuitTileId>,
                    tilePool.take(b, hand.winningTile, preferWinning: !pairPrefersWinning) as Tile<SuitTileId>,
                    tilePool.take(c, hand.winningTile, preferWinning: !pairPrefersWinning) as Tile<SuitTileId>,
                  ],
                ),
              );
            }
          }

          yield StandardHand(
            melds: [...hand.revealed, ...meldSequences],
            pair: pair,
            winningTile: hand.winningTile,
          );
        }
      }
    }
  }

  Iterable<List<List<int>>> _searchMelds(
    List<int> counts,
    List<List<int>> melds,
    int revealed,
  ) sync* {
    final i = counts.indexWhere((c) => c > 0);

    if (i == -1) {
      if (revealed + melds.length == 4) yield List.from(melds);
      return;
    }

    if (counts[i] >= 3) {
      counts[i] -= 3;

      melds.add([i, i, i]);

      yield* _searchMelds(counts, melds, revealed);

      melds.removeLast();
      counts[i] += 3;
    }

    if (i < 27 && i % 9 <= 6 && counts[i + 1] > 0 && counts[i + 2] > 0) {
      counts[i]--;
      counts[i + 1]--;
      counts[i + 2]--;

      melds.add([i, i + 1, i + 2]);

      yield* _searchMelds(counts, melds, revealed);

      melds.removeLast();

      counts[i]++;
      counts[i + 1]++;
      counts[i + 2]++;
    }
  }
}
