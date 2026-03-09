import '/tile.dart';
import 'hand.dart';
import 'sequence.dart';

enum _HandParseState {
  none,
  meld,
  winning,
}

Hand parseHand(String input) {
  final revealed = <RevealedMeldSequence>[];
  final concealed = <Tile>[];

  _HandParseState state = _HandParseState.none;
  final buffer = StringBuffer();
  for (final c in input.split('')) {
    if (c.trim().isEmpty) continue;

    if (c == '+') {
      if (state != _HandParseState.none) throw const FormatException();

      if (buffer.isNotEmpty) {
        concealed.addAll(_parseTiles(buffer.toString()));
        buffer.clear();
      }

      state = _HandParseState.winning;
    } else if (c == '[') {
      if (state != _HandParseState.none) throw const FormatException();

      if (buffer.isNotEmpty) {
        concealed.addAll(_parseTiles(buffer.toString()));
        buffer.clear();
      }

      state = _HandParseState.meld;
    } else if (c == ']') {
      if (state != _HandParseState.meld || buffer.isEmpty) throw const FormatException();

      revealed.add(_toMeld(_parseTiles(buffer.toString())));
      buffer.clear();

      state = _HandParseState.none;
    } else {
      buffer.write(c);
    }
  }
  if (state != _HandParseState.winning || buffer.isEmpty) {
    throw const FormatException('Hand must contain + winning tile');
  }

  final winningTiles = _parseTiles(buffer.toString());
  if (winningTiles.length != 1) throw const FormatException();

  return Hand(
    concealed: concealed,
    revealed: revealed,
    winningTile: winningTiles.single,
  );
}

List<Tile> _parseTiles(String input) {
  final tiles = <Tile>[];
  final buffer = StringBuffer();
  for (final char in input.split('')) {
    if (char.trim().isEmpty) continue;

    if (_isDigit(char)) {
      buffer.write(char);
    } else if (_isSuit(char)) {
      for (final d in buffer.toString().split('')) {
        tiles.add(_toTile(int.parse(d), char));
      }
      buffer.clear();
    } else {
      throw FormatException('Unexpected char: $char');
    }
  }

  return tiles;
}

bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

bool _isSuit(String c) => c == manzuSymbol || c == pinzuSymbol || c == souzuSymbol || c == honorSymbol;

Tile _toTile(int value, String suit) {
  final isRed = value == 0;
  final v = isRed ? 5 : value;
  final index = v - 1;

  if (suit == 'z' && isRed) {
    throw const FormatException('Honor tiles cannot be red');
  }

  return switch (suit) {
    manzuSymbol => SuitTile(ManzuTileId.byIndex[index], isRed: isRed),
    pinzuSymbol => SuitTile(PinzuTileId.byIndex[index], isRed: isRed),
    souzuSymbol => SuitTile(SouzuTileId.byIndex[index], isRed: isRed),
    honorSymbol => HonorTile(HonorTileId.byIndex[index]),
    _ => throw FormatException('Invalid suit: $suit'),
  };
}

RevealedMeldSequence _toMeld(List<Tile> tiles) {
  tiles.sort((a, b) => a.id.compareTo(b.id));

  if (tiles.length == 3) {
    // pon
    if (tiles[0].id == tiles[1].id && tiles[1].id == tiles[2].id) {
      return OpenPonSequence(tiles: tiles);
    }

    // chi
    final suitTiles = tiles.whereType<Tile<SuitTileId>>().toList();
    if (suitTiles.length == 3) {
      if (suitTiles[0].id.next == suitTiles[1].id && suitTiles[1].id.next == suitTiles[2].id) {
        return OpenChiiSequence(tiles: suitTiles);
      }
    }
  }

  // kan
  if (tiles.length == 4) {
    if (tiles.every((e) => e.id == tiles.first.id)) {
      return OpenKanSequence(tiles: tiles);
    }
  }

  throw FormatException('Invalid meld: $tiles');
}
