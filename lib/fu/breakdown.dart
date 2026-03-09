import 'dart:math';

import '/rules.dart';
import '/util.dart';
import '/win.dart';
import 'reason.dart';

abstract class FuBreakdown implements Comparable<FuBreakdown> {
  const FuBreakdown({
    required this.items,
    required this.agari,
  });

  final Iterable<FuReason> items;
  final Agari agari;

  int get raw => items.fold(0, (r, v) => r + v.fu);

  int get value;

  @override
  int compareTo(FuBreakdown other) => value.compareTo(other.value);
}

class FixedFuBreakdown extends FuBreakdown {
  const FixedFuBreakdown({
    required super.items,
    required super.agari,
  });

  @override
  int get value => raw;
}

class RoundedFuBreakdown extends FuBreakdown {
  const RoundedFuBreakdown({
    required super.items,
    required super.agari,
    this.ronMinimum30Fu = true,
    this.roundUpTo10Fu = true,
  });

  RoundedFuBreakdown.fromRules({
    required Rules rules,
    required super.items,
    required super.agari,
  }) : ronMinimum30Fu = rules.ronMinimum30Fu,
       roundUpTo10Fu = rules.roundUpTo10Fu;

  final bool ronMinimum30Fu;
  final bool roundUpTo10Fu;

  @override
  int get value {
    final value = roundUpTo10Fu ? roundFu(raw) : raw;
    if (ronMinimum30Fu && agari is Ron) return max(value, 30);

    return value;
  }
}
