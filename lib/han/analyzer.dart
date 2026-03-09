import '/context.dart';
import 'result.dart';
import 'yaku.dart';

class HanList with Iterable<HanResult> {
  const HanList({
    required this.items,
  });

  final List<HanResult> items;

  int get value => items.fold(0, (sum, y) => sum + y.value);

  bool get isYakuman => items.whereType<YakuResult>().any((e) => e.yaku.isYakuman);

  @override
  Iterator<HanResult> get iterator => items.iterator;
}

class HanAnalyzer {
  const HanAnalyzer({
    required this.yakuList,
    required this.yakumanList,
  });

  final List<Yaku> yakuList;
  final List<Yakuman> yakumanList;

  HanList analyze(Context context) {
    final yakuman = yakumanList.expand((e) => e.evaluate(context));
    if (yakuman.isNotEmpty) {
      return HanList(
        items: yakuman.toList(),
      );
    }

    final yaku = yakuList.expand((e) => e.evaluate(context));
    if (yaku.isNotEmpty) {
      return HanList(
        items: [
          ...yaku,
          if (context.round.countDora(context.structure.tiles) case final value)
            if (value > 0) DoraResult(dora: .dora, value: value),
          if (context.round.countUraDora(context.structure.tiles) case final value)
            if (value > 0) DoraResult(dora: .uraDora, value: value),
          if (context.rules.allowAkaDora)
            if (context.round.countAkaDora(context.structure.tiles) case final value)
              if (value > 0) DoraResult(dora: .akaDora, value: value),
        ],
      );
    }
    return const HanList(items: []);
  }
}
