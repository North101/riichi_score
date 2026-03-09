import '/tile.dart';

sealed class TileSequence<T extends TileId> with Iterable<Tile<T>> {
  const TileSequence();

  @override
  Iterator<Tile<T>> get iterator => tiles.iterator;

  List<Tile<T>> get tiles;

  @override
  String toString() {
    if (first.id case SuitTileId(:final symbol)) {
      return '${tiles.cast<Tile<SuitTileId>>().map((e) => e.isRed ? 0 : e.id.value).join()}$symbol';
    }

    return tiles.join();
  }
}

class PairSequence<T extends TileId> extends TileSequence<T> {
  PairSequence({
    required this.tiles,
  }) : assert(tiles.length == 2),
       assert(tiles.every((e) => e.id == tiles.first.id));

  PairSequence.from(Tile<T> tile) : this(tiles: [tile, tile]);

  @override
  final List<Tile<T>> tiles;
}

sealed class MeldSequence<T extends TileId> extends TileSequence<T> {
  const MeldSequence({
    required this.tiles,
  });

  @override
  final List<Tile<T>> tiles;

  bool get isClosed;

  @override
  String toString() => isClosed ? super.toString() : '[${super.toString()}]';
}

mixin RevealedMeldSequence<T extends TileId> on MeldSequence<T> {}

sealed class ChiiSequence extends MeldSequence<SuitTileId> {
  ChiiSequence({
    required super.tiles,
  }) : assert(tiles.length == 3),
       assert(tiles[0].id.value + 1 == tiles[1].id.value),
       assert(tiles[0].id.value + 2 == tiles[2].id.value);

  ChiiSequence.from(Tile<SuitTileId> tile)
    : this(
        tiles: [tile, SuitTile(tile.id.next!), SuitTile(tile.id.next!.next!)],
      );
}

class OpenChiiSequence extends ChiiSequence with RevealedMeldSequence<SuitTileId> {
  OpenChiiSequence({
    required super.tiles,
  });

  OpenChiiSequence.from(super.tile) : super.from();

  @override
  bool get isClosed => false;
}

class ClosedChiiSequence extends ChiiSequence {
  ClosedChiiSequence({
    required super.tiles,
  });

  ClosedChiiSequence.from(super.tile) : super.from();

  @override
  bool get isClosed => true;
}

sealed class PonSequence extends MeldSequence<TileId> {
  PonSequence({
    required super.tiles,
  }) : assert(tiles.length == 3),
       assert(tiles.every((e) => e.id == tiles.first.id));

  PonSequence.from(Tile tile) : this(tiles: [tile, tile, tile]);
}

class OpenPonSequence extends PonSequence with RevealedMeldSequence<TileId> {
  OpenPonSequence({
    required super.tiles,
  });

  OpenPonSequence.from(super.tile) : super.from();

  @override
  bool get isClosed => false;
}

class ClosedPonSequence extends PonSequence {
  ClosedPonSequence({
    required super.tiles,
  });

  ClosedPonSequence.from(super.tile) : super.from();

  @override
  bool get isClosed => true;
}

sealed class KanSequence extends MeldSequence<TileId> with RevealedMeldSequence {
  KanSequence({
    required super.tiles,
  }) : assert(tiles.length == 4),
       assert(tiles.every((e) => e.id == tiles.first.id));

  KanSequence.from(Tile tile) : this(tiles: [tile, tile, tile, tile]);
}

class OpenKanSequence extends KanSequence {
  OpenKanSequence({
    required super.tiles,
  });

  OpenKanSequence.from(super.tile) : super.from();

  @override
  bool get isClosed => false;
}

class ClosedKanSequence extends KanSequence {
  ClosedKanSequence({
    required super.tiles,
  });

  ClosedKanSequence.from(super.tile) : super.from();

  @override
  bool get isClosed => true;
}
