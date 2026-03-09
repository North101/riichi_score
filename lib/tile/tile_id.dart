import 'constants.dart';

abstract class TileHelper {
  bool get isHonor;
  bool get isTerminal;
  bool get isTerminalOrHonor => isTerminal || isHonor;
  bool get isSimple;
  bool get isGreen;
}

mixin TileSymbol {
  String get symbol;
}

enum Suit with TileSymbol {
  manzu,
  pinzu,
  souzu
  ;

  @override
  String get symbol => switch (this) {
    Suit.manzu => manzuSymbol,
    Suit.pinzu => pinzuSymbol,
    Suit.souzu => souzuSymbol,
  };
}

enum Wind {
  east,
  south,
  west,
  north
  ;

  bool get isDealer => this == Wind.east;
}

enum Dragon { white, green, red }

sealed class TileId with TileSymbol implements TileHelper, Comparable<TileId> {
  const TileId();

  static const byIndex = [
    ...SuitTileId.byIndex,
    ...HonorTileId.byIndex,
  ];

  @override
  bool get isHonor;
  @override
  bool get isTerminal;
  @override
  bool get isTerminalOrHonor => isTerminal || isHonor;
  @override
  bool get isSimple;
  @override
  bool get isGreen;

  TileId get dora;

  int get index => switch (this) {
    SuitTileId(:final suit, value: final v) => (suit.index * 9) + v - 1,
    WindTileId(:final wind) => (Suit.values.length * 9) + wind.index,
    DragonTileId(:final dragon) => (Suit.values.length * 9) + Wind.values.length + dragon.index,
  };

  @override
  int compareTo(TileId other) {
    return switch (this) {
      SuitTileId(suit: final suit1, value: final value1) => switch (other) {
        SuitTileId(suit: final suit2, value: final value2) =>
          (suit1 == suit2)
              ? value1.compareTo(value2) //
              : suit1.index.compareTo(suit2.index),
        WindTileId() => -1,
        DragonTileId() => -1,
      },
      WindTileId(wind: final wind1) => switch (other) {
        SuitTileId() => 1,
        WindTileId(wind: final wind2) => wind1.index.compareTo(wind2.index),
        DragonTileId() => -1,
      },
      DragonTileId(dragon: final dragon1) => switch (other) {
        SuitTileId() => 1,
        WindTileId() => 1,
        DragonTileId(dragon: final dragon2) => dragon1.index.compareTo(dragon2.index),
      },
    };
  }
}

sealed class SuitTileId extends TileId {
  const SuitTileId(this.value);

  static const byIndex = [
    ...ManzuTileId.byIndex,
    ...PinzuTileId.byIndex,
    ...SouzuTileId.byIndex,
  ];

  Suit get suit;
  final int value;

  @override
  final bool isHonor = false;
  @override
  bool get isTerminal => value == 1 || value == 9;
  @override
  bool get isSimple => value > 1 && value < 9;

  @override
  String get symbol => suit.symbol;

  SuitTileId? get next;

  @override
  bool operator ==(Object other) =>
      other is SuitTileId && other.runtimeType == runtimeType && other.suit == suit && other.value == value;

  @override
  int get hashCode => Object.hash(suit, value);

  @override
  String toString() => '$value${suit.symbol}';
}

class ManzuTileId extends SuitTileId {
  const ManzuTileId(super.value);

  static const byIndex = [
    ManzuTileId(1),
    ManzuTileId(2),
    ManzuTileId(3),
    ManzuTileId(4),
    ManzuTileId(5),
    ManzuTileId(6),
    ManzuTileId(7),
    ManzuTileId(8),
    ManzuTileId(9),
  ];

  @override
  Suit get suit => Suit.manzu;

  @override
  final bool isGreen = false;

  @override
  ManzuTileId? get next => switch (value) {
    1 => const ManzuTileId(2),
    2 => const ManzuTileId(3),
    3 => const ManzuTileId(4),
    4 => const ManzuTileId(5),
    5 => const ManzuTileId(6),
    6 => const ManzuTileId(7),
    7 => const ManzuTileId(8),
    8 => const ManzuTileId(9),
    9 => null,
    _ => throw RangeError.range(value, 1, 9),
  };

  @override
  ManzuTileId get dora => next ?? const ManzuTileId(1);
}

