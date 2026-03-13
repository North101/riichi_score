import '/tile.dart';
import '/win.dart';
import 'constants.dart' as constants;
import 'limit.dart';
import 'result.dart';

class ScoreCalculator {
  const ScoreCalculator();

  Limit? _capLimit({
    Limit? limit,
    Limit? maxLimit,
  }) {
    if (limit == null || maxLimit == null) return limit;

    return limit.index.compareTo(maxLimit.index) > 0 ? limit : maxLimit;
  }

  Limit? _detectLimit({
    required int han,
    required int fu,
    bool useKiriageMangan = true,
  }) {
    if (han >= 26) return Limit.doubleYakuman;
    if (han >= 13) return Limit.yakuman;
    if (han >= 11) return Limit.sanbaiman;
    if (han >= 8) return Limit.baiman;
    if (han >= 6) return Limit.haneman;
    if (han == 5) return Limit.mangan;
    if (han == 4 && fu >= 40 && useKiriageMangan) return Limit.mangan;
    if (han == 3 && fu >= 70 && useKiriageMangan) Limit.mangan;

    return null;
  }

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
    int riichiPoints = constants.riichiPoints,
    int honbaCount = 0,
    int honbaPoints = constants.honbaPoints,
    bool useKiriageMangan = constants.useKiriageMangan,
    Limit? maxLimit,
  }) {
    final limit = _capLimit(
      limit: _detectLimit(
        han: han,
        fu: fu,
        useKiriageMangan: useKiriageMangan,
      ),
      maxLimit: maxLimit,
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
