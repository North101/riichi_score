enum YakuType {
  // Closed Only
  riichi,
  doubleRiichi,
  ippatsu,
  menzenTsumo,
  pinfu,
  iipeikou,

  // Open or Closed
  tanyao,

  // Yakuhai
  yakuhaiSeatWind,
  yakuhaiRoundWind,
  yakuhaiWhiteDragon,
  yakuhaiGreenDragon,
  yakuhaiRedDragon,

  // Win-Condition Yaku
  haitei,
  houtei,
  rinshan,
  chankan,

  // 2 Han
  sanshokuDoujun,
  ittsuu,
  toitoi,
  sanankou,
  sanshokuDoukou,
  chiitoitsu,
  chanta,
  shousangen,
  honroutou,

  // 3 Han
  ryanpeikou,
  junchan,
  honitsu,

  // 5-6 Han
  chinitsu,

  // Yakuman
  shousuushii(true),
  daisuushii(true),
  daisangen(true),
  tsuuiisou(true),
  chinroutou(true),
  ryuuiisou(true),
  suuankou(true),
  suukantsu(true),
  chuurenPoutou(true),
  kokushiMusou(true)
  ;

  const YakuType([this.isYakuman = false]);

  final bool isYakuman;
}

sealed class HanResult {
  const HanResult();

  int get value;
}

class YakuResult extends HanResult {
  const YakuResult({
    required this.yaku,
    required this.value,
  });

  final YakuType yaku;
  @override
  final int value;
}

enum DoraType {
  dora,
  uraDora,
  akaDora,
}

class DoraResult extends HanResult {
  const DoraResult({
    required this.dora,
    required this.value,
  });

  final DoraType dora;
  @override
  final int value;
}
