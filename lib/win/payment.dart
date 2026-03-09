import '/score.dart';
import '/tile.dart';
import '/util.dart';

typedef SeatPayment = ({
  Wind wind,
  int value,
});

sealed class Payment {
  const Payment();

  Wind get winner;
  int get basePoints;
  int get riichiCount;
  int get riichiPoints;
  int get honbaCount;
  int get honbaPoints;

  int get pointsFromRiichi => riichiCount * riichiPoints;
  int get pointsFromHonba;

  Map<Wind, int> get payments;

  int get total => payments.values.fold(pointsFromRiichi, (a, b) => a + b);
}

class RonPayment extends Payment {
  RonPayment({
    required this.winner,
    required this.from,
    required this.basePoints,
    required this.riichiCount,
    required this.riichiPoints,
    required this.honbaCount,
    required this.honbaPoints,
  });

  @override
  final Wind winner;
  final Wind from;
  @override
  final int basePoints;
  @override
  final int riichiCount;
  @override
  final int riichiPoints;
  @override
  final int honbaCount;
  @override
  final int honbaPoints;

  @override
  int get pointsFromHonba => honbaCount * honbaPoints * 3;

  int get payment {
    final multiplier = winner.isDealer ? dealerRonMultiplier : nonDealerRonMultiplier;
    return roundScore(basePoints * multiplier) + pointsFromHonba;
  }

  @override
  late Map<Wind, int> payments = {
    from: payment,
  };
}

class TsumoPayment extends Payment {
  TsumoPayment({
    required this.winner,
    required this.basePoints,
    required this.riichiCount,
    required this.riichiPoints,
    required this.honbaCount,
    required this.honbaPoints,
  });

  @override
  final Wind winner;
  @override
  final int basePoints;
  @override
  final int riichiCount;
  @override
  final int riichiPoints;
  @override
  final int honbaCount;
  @override
  final int honbaPoints;

  @override
  int get pointsFromHonba => honbaCount * honbaPoints;

  int get dealerPayment => roundScore(basePoints * dealerTsumoMultiplier) + pointsFromHonba;
  int get nonDealerPayment => roundScore(basePoints) + pointsFromHonba;

  @override
  late Map<Wind, int> payments = {
    for (final wind in Wind.values)
      if (wind != winner)
        wind: winner.isDealer || wind.isDealer
            ? dealerPayment //
            : nonDealerPayment,
  };
}
