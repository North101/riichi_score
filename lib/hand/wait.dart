import '/hand.dart';
import '/tile.dart';

sealed class Wait {
  const Wait();
}

sealed class StandardWait extends Wait {
  const StandardWait();
}

class Ryanmen extends StandardWait {
  const Ryanmen();
}

class Kanchan extends StandardWait {
  const Kanchan();
}

class Penchan extends StandardWait {
  const Penchan();
}

class Tanki extends StandardWait {
  const Tanki();
}

class Shanpon extends StandardWait {
  const Shanpon();
}

sealed class ThirteenOrphansWait extends Wait {
  const ThirteenOrphansWait();
}

class KokushiMusoTanki extends ThirteenOrphansWait {
  const KokushiMusoTanki();
}

class KokushiMusoJusanmen extends ThirteenOrphansWait {
  const KokushiMusoJusanmen();
}

class WaitAnalyzer {
  const WaitAnalyzer();

  Set<StandardWait> analyzeStandardHand(StandardHand structure) {
    final melds = structure.melds;
    final pair = structure.pair;
    final winningTile = structure.winningTile;

    final waits = <StandardWait>{};

    // Tanki
    if (pair.tiles.first == winningTile) {
      waits.add(const Tanki());
    }

    // Shanpon:
    // Winning tile completes a triplet (pon) while hand has another pair.
    final matchingMelds = melds.whereType<PonSequence>().where((m) => m.tiles.first == winningTile);
    if (matchingMelds.isNotEmpty) {
      waits.add(const Shanpon());
    }

    // Suit-based waits
    if (winningTile.id case SuitTileId(:final value)) {
      for (final meld in melds.whereType<ChiiSequence>()) {
        if (!meld.tiles.contains(winningTile)) continue;

        final first = meld.tiles[0].id.value;
        final second = meld.tiles[1].id.value;
        final third = meld.tiles[2].id.value;

        if ((first == 1 && value == 3) || (third == 9 && value == 7)) {
          waits.add(const Penchan());
        } else if (value == first || value == third) {
          waits.add(const Ryanmen());
        }
        if (value == second) {
          waits.add(const Kanchan());
        }
      }
    }

    return waits;
  }

  Set<Tanki> analyzeSevenPairsHand(SevenPairsHand structure) => const {Tanki()};

  Set<ThirteenOrphansWait> analyzeThirteenOrphansHand(ThirteenOrphansHand structure) {
    final winningTile = structure.winningTile;
    final pair = structure.pair;
    if (winningTile.id == pair.first.id) {
      return const {KokushiMusoJusanmen()};
    }
    return const {KokushiMusoTanki()};
  }

  Set<Wait> analyze(HandStructure structure) => switch (structure) {
    StandardHand() => analyzeStandardHand(structure),
    SevenPairsHand() => analyzeSevenPairsHand(structure),
    ThirteenOrphansHand() => analyzeThirteenOrphansHand(structure),
  };
}
