import '/context.dart';
import '/hand.dart';
import '/rules.dart';
import '/tile.dart';
import '/util.dart';
import '/win.dart';
import 'result.dart';

abstract class Yaku {
  const Yaku();

  bool matches(Context context);

  Iterable<YakuResult> _results(Context context);

  Iterable<YakuResult> evaluate(Context context) sync* {
    if (!matches(context)) return;

    yield* _results(context);
  }
}

// Menzenchin tsumohou 「門前清自摸和」, usually abbreviated as menzen tsumo 「メンゼンツモ」, mentsumo 「メンツモ」, or
// simply tsumo 「ツモ」, is a yaku obtained when a closed hand wins with a self-drawn tile - in other words, a menzen
// hand winning from a tsumo call.
class MenzenTsumoYaku extends Yaku {
  const MenzenTsumoYaku();

  @override
  bool matches(Context context) {
    if (!context.structure.isClosed) return false;
    return context.seat.agari is Tsumo;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .menzenTsumo,
      value: 1,
    );
  }
}

// Riichi 「立直」 or 「リーチ」 is the most common yaku in the round. Any closed hand that reaches tenpai can declare
// "riichi", gaining this yaku. It occurs in roughly 40% of winning hands across various platforms and professional
// settings.
class RiichiYaku extends Yaku {
  const RiichiYaku();

  @override
  bool matches(Context context) {
    return context.seat.riichi is Riichi && context.seat.riichi is! DoubleRiichi;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .riichi,
      value: 1,
    );
  }
}

// Daburu riichi 「両立直」, 「ダブルリーチ」 or 「Ｗリーチ」, or literally double riichi, is a special case for riichi on
// the first turn. If the player reaches tenpai before discarding (i.e., within the first 14 tiles), and before anyone
// has made a tile call, then riichi will automatically be converted into double riichi. Double riichi is worth 2 han,
// 1 more than the usual 1 han for riichi.
class DoubleRiichiYaku extends Yaku {
  const DoubleRiichiYaku();

  @override
  bool matches(Context context) {
    return context.seat.riichi is DoubleRiichi;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .doubleRiichi,
      value: 2,
    );
  }
}

// Ippatsu 「一発」 is a yaku that is completely dependent on riichi. After declaring riichi, if the player wins before
// their next discard, and before anyone makes a tile call, ippatsu is scored. You must declare riichi to score
// ippatsu, so a hand can never have ippatsu by itself.
class IppatsuYaku extends Yaku {
  const IppatsuYaku();

  @override
  bool matches(Context context) {
    return context.seat.riichi?.ippatsu ?? false;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .ippatsu,
      value: 1,
    );
  }
}

// Haitei raoyue 「海底撈月」 (also called Haitei mouyue 「海底摸月」), or haitei for short, is a yaku scored when a player
// wins by tsumo on the last drawable tile from the live wall.
class HaiteiYaku extends Yaku {
  const HaiteiYaku();

  @override
  bool matches(Context context) {
    if (!context.rules.allowHaitei) return false;
    return context.seat.agari is Haitei;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .haitei,
      value: 1,
    );
  }
}

// Houtei raoyui 「河底撈魚」, or houtei for short, is scored when a player wins by ron on the last possible discard. The
// discarded tile does not have to be the tile just drawn by the player.
class HouteiYaku extends Yaku {
  const HouteiYaku();

  @override
  bool matches(Context context) {
    if (!context.rules.allowHoutei) return false;
    return context.seat.agari is Houtei;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .houtei,
      value: 1,
    );
  }
}

// Rinshan kaihou 「嶺上開花」 is a yaku obtained when a player wins from a draw from the dead wall. This can be obtained
// by:
// * Declaring a kan and winning with the tile drawn from said kan.
// * In sanma, declaring nukidora/kita and winning with the tile drawn.
class RinshanYaku extends Yaku {
  const RinshanYaku();

  @override
  bool matches(Context context) {
    if (!context.rules.allowRinshan) return false;
    return context.seat.agari is Rinshan;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .rinshan,
      value: 1,
    );
  }
}

// Chankan 「搶槓」 is a yaku scored when "robbing a kan". When an opponent upgrades an open triplet into an added kan,
// you may call ron if the kan would be your winning tile, scoring chankan in the process.
class ChankanYaku extends Yaku {
  const ChankanYaku();

