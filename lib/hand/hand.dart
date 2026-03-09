import '/tile.dart';
import 'dsl.dart';
import 'sequence.dart';

class Hand {
  const Hand({
    required this.concealed,
    required this.revealed,
    required this.winningTile,
  });

  factory Hand.parse(String input) => parseHand(input);

  final List<Tile> concealed;
  final List<RevealedMeldSequence> revealed;
  final Tile winningTile;

  Iterable<Tile> get tiles sync* {
    yield* concealed;
    for (final meld in revealed) {
      yield* meld;
    }
    yield winningTile;
  }

  bool get isClosed => revealed.every((m) => m.isClosed);
}
