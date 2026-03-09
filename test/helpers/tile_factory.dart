import 'package:riichi_score/tile.dart';

const man1 = SuitTile(ManzuTileId(1));
const man2 = SuitTile(ManzuTileId(2));
const man3 = SuitTile(ManzuTileId(3));
const man4 = SuitTile(ManzuTileId(4));
const man5 = SuitTile(ManzuTileId(5));
const manRed5 = SuitTile(ManzuTileId(5), isRed: true);
const man6 = SuitTile(ManzuTileId(6));
const man7 = SuitTile(ManzuTileId(7));
const man8 = SuitTile(ManzuTileId(8));
const man9 = SuitTile(ManzuTileId(9));

const pin1 = SuitTile(PinzuTileId(1));
const pin2 = SuitTile(PinzuTileId(2));
const pin3 = SuitTile(PinzuTileId(3));
const pin4 = SuitTile(PinzuTileId(4));
const pin5 = SuitTile(PinzuTileId(5));
const pinRed5 = SuitTile(PinzuTileId(5), isRed: true);
const pin6 = SuitTile(PinzuTileId(6));
const pin7 = SuitTile(PinzuTileId(7));
const pin8 = SuitTile(PinzuTileId(8));
const pin9 = SuitTile(PinzuTileId(9));

const sou1 = SuitTile(SouzuTileId(1));
const sou2 = SuitTile(SouzuTileId(2));
const sou3 = SuitTile(SouzuTileId(3));
const sou4 = SuitTile(SouzuTileId(4));
const sou5 = SuitTile(SouzuTileId(5));
const souRed5 = SuitTile(SouzuTileId(5), isRed: true);
const sou6 = SuitTile(SouzuTileId(6));
const sou7 = SuitTile(SouzuTileId(7));
const sou8 = SuitTile(SouzuTileId(8));
const sou9 = SuitTile(SouzuTileId(9));

const east = HonorTile(WindTileId(Wind.east));
const south = HonorTile(WindTileId(Wind.south));
const west = HonorTile(WindTileId(Wind.west));
const north = HonorTile(WindTileId(Wind.north));

const white = HonorTile(DragonTileId(Dragon.white));
const green = HonorTile(DragonTileId(Dragon.green));
const red = HonorTile(DragonTileId(Dragon.red));
