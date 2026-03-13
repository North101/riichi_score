import 'score/constants.dart' as constants;

enum DoubleYakumanRule {
  suuankouTanki,
  kokushi13Wait,
  daisuushi,
  junseiChuurenPoutou,
}

class Rules {
  const Rules({
    // --- Limit Rules ---
    this.useKiriageMangan = constants.useKiriageMangan,
    this.allowKazoeYakuman = constants.allowKazoeYakuman,

    // Some rule sets treat certain hands as double yakuman
    this.doubleYakumanHands = const {
      DoubleYakumanRule.suuankouTanki,
      DoubleYakumanRule.kokushi13Wait,
      DoubleYakumanRule.daisuushi,
      DoubleYakumanRule.junseiChuurenPoutou,
    },

    // --- Fu Rules ---
    this.pinfuTsumo20Fu = true,
    this.ronMinimum30Fu = true,
    this.roundUpTo10Fu = true,

    // --- Win Condition Rules ---
    this.allowHaitei = true,
    this.allowHoutei = true,
    this.allowRinshan = true,
    this.allowChankan = true,

    // --- Yaku Rules ---
    this.requireClosedForRiichi = true,
    this.allowOpenTanyao = true,

    // --- Bonus Rules ---
    this.allowAkaDora = true,
    this.riichiPoints = constants.riichiPoints,
    this.honbaPoints = constants.honbaPoints,
  });

  // =========================
  // Limit Hand Rules
  // =========================

  final bool useKiriageMangan;
  final bool allowKazoeYakuman;

  // =========================
  // Yakuman Rules
  // =========================

  final Set<DoubleYakumanRule> doubleYakumanHands;

  // =========================
  // Fu Rules
  // =========================

  final bool pinfuTsumo20Fu;
  final bool ronMinimum30Fu;
  final bool roundUpTo10Fu;

  // =========================
  // Win Condition Rules
  // =========================

  final bool allowHaitei;
  final bool allowHoutei;
  final bool allowRinshan;
  final bool allowChankan;

  // =========================
  // Yaku Rules
  // =========================

  final bool requireClosedForRiichi;
  final bool allowOpenTanyao;

  // =========================
  // Bonus Rules
  // =========================

  final bool allowAkaDora;
  final int riichiPoints;
  final int honbaPoints;
}
