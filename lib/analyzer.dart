import 'context.dart';
import 'fu.dart';
import 'round.dart';
import 'han.dart';
import 'hand.dart';
import 'seat.dart';
import 'rules.dart';
import 'score.dart';

class MahjongAnalyzer {
  const MahjongAnalyzer({
    this.handAnalyzer = const HandAnalyzer(),
    this.waitAnalyzer = const WaitAnalyzer(),
    this.hanAnalyzer = const HanAnalyzer(
      yakuList: yakuList,
      yakumanList: yakumanList,
    ),
    this.fuCalculator = const FuCalculator(),
    this.scoreCalculator = const ScoreCalculator(),
  });

  final HandAnalyzer handAnalyzer;
  final WaitAnalyzer waitAnalyzer;
  final HanAnalyzer hanAnalyzer;
  final FuCalculator fuCalculator;
  final ScoreCalculator scoreCalculator;

  HandResult? analyzeStructure(Context context) {
    final han = hanAnalyzer.analyze(context);
    if (han.isEmpty) return null;

    final fu = fuCalculator.calculate(context);
    final score = scoreCalculator.calculate(
      han: han.value,
      fu: fu.value,
      seatWind: context.seat.wind,
      agari: context.seat.agari,
      riichiCount: context.round.riichiCount,
      riichiPoints: context.rules.riichiPoints,
      honbaCount: context.round.honbaCount,
      honbaPoints: context.rules.honbaPoints,
      maxLimit: han.isYakuman || context.rules.allowKazoeYakuman ? null : Limit.sanbaiman,
      useKiriageMangan: context.rules.useKiriageMangan,
    );

    return HandResult(
      context: context,
      han: han,
      fu: fu,
      score: score,
    );
  }

  Iterable<HandResult> analyzeStructures({
    required Rules rules,
    required Round round,
    required Seat seat,
    required Hand hand,
    required Iterable<HandStructure> structures,
  }) sync* {
    for (final structure in structures) {
      final context = Context(
        rules: rules,
        round: round,
        seat: seat,
        structure: structure,
        waits: waitAnalyzer.analyze(structure),
      );
      final result = analyzeStructure(context);
      if (result == null) continue;

      yield result;
    }
  }

  HandResult? analyze({
    required Rules rules,
    required Round round,
    required Seat seat,
    required Hand hand,
  }) {
    return analyzeStructures(
      rules: rules,
      round: round,
      seat: seat,
      hand: hand,
      structures: handAnalyzer.analyze(hand),
    ).fold(
      null,
      (best, next) => best == null || next.compareTo(best) > 0 ? next : best,
    );
  }
}
