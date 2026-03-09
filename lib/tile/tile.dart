import 'tile_id.dart';

sealed class Tile<T extends TileId> implements TileHelper, Comparable<Tile> {
  const Tile(this.id);

  final T id;

  bool get isRed => false;

  @override
  bool get isGreen => id.isGreen;

  @override
  bool get isHonor => id.isHonor;

  @override
  bool get isSimple => id.isSimple;

  @override
  bool get isTerminal => id.isTerminal;

  @override
  bool get isTerminalOrHonor => id.isTerminalOrHonor;

  @override
  int compareTo(Tile other) {
    final compare = id.compareTo(other.id);
    if (compare != 0) return compare;

    if (isRed == other.isRed) return 0;
    return isRed ? -1 : 1;
  }

  @override
  String toString() => id.toString();
}

class SuitTile extends Tile<SuitTileId> {
  const SuitTile(super.id, {this.isRed = false});

  @override
  final bool isRed;
}

class HonorTile extends Tile<HonorTileId> {
  const HonorTile(super.id);
}

const tiles = <Tile>[
  SuitTile(ManzuTileId(1)),
  SuitTile(ManzuTileId(2)),
  SuitTile(ManzuTileId(3)),
  SuitTile(ManzuTileId(4)),
  SuitTile(ManzuTileId(5)),
  SuitTile(ManzuTileId(5), isRed: true),
  SuitTile(ManzuTileId(6)),
  SuitTile(ManzuTileId(7)),
  SuitTile(ManzuTileId(8)),
  SuitTile(ManzuTileId(9)),

  SuitTile(PinzuTileId(1)),
  SuitTile(PinzuTileId(2)),
  SuitTile(PinzuTileId(3)),
  SuitTile(PinzuTileId(4)),
  SuitTile(PinzuTileId(5)),
  SuitTile(PinzuTileId(5), isRed: true),
  SuitTile(PinzuTileId(6)),
  SuitTile(PinzuTileId(7)),
  SuitTile(PinzuTileId(8)),
  SuitTile(PinzuTileId(9)),

  SuitTile(SouzuTileId(1)),
  SuitTile(SouzuTileId(2)),
  SuitTile(SouzuTileId(3)),
  SuitTile(SouzuTileId(4)),
  SuitTile(SouzuTileId(5)),
  SuitTile(SouzuTileId(5), isRed: true),
  SuitTile(SouzuTileId(6)),
  SuitTile(SouzuTileId(7)),
  SuitTile(SouzuTileId(8)),
  SuitTile(SouzuTileId(9)),

  HonorTile(WindTileId(Wind.east)),
  HonorTile(WindTileId(Wind.south)),
  HonorTile(WindTileId(Wind.west)),
  HonorTile(WindTileId(Wind.north)),

  HonorTile(DragonTileId(Dragon.white)),
  HonorTile(DragonTileId(Dragon.green)),
  HonorTile(DragonTileId(Dragon.red)),
];
