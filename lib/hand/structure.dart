import '/tile.dart';
import '/util.dart';
import 'sequence.dart';

sealed class HandStructure {
  const HandStructure();

  Tile get winningTile;

  Iterable<Tile> get tiles;

  bool get isValid;

  bool get isClosed;

  bool get hasHonor => tiles.any((tile) => tile.id is HonorTileId);

  bool get isSingleSuit {
    final suitTiles = tiles.map((e) => e.id).whereType<SuitTileId>();
    if (suitTiles.isEmpty) return false;

    final suit = suitTiles.first.suit;
    return suitTiles.every((tile) => tile.suit == suit);
  }

  bool get isHalfFlush => isSingleSuit && hasHonor;
  bool get isFlush => isSingleSuit && !hasHonor;
}

class StandardHand extends HandStructure {
  StandardHand({
    required this.melds,
    required this.pair,
    required this.winningTile,
  }) : assert(melds.length == 4),
       assert(melds.expand((e) => e.tiles).followedBy(pair).contains(winningTile));

  final Iterable<MeldSequence> melds;
  final PairSequence pair;
  @override
  final Tile winningTile;

  @override
  Iterable<Tile> get tiles => melds.expand((e) => e.tiles).followedBy(pair);

  @override
  bool get isValid => melds.length == 4;

  @override
  bool get isClosed => melds.every((meld) => meld.isClosed);

  bool get isAllSequences => melds.every((meld) => meld is ChiiSequence);

  bool get isAllTriplets => melds.every((meld) => meld is PonSequence);

  Set<Suit> get suits => {
    for (final tile in tiles)
      if (tile.id case SuitTileId(:final suit)) suit,
  };

  @override
  String toString() => '${melds.join()}$pair';
}

class SevenPairsHand extends HandStructure {
  SevenPairsHand({
    required this.pairs,
    required this.winningTile,
  }) : assert(pairs.length == 7),
       assert(pairs.expand((e) => e.tiles).contains(winningTile));

  final Iterable<PairSequence> pairs;

  @override
  final Tile winningTile;

  @override
  Iterable<Tile> get tiles => pairs.expand((e) => e.tiles);

  @override
  final bool isClosed = true;

  @override
  bool get isValid => pairs.length == 7;

  @override
  String toString() => pairs.join();
}

class ThirteenOrphansHand extends HandStructure {
  ThirteenOrphansHand({
    required this.singles,
    required this.pair,
    required this.winningTile,
  }) : assert(singles.length == 12),
       assert(singles.followedBy(pair).contains(winningTile));

  final Iterable<Tile> singles;
  final PairSequence pair;
  @override
  final Tile winningTile;

  @override
  Iterable<Tile> get tiles => singles.followedBy(pair);

  @override
  bool get isClosed => true;

  @override
  bool get isValid {
    if (tiles.length != 14) return false;

    final counts = <TileId, int>{};
    for (final tile in tiles) {
      counts.inc(tile.id, 1);
    }

    if (counts.length != 13) return false;
    if (counts.entries.any((e) => e.value > 2 || !e.key.isTerminalOrHonor)) return false;

    final pairCount = counts.values.where((e) => e == 2).length;
    return pairCount == 1;
  }

  @override
  String toString() => '${singles.join()}${pair.join()}';
}
