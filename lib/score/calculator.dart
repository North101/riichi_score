import '/tile.dart';
import '/win.dart';
import 'constants.dart';
import 'limit.dart';
import 'result.dart';

class ScoreCalculator {
  const ScoreCalculator();

  Limit? _detectLimit({
    required int han,
    required int fu,
    bool useKiriageMangan = true,
  }) => switch (han) {
    >= 13 => Limit.yakuman,
    >= 11 => Limit.sanbaiman,
    >= 8 => Limit.baiman,
    >= 6 => Limit.haneman,

    == 5 => Limit.mangan,
    == 4 =>
      useKiriageMangan
          ? switch (fu) {
              >= 40 => Limit.mangan,
              _ => null,
            }
          : null,
    == 3 =>
      useKiriageMangan
          ? switch (fu) {
              >= 70 => Limit.mangan,
              _ => null,
            }
          : null,

    _ => null,
  };

  int _basePoints(int han, int fu) => fu * (1 << (2 + han));

  Payment _calculatePayment({
    required Wind seatWind,
    required Agari agari,
    required int basePoints,
    required int riichiCount,
    required int riichiPoints,
    required int honbaCount,
    required int honbaPoints,
  }) => switch (agari) {
    Ron() => RonPayment(
      winner: seatWind,
      from: agari.from,
      basePoints: basePoints,
      riichiCount: riichiCount,
      riichiPoints: riichiPoints,
      honbaCount: honbaCount,
      honbaPoints: honbaPoints,
    ),
    Tsumo() => TsumoPayment(
      winner: seatWind,
      basePoints: basePoints,
      riichiCount: riichiCount,
      riichiPoints: riichiPoints,
      honbaCount: honbaCount,
      honbaPoints: honbaPoints,
    ),
  };

  ScoreResult calculate({
    required int han,
    required int fu,
    required Wind seatWind,
    required Agari agari,
    int riichiCount = 0,
    int riichiPoints = riichiPoints,
    int honbaCount = 0,
    int honbaPoints = honbaPoints,
    bool useKiriageMangan = useKiriageMangan,
  }) {
    final limit = _detectLimit(
      han: han,
      fu: fu,
      useKiriageMangan: useKiriageMangan,
    );
    final basePoints = limit?.points ?? _basePoints(han, fu);
    final payment = _calculatePayment(
      seatWind: seatWind,
      agari: agari,
      basePoints: basePoints,
      riichiCount: riichiCount,
      riichiPoints: riichiPoints,
      honbaCount: honbaCount,
      honbaPoints: honbaPoints,
    );

    return ScoreResult(
      han: han,
      fu: fu,
      basePoints: basePoints,
      payment: payment,
      limit: limit,
    );
  }
}