  @override
  bool matches(Context context) {
    if (!context.rules.allowChankan) return false;
    return context.seat.agari is Chankan;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .chankan,
      value: 1,
    );
  }
}

// Tanyaochuu 「断幺九」 (lit. "severed terminals and honors"), usually abbreviated to tanyao 「タンヤオ」, is a yaku
// scored when the hand only has numbered tiles 2-8. In other words, the hand cannot contain terminal tiles (1 and 9)
// or honor tiles. While it is cheap, tanyao is one of the fastest and easiest yaku to obtain.
class TanyaoYaku extends Yaku {
  const TanyaoYaku();

  @override
  bool matches(Context context) {
    if (!context.rules.allowOpenTanyao && !context.structure.isClosed) return false;
    return !context.structure.tiles.any((e) => e.isTerminalOrHonor);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .tanyao,
      value: 1,
    );
  }
}

// Yakuhai 「役牌」, or Fanpai 「飜牌」, is a group of 1 han yaku scored for completing a group of honor tiles. They come
// in three classes:
// * Dragon tile groups always count for yakuhai.
// * Wind tiles of the round wind count as yakuhai.
// * Wind tiles of the seat wind also count as yakuhai. (If a wind is both the round and seat wind, it is worth 2 han.)
class YakuhaiYaku extends Yaku {
  const YakuhaiYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;
    return structure.melds.whereType<PonSequence>().any((e) => context.isValueTile(e.tiles.first.id));
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    final structure = context.structure;
    if (structure is! StandardHand) return;

    for (final meld in structure.melds) {
      if (meld is PonSequence) {
        if (meld.tiles.first.id case DragonTileId(:final dragon)) {
          yield YakuResult(
            yaku: switch (dragon) {
              Dragon.white => .yakuhaiWhiteDragon,
              Dragon.green => .yakuhaiGreenDragon,
              Dragon.red => .yakuhaiRedDragon,
            },
            value: 1,
          );
        } else if (meld.tiles.first.id case WindTileId(:final wind)) {
          if (wind == context.round.wind) {
            yield const YakuResult(
              yaku: .yakuhaiRoundWind,
              value: 1,
            );
          }
          if (wind == context.seat.wind) {
            yield const YakuResult(
              yaku: .yakuhaiSeatWind,
              value: 1,
            );
          }
        }
      }
    }
  }
}

// Pinfu 「平和」 is a yaku obtained when a closed hand gains no fu from its composition at tenpai or wait pattern. In
// other words, it would only gain the base 20 fu and fu from the win method. It is worth 1 han and can only be scored
// by closed hands.
class PinfuYaku extends Yaku {
  const PinfuYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    if (!structure.isClosed) return false;
    if (!structure.isAllSequences) return false;
    if (context.isValueTile(structure.pair.tiles.first.id)) return false;

    return context.waits.contains(const Ryanmen());
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .pinfu,
      value: 1,
    );
  }
}

// Iipeikou 「一盃口」 is a yaku scored when a hand has two identical sequences (two sequences with the same number and
// suit). It also requires the hand to be closed. If a hand has "two iipeikou"s, it instead scores ryanpeikou.
class IipeikouYaku extends Yaku {
  const IipeikouYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    if (!structure.isClosed) return false;

    final sequences = structure.melds.whereType<ChiiSequence>().toList();
    if (sequences.length < 2) return false;

    final map = <SuitTileId, int>{};
    for (final seq in sequences) {
      map.inc(seq.tiles.first.id, 1);
    }

    final pairs = map.values.where((v) => v >= 2).length;
    return pairs == 1;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .iipeikou,
      value: 1,
    );
  }
}

// Sanshoku doujun 「三色同順」 (lit. "three colors, same sequence") is a yaku scored when a hand has three sequences,
// one of each suit, that share the same numbers. The shorthand sanshoku more commonly refers to this yaku, instead of
// the significantly more difficult to achieve sanshoku doukou. It is sometimes called sanshiki (alternative reading of
// 三色) in older media.
class SanshokuDoujunYaku extends Yaku {
  const SanshokuDoujunYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final groups = <int, Set<Suit>>{};
    for (final meld in structure.melds.whereType<ChiiSequence>()) {
      groups.putIfAbsent(meld.tiles.first.id.value, () => {}).add(meld.tiles.first.id.suit);
    }
    return groups.values.any((e) => e.length == 3);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .sanshokuDoujun,
      value: 2,
    );
  }
}

