import 'round.dart';
import 'hand.dart';
import 'seat.dart';
import 'rules.dart';
import 'tile.dart';

class Context {
  const Context({
    required this.rules,
    required this.round,
    required this.seat,
    required this.structure,
    required this.waits,
  });

  final Rules rules;
  final Round round;
  final Seat seat;
  final HandStructure structure;
  final Set<Wait> waits;

  bool isValueTile(TileId tile) => switch (tile) {
    DragonTileId() => true,
    WindTileId(:final wind) => wind == round.wind || wind == seat.wind,
    _ => false,
  };
}