class PinzuTileId extends SuitTileId {
  const PinzuTileId(super.value) : assert(value >= 1 && value <= 9);

  static const byIndex = [
    PinzuTileId(1),
    PinzuTileId(2),
    PinzuTileId(3),
    PinzuTileId(4),
    PinzuTileId(5),
    PinzuTileId(6),
    PinzuTileId(7),
    PinzuTileId(8),
    PinzuTileId(9),
  ];

  @override
  Suit get suit => Suit.pinzu;

  @override
  final bool isGreen = false;

  @override
  PinzuTileId? get next => switch (value) {
    1 => const PinzuTileId(2),
    2 => const PinzuTileId(3),
    3 => const PinzuTileId(4),
    4 => const PinzuTileId(5),
    5 => const PinzuTileId(6),
    6 => const PinzuTileId(7),
    7 => const PinzuTileId(8),
    8 => const PinzuTileId(9),
    9 => null,
    _ => throw RangeError.range(value, 1, 9),
  };

  @override
  PinzuTileId get dora => next ?? const PinzuTileId(1);
}

class SouzuTileId extends SuitTileId {
  const SouzuTileId(super.value);

  static const byIndex = [
    SouzuTileId(1),
    SouzuTileId(2),
    SouzuTileId(3),
    SouzuTileId(4),
    SouzuTileId(5),
    SouzuTileId(6),
    SouzuTileId(7),
    SouzuTileId(8),
    SouzuTileId(9),
  ];

  @override
  Suit get suit => Suit.souzu;

  @override
  bool get isGreen => switch (value) {
    2 => true,
    3 => true,
    4 => true,
    6 => true,
    8 => true,
    _ => false,
  };

  @override
  SouzuTileId? get next => switch (value) {
    1 => const SouzuTileId(2),
    2 => const SouzuTileId(3),
    3 => const SouzuTileId(4),
    4 => const SouzuTileId(5),
    5 => const SouzuTileId(6),
    6 => const SouzuTileId(7),
    7 => const SouzuTileId(8),
    8 => const SouzuTileId(9),
    9 => null,
    _ => throw RangeError.range(value, 1, 9),
  };

  @override
  SouzuTileId get dora => next ?? const SouzuTileId(1);
}

sealed class HonorTileId extends TileId {
  const HonorTileId();

  static const byIndex = [
    ...WindTileId.byIndex,
    ...DragonTileId.byIndex,
  ];

  @override
  final bool isHonor = true;
  @override
  final bool isTerminal = false;
  @override
  final bool isSimple = false;

  @override
  String get symbol => honorSymbol;
}

class WindTileId extends HonorTileId {
  const WindTileId(this.wind);

  static const byIndex = [
    WindTileId(Wind.east),
    WindTileId(Wind.south),
    WindTileId(Wind.west),
    WindTileId(Wind.north),
  ];

  final Wind wind;

  @override
  final bool isGreen = false;

  @override
  WindTileId get dora => switch (wind) {
    Wind.east => const WindTileId(Wind.south),
    Wind.south => const WindTileId(Wind.west),
    Wind.west => const WindTileId(Wind.north),
    Wind.north => const WindTileId(Wind.east),
  };

  @override
  bool operator ==(Object other) => other is WindTileId && other.runtimeType == runtimeType && other.wind == wind;

  @override
  int get hashCode => wind.hashCode;

  @override
  String toString() => '${wind.index + 1}$symbol';
}

class DragonTileId extends HonorTileId {
  const DragonTileId(this.dragon);

  static const byIndex = [
    DragonTileId(Dragon.white),
    DragonTileId(Dragon.green),
    DragonTileId(Dragon.red),
  ];

  final Dragon dragon;

  @override
  bool get isGreen => dragon == Dragon.green;

  @override
  DragonTileId get dora => switch (dragon) {
    Dragon.white => const DragonTileId(Dragon.green),
    Dragon.green => const DragonTileId(Dragon.red),
    Dragon.red => const DragonTileId(Dragon.white),
  };

  @override
  bool operator ==(Object other) => other is DragonTileId && other.runtimeType == runtimeType && other.dragon == dragon;

  @override
  int get hashCode => dragon.hashCode;

  @override
  String toString() => '${Wind.values.length + dragon.index + 1}$symbol';
}