// Ikki tsuukan 「一気通貫」 (lit. "piercing through in one go"), or ittsuu 「一通」 for short, is a yaku scored when the
// hand has three sequences of: 123, 456, 789, all sharing the same suit. It forms a single suit "straight" of
// 123456789, similar to the poker hand, which is why it is commonly called a full straight, a pure straight, or simply
// straight in English. It can be scored open or closed, but if in an open hand, it loses 1 han of value.
class IttsuuYaku extends Yaku {
  const IttsuuYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final groups = <Suit, Set<int>>{};
    for (final meld in structure.melds.whereType<ChiiSequence>()) {
      groups.putIfAbsent(meld.tiles.first.id.suit, () => {}).add(meld.tiles.first.id.value);
    }
    return groups.values.any((e) => e.containsAll(const {1, 4, 7}));
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .ittsuu,
      value: 2,
    );
  }
}

// Toitoihou 「対々和」, often shortened to toitoi 「対々」, is a yaku scored when all four tile groups are triplets
// (and/or kans), giving it the English name of "All Triplets".
class ToitoiYaku extends Yaku {
  const ToitoiYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    return structure.isAllTriplets;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .toitoi,
      value: 2,
    );
  }
}

// Sanankou 「三暗刻」[n 1] is a yaku obtained when the hand has three concealed triplets (ankou). A concealed kan counts
// as a concealed triplet. It can be completed with an open or closed hand.
class SanankouYaku extends Yaku {
  const SanankouYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final closedTriplets = structure.melds
        .whereType<ClosedPonSequence>() //
        .length;
    return closedTriplets == 3;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .sanankou,
      value: 2,
    );
  }
}

// Chanta 「全帯」, short for honchantaiyaochuu 「混全帯么九」, is scored when every tile group and the pair contains at
// least one terminal / honor tile. The hand must contain at least one honor and one non-terminal tile to score chanta,
// or it would score the more valuable junchan or honroutou instead. This yaku can also be called chantaiyaochuu
//「全帯么九」 or chantaiyao 「全帯么」.
class ChantaYaku extends Yaku {
  const ChantaYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    return structure.melds.every((meld) => meld.any((e) => e.isTerminalOrHonor)) &&
        context.structure.tiles.any((e) => !e.isTerminalOrHonor);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield YakuResult(
      yaku: .chanta,
      value: context.structure.isClosed ? 2 : 1,
    );
  }
}

// Chiitoitsu 「七対子」, also known as chiitoi or niconico, is a yaku scored when a hand has seven pairs. It is one of
// the two exceptions of the "four melds and one pair" rule for winning hands, the other being kokushi musou. Because
// the hand does not use melds, it can only be closed.
class ChiitoitsuYaku extends Yaku {
  const ChiitoitsuYaku();

  @override
  bool matches(Context context) {
    return context.structure is SevenPairsHand;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .chiitoitsu,
      value: 2,
    );
  }
}

// Sanshoku doukou 「三色同刻」 (lit. "three colors, same triplet") is a yaku scored when a hand has triplets
// (and/or kans) of the same numbered tile in all three suits. Whether open or closed, this yaku scores 2 han.
class SanshokuDoukouYaku extends Yaku {
  const SanshokuDoukouYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final groups = <int, Set<Suit>>{};
    for (final meld in structure.melds.whereType<PonSequence>()) {
      if (meld.tiles.first.id case SuitTileId(:final suit, :final value)) {
        groups.putIfAbsent(value, () => {}).add(suit);
      }
    }
    return groups.values.any((e) => e.length == 3);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .sanshokuDoukou,
      value: 2,
    );
  }
}

// Honroutou 「混老頭」 is a yaku scored when every tile in the hand is either a terminal or an honor tile. The hand must
// contain at least one honor and one terminal to score honroutou; an all honor hand would be tsuuiisou, while an all
// terminal hand would be chinroutou.
class HonroutouYaku extends Yaku {
  const HonroutouYaku();

