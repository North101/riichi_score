import '/win.dart';
import 'limit.dart';

class ScoreResult {
  const ScoreResult({
    required this.han,
    required this.fu,
    required this.basePoints,
    required this.payment,
    required this.limit,
  });

  final int han;
  final int fu;
  final int basePoints;
  final Payment payment;
  final Limit? limit;
}
