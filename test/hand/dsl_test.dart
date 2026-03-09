import 'package:test/test.dart';
import 'package:riichi_score/hand.dart';
import 'package:riichi_score/tile.dart';

void main() {
  group('Mahjong DSL Parser', () {
    test('parses fully concealed hand', () {
      final hand = parseHand('123m456p789s111z2z + 2z');

      expect(hand.concealed.length, 13);
      expect(hand.revealed, isEmpty);
      expect(hand.winningTile, isNotNull);
      expect(hand.winningTile.id, isA<TileId>());
    });

    test('parses hand with revealed pon', () {
      final hand = parseHand('[555m]123p456s11z + 1z');

      expect(hand.revealed.length, 1);
      final meld = hand.revealed.first;
      expect(meld.tiles.length, 3);
      expect(meld, isA<OpenPonSequence>());
    });

    test('parses hand with multiple revealed melds', () {
      final hand = parseHand('[123m][777p]456s111z2z + 2z');

      expect(hand.revealed.length, 2);
      expect(hand.revealed[0], isA<OpenChiiSequence>());
      expect(hand.revealed[1], isA<OpenPonSequence>());
    });

    test('parses hand with red fives', () {
      final hand = parseHand('0m0p0s11z + 1z'); // red 5 in all suits

      final redTiles = hand.concealed.where((t) => t.isRed).toList();
      expect(redTiles.length, 3);
      expect(
        redTiles.where((e) => e.isRed).map((e) => e.id).whereType<SuitTileId>().every((t) => t.value == 5),
        isTrue,
      );
    });

    test('winning tile parsed correctly', () {
      final hand = parseHand('123m456p789s11z + 7s');

      expect(hand.winningTile.id, const SouzuTileId(7));
      expect(hand.winningTile.id.index, greaterThanOrEqualTo(18)); // suit s offset
    });

    test('throws on invalid meld', () {
      expect(() => parseHand('[124m]123p456s11z + 1z'), throwsFormatException);
    });

    test('throws on missing winning tile', () {
      expect(() => parseHand('123m456p789s11z'), throwsFormatException);
    });

    test('throws on unclosed meld', () {
      expect(() => parseHand('[123m123p456s11z + 1z'), throwsFormatException);
    });

    test('parses complex hand with multiple melds and red fives', () {
      final hand = parseHand('[555m][234p]0s789s11z + 0m');

      expect(hand.revealed.length, 2);
      expect(hand.revealed[0], isA<OpenPonSequence>());
      expect(hand.revealed[1], isA<OpenChiiSequence>());

      final redTile = hand.concealed.firstWhere((t) => t.isRed);
      expect(redTile.id, const SouzuTileId(5));
      expect(hand.winningTile.isRed, isTrue);
    });
  });
}