  @override
  bool matches(Context context) {
    final terminalCount = context.structure.tiles.where((e) => e.isTerminal).length;
    if (terminalCount == 0) return false;

    final honorCount = context.structure.tiles.where((e) => e.isHonor).length;
    if (honorCount == 0) return false;

    return (terminalCount + honorCount) == context.structure.tiles.length;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .honroutou,
      value: 2,
    );
  }
}

// Shousangen 「小三元」 ("small three dragons") is a yaku scored when a hand has two triplets of dragons and a pair of
// the third dragon.
class ShousangenYaku extends Yaku {
  const ShousangenYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final dragonTriplets = structure.melds
        .whereType<PonSequence>()
        .where((p) => p.tiles.first.id is DragonTileId)
        .length;
    final pairIsDragon = structure.pair.tiles.first.id is DragonTileId;
    return dragonTriplets == 2 && pairIsDragon;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .shousangen,
      value: 2,
    );
  }
}

// Junchantaiyaochuu 「純全帯么九」, or junchan 「純全」 for short, is a yaku scored when every tile group and the pair
// contains at least one terminal tile (either 1/9). At least one non-terminal must be present to score junchan, or the
// hand would score chinroutou instead. It is similar to chanta, but chanta allows the use of honor tiles.
class JunchanYaku extends Yaku {
  const JunchanYaku();

  @override
  bool matches(Context context) {
    if (context.structure.tiles.every((tile) => tile.isTerminal)) return false;

    return context.structure.tiles.every((meld) {
      if (meld case (SuitTileId(:final value))) {
        if (meld is PairSequence || meld is PonSequence) {
          return const {1, 9}.contains(value);
        } else if (meld is ChiiSequence) {
          return const {1, 7}.contains(value);
        }
      }
      return false;
    });
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield YakuResult(
      yaku: .junchan,
      value: context.structure.isClosed ? 3 : 2,
    );
  }
}

// Ryanpeikou 「二盃口」 is a yaku scored when a hand has two "iipeikou". In other words, it is scored when the hand is
// closed and has four sequences, with two sequences sharing identical suit/numbers with each other, and the other two
// sequences also sharing the same suit/numbers.
class RyanpeikouYaku extends Yaku {
  const RyanpeikouYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    if (!structure.isClosed) return false;

    final sequences = structure.melds.whereType<ChiiSequence>().toList();
    if (sequences.length < 4) return false;

    final map = <SuitTileId, int>{};
    for (final seq in sequences) {
      map.inc(seq.tiles.first.id, 1);
    }

    final pairs = map.values.where((v) => v >= 2).length;
    return pairs == 2;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .ryanpeikou,
      value: 3,
    );
  }
}

// Honiisou 「混一色」 (lit. "blended single color"), often called honitsu 「混一」,[n 1][n 2] is scored with a hand
// that has only a single suit of number tiles and at least 1 honor tile. It is worth 3 han, but reduced to 2 in an
// open hand. A "single suit" hand without honors instead scores chinitsu, which is worth 3 han more.
class HonitsuYaku extends Yaku {
  const HonitsuYaku();

  @override
  bool matches(Context context) {
    return context.structure.isHalfFlush;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield YakuResult(
      yaku: .honitsu,
      value: context.structure.isClosed ? 3 : 2,
    );
  }
}

// Chiniisou 「清一色」 (lit. "pure single color"), often called chinitsu 「清一」,[n 1][n 2] is a yaku scored when the
// hand only has tiles of a single numbered suit. It is worth 6 han, but reduced to 5 in an open hand.
class ChinitsuYaku extends Yaku {
  const ChinitsuYaku();

  @override
  bool matches(Context context) {
    return context.structure.isFlush;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield YakuResult(
      yaku: .chinitsu,
      value: context.structure.isClosed ? 6 : 5,
    );
  }
}

// YAKUMAN

abstract class Yakuman extends Yaku {
  const Yakuman();
}

// Shousuushii 「小四喜」is a wind-baed yakuman with triplets/quads of three winds, and a pair of the last wind.
class ShousuushiiYaku extends Yakuman {
  const ShousuushiiYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final windTriplets = structure.melds.whereType<PonSequence>().where((p) => p.tiles.first.id is WindTileId).length;
    if (windTriplets != 3) return false;

    final pairIsWind = structure.pair.tiles.first.id is WindTileId;
    return pairIsWind;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .shousuushii,
      value: 13,
    );
  }
}

