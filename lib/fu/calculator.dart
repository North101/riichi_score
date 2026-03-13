import '/context.dart';
import '/hand.dart';
import '/tile.dart';
import '/win.dart';
import '/han.dart';
import 'reason.dart';
import 'breakdown.dart';

class FuCalculator {
  const FuCalculator();

  FuBreakdown calculate(Context context) {
    final structure = context.structure;
    final agari = context.seat.agari;
    if (structure is SevenPairsHand) {
      return FixedFuBreakdown(
        items: const [
          FuReason.sevenPairs,
        ],
        agari: agari,
      );
    }

    if (structure is! StandardHand) {
      return FixedFuBreakdown(
        items: const [],
        agari: agari,
      );
    }

    if (const PinfuYaku().matches(context)) {
      if (context.rules.pinfuTsumo20Fu) {
        return FixedFuBreakdown(
          items: [
            FuReason.base,
            if (agari is Ron) //
              FuReason.closedRon,
          ],
          agari: agari,
        );
      }
      return RoundedFuBreakdown.fromRules(
        rules: context.rules,
        items: [
          FuReason.base,

          if (agari is Tsumo) //
            FuReason.tsumo,

          if (agari is Ron) //
            FuReason.closedRon,
        ],
        agari: agari,
      );
    }

    final pair = structure.pair.first.id;
    final pairWind = switch (pair) {
      WindTileId(:final wind) => wind,
      _ => null,
    };
    return RoundedFuBreakdown.fromRules(
      rules: context.rules,
      items: [
        FuReason.base,

        if (agari is Ron && structure.isClosed) //
          FuReason.closedRon,

        if (agari is Tsumo) //
          FuReason.tsumo,

        for (final meld in structure.melds)
          if (_meldFu(meld) case FuReason meldFu) //
            meldFu,

        if (pair is DragonTileId) //
          FuReason.valuePair,

        if (pairWind == context.round.wind) //
          FuReason.valuePair,

        if (pairWind == context.seat.wind) //
          FuReason.valuePair,

        if (_waitFu(context.waits) case FuReason waitFu) //
          waitFu,
      ],
      agari: agari,
    );
  }
}

FuReason? _meldFu(MeldSequence meld) {
  final isClosed = meld.isClosed;
  if (meld case KanSequence(:final first)) {
    if (first.isTerminalOrHonor) {
      return isClosed ? FuReason.kanTerminalClosed : FuReason.kanTerminalOpen;
    } else {
      return isClosed ? FuReason.kanSimpleClosed : FuReason.kanSimpleOpen;
    }
  }

  if (meld case PonSequence(:final first)) {
    if (first.isTerminalOrHonor) {
      return isClosed ? FuReason.tripletTerminalClosed : FuReason.tripletTerminalOpen;
    } else {
      return isClosed ? FuReason.tripletSimpleClosed : FuReason.tripletSimpleOpen;
    }
  }

  return null;
}

FuReason? _waitFu(Set<Wait> waits) {
  if (waits.contains(const Tanki())) return FuReason.tankiWait;
  if (waits.contains(const Kanchan())) return FuReason.kanchanWait;
  if (waits.contains(const Penchan())) return FuReason.penchanWait;
  return null;
}
