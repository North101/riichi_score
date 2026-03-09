import '/context.dart';
import '/fu.dart';
import '/score.dart';
import '/han.dart';

class HandResult implements Comparable<HandResult> {
  const HandResult({
    required this.context,
    required this.han,
    required this.fu,
    required this.score,
  });

  final Context context;
  final HanList han;

  final FuBreakdown fu;

  final ScoreResult score;

  bool get isYakuman => han.whereType<YakuResult>().any((e) => e.yaku.isYakuman);

  @override
  int compareTo(HandResult other) {
    final thisPoints = score.payment.total;
    final otherPoints = other.score.payment.total;

    if (thisPoints != otherPoints) {
      return thisPoints.compareTo(otherPoints);
    }

    if (han != other.han) {
      return han.value.compareTo(other.han.value);
    }

    return fu.compareTo(other.fu);
  }
}