// Daisuushii 「小四喜」is a wind-baed yakuman with triplets/quads of all four winds.
class DaisuushiiYakuman extends Yakuman {
  const DaisuushiiYakuman();

  bool isDoubleYakuman(Context context) {
    return context.rules.doubleYakumanHands.contains(DoubleYakumanRule.daisuushi);
  }

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final windTriplets = structure.melds.whereType<PonSequence>().where((p) => p.tiles.first.id is WindTileId).length;
    return windTriplets == 4;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    if (isDoubleYakuman(context)) {
      yield const YakuResult(
        yaku: .daisuushii,
        value: 26,
      );
    } else {
      yield const YakuResult(
        yaku: .daisuushii,
        value: 13,
      );
    }
  }
}

// Daisangen 「大三元」 is a yakuman scored when a hand has triplets/quads of all three dragons.
class DaisangenYaku extends Yakuman {
  const DaisangenYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final dragons = {
      for (final meld in structure.melds.whereType<PonSequence>())
        if (meld.tiles.first.id case DragonTileId(:final dragon)) dragon,
    };
    return dragons.containsAll(Dragon.values);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .daisangen,
      value: 13,
    );
  }
}

// Tsuuiisou 「字一色」 is a yakuman scored when the hand consists entirely of honor tiles.
class TsuuiisouYaku extends Yakuman {
  const TsuuiisouYaku();

  @override
  bool matches(Context context) {
    return context.structure.tiles.every((e) => e.isHonor);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .tsuuiisou,
      value: 13,
    );
  }
}

// Chinroutou 「清老頭」, or chinrou 「清老」 for short, is a yakuman scored when every tile is a terminal (1 or 9).
// In other words, no simples (2-8) or honors are allowed.
class ChinroutouYaku extends Yakuman {
  const ChinroutouYaku();

  @override
  bool matches(Context context) {
    return context.structure.tiles.every((e) => e.isTerminal);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .chinroutou,
      value: 13,
    );
  }
}

// Ryuuiisou 「緑一色」, or "all green" in English, is a yakuman scored when the hand is composed entirely of the
// following tiles: 2, 3, 4, 6, 8 of souzu, and/or the green dragon tiles.
class RyuuiisouYaku extends Yakuman {
  const RyuuiisouYaku();

  @override
  bool matches(Context context) {
    return context.structure.tiles.every((e) => e.isGreen);
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .ryuuiisou,
      value: 13,
    );
  }
}

// Suukantsu 「四槓子」 is a yakuman scored when the hand has called kan four times. Suukantsu is the rarest hand in the
// round, even rarer than tenhou or chiihou. It is also the longest, requiring 18 tiles total.
class SuuankouYaku extends Yakuman {
  const SuuankouYaku();

  bool isDoubleYakuman(Context context) {
    return context.waits.contains(const Tanki()) &&
        context.rules.doubleYakumanHands.contains(DoubleYakumanRule.suuankouTanki);
  }

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final pons = structure.melds.whereType<ClosedPonSequence>().length;
    return pons == 4;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    if (isDoubleYakuman(context)) {
      yield const YakuResult(
        yaku: .suuankou,
        value: 26,
      );
    } else {
      yield const YakuResult(
        yaku: .suuankou,
        value: 13,
      );
    }
  }
}

// Suukantsu 「四槓子」 is a yakuman scored when the hand has called kan four times. Suukantsu is the rarest hand in the
// round, even rarer than tenhou or chiihou. It is also the longest, requiring 18 tiles total.
class SuukantsuYaku extends Yakuman {
  const SuukantsuYaku();

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final kans = structure.melds.whereType<KanSequence>().length;
    return kans == 4;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    yield const YakuResult(
      yaku: .suukantsu,
      value: 13,
    );
  }
}

// Chuuren poutou 「九連宝燈」 or 「九蓮宝燈」 (lit. "nine-connected treasure lamp" or "nine-lotus treasure lamp") is a
// yakuman scored when a hand contains the 13-tile pattern of: 1-1-1-2-3-4-5-6-7-8-9-9-9 of the same suit, plus any one
// tile from the same suit. In addition, the hand must be closed. Calling a kan on the 1 or 9 invalidates the yakuman.
// It is known in English as nine gates.
class ChuurenPoutouYaku extends Yakuman {
  const ChuurenPoutouYaku();

