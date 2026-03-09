import 'tile.dart';
import 'win.dart';

class Seat {
  const Seat({
    required this.wind,
    required this.agari,
    this.riichi,
  });

  final Wind wind;
  final Agari agari;
  final Riichi? riichi;

  bool get isRiichi => riichi != null;
}
