import '/tile.dart';
import '/util.dart';

abstract class Dora {
  const Dora();

  int countDora(Iterable<Tile> tiles);

  int countUraDora(Iterable<Tile> tiles);

  int countAkaDora(Iterable<Tile> tiles) => //
      tiles.fold(0, (sum, tile) => sum + (tile.isRed ? 1 : 0));
}

class DoraCount extends Dora {
  const DoraCount({
    required this.dora,
    required this.uraDora,
    this.akaDora,
  });

  final int dora;
  final int uraDora;
  final int? akaDora;

  @override
  int countDora(Iterable<Tile> tiles) => dora;

  @override
  int countUraDora(Iterable<Tile> tiles) => uraDora;

  @override
  int countAkaDora(Iterable<Tile> tiles) => akaDora ?? super.countAkaDora(tiles);
}

Map<TileId, int> _toDoraMap(Iterable<TileId> tiles) {
  final map = <TileId, int>{};
  for (final tile in tiles) {
    map.inc(tile.dora, 1);
  }
  return map;
}

class DoraTiles extends Dora {
  const DoraTiles({
    required this.dora,
    required this.uraDora,
  });

  DoraTiles.fromIndicators({
    required Iterable<TileId> dora,
    required Iterable<TileId> uraDora,
  }) : dora = _toDoraMap(dora),
       uraDora = _toDoraMap(uraDora);

  DoraTiles.fromIndicatorTiles({
    required Iterable<Tile> dora,
    required Iterable<Tile> uraDora,
  }) : dora = _toDoraMap(dora.map((e) => e.id)),
       uraDora = _toDoraMap(uraDora.map((e) => e.id));

  final Map<TileId, int> dora;
  final Map<TileId, int> uraDora;

  int _count(Map<TileId, int> dora, Iterable<Tile> tiles) => //
      tiles.fold(0, (sum, tile) => sum + (dora[tile.id] ?? 0));

  @override
  int countDora(Iterable<Tile> tiles) => _count(dora, tiles);

  @override
  int countUraDora(Iterable<Tile> tiles) => _count(uraDora, tiles);
}