  bool isDoubleYakuman(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    final extraTile = _extraTile(structure.tiles);
    if (extraTile == null) return false;

    final winning = context.structure.winningTile.id;
    return winning is SuitTileId &&
        winning.value == extraTile &&
        context.rules.doubleYakumanHands.contains(
          DoubleYakumanRule.junseiChuurenPoutou,
        );
  }

  @override
  bool matches(Context context) {
    final structure = context.structure;
    if (structure is! StandardHand) return false;

    // must be fully closed
    if (structure.melds.any((m) => !m.isClosed)) return false;

    return _extraTile(structure.tiles) != null;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    if (isDoubleYakuman(context)) {
      yield const YakuResult(
        yaku: .chuurenPoutou,
        value: 26,
      );
    } else {
      yield const YakuResult(
        yaku: .chuurenPoutou,
        value: 13,
      );
    }
  }

  int? _extraTile(Iterable<Tile> tiles) {
    final suitTiles = tiles.map((t) => t.id).whereType<SuitTileId>().toList();
    if (suitTiles.length != 14) return null;

    // must all be same suit
    final suit = suitTiles.first.suit;
    if (suitTiles.any((t) => t.suit != suit)) return null;

    final counts = List<int>.filled(10, 0);
    for (final tile in suitTiles) {
      counts[tile.value]++;
    }

    const base = [
      0,
      3, // 1
      1, // 2
      1, // 3
      1, // 4
      1, // 5
      1, // 6
      1, // 7
      1, // 8
      3, // 9
    ];

    int? extraTile;

    for (var i = 1; i <= 9; i++) {
      if (counts[i] == base[i]) continue;

      if (extraTile == null && counts[i] == base[i] + 1) {
        extraTile = i;
        continue;
      }

      return null;
    }

    return extraTile;
  }
}

// Kokushi musou 「国士無双」, kokushi for short, or thirteen orphans in English, is one of the standard yakuman hands.
// It is one of the two exceptions of the "four tile groups and one pair" requirement for winning hands, the other
// being chiitoitsu. Kokushi requires having 13 unique terminal/honor tiles, and a duplicate of any one of these tiles.
class KokushiMusouYaku extends Yakuman {
  const KokushiMusouYaku();

  bool isDoubleYakuman(Context context) {
    return context.waits.contains(const KokushiMusoJusanmen()) &&
        context.rules.doubleYakumanHands.contains(DoubleYakumanRule.kokushi13Wait);
  }

  @override
  bool matches(Context context) {
    return context.structure is ThirteenOrphansHand;
  }

  @override
  Iterable<YakuResult> _results(Context context) sync* {
    if (isDoubleYakuman(context)) {
      yield const YakuResult(
        yaku: .kokushiMusou,
        value: 26,
      );
    } else {
      yield const YakuResult(
        yaku: .kokushiMusou,
        value: 13,
      );
    }
  }
}

const yakuList = [
  // Closed Only
  RiichiYaku(),
  DoubleRiichiYaku(),
  IppatsuYaku(),
  MenzenTsumoYaku(),
  PinfuYaku(),
  IipeikouYaku(),

  // Open or Closed
  TanyaoYaku(),
  YakuhaiYaku(),

  // Win-Condition Yaku
  HaiteiYaku(),
  HouteiYaku(),
  RinshanYaku(),
  ChankanYaku(),

  // 2 Han
  SanshokuDoujunYaku(),
  IttsuuYaku(),
  ToitoiYaku(),
  SanankouYaku(),
  SanshokuDoukouYaku(),
  ChiitoitsuYaku(),
  ChantaYaku(),
  ShousangenYaku(),
  HonroutouYaku(),

  // 3 Han
  RyanpeikouYaku(),
  JunchanYaku(),
  HonitsuYaku(),

  // 5-6 Han
  ChinitsuYaku(),
];

const yakumanList = [
  // Yakuman
  ShousuushiiYaku(),
  DaisuushiiYakuman(),
  DaisangenYaku(),
  TsuuiisouYaku(),
  ChinroutouYaku(),
  RyuuiisouYaku(),
  SuuankouYaku(),
  SuukantsuYaku(),
  ChuurenPoutouYaku(),
  KokushiMusouYaku(),
];
