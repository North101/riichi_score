import 'dora.dart';
import 'tile.dart';

class Round {
  const Round({
    required this.wind,
    this.dora = const DoraCount(
      dora: 0,
      uraDora: 0,
    ),
    this.riichiCount = 0,
    this.honbaCount = 0,
  });

  final Wind wind;
  final Dora dora;
  final int riichiCount;
  final int honbaCount;

  int countDora(Iterable<Tile> tiles) => dora.countDora(tiles);

  int countUraDora(Iterable<Tile> tiles) => dora.countUraDora(tiles);

  int countAkaDora(Iterable<Tile> tiles) => dora.countAkaDora(tiles);
}
