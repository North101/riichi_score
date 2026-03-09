import '/tile.dart';

sealed class Agari {
  const Agari();
}

class Ron extends Agari {
  const Ron({required this.from});

  final Wind from;
}

class Houtei extends Ron {
  const Houtei({required super.from});
}

class Chankan extends Ron {
  const Chankan({required super.from});
}

class Tsumo extends Agari {
  const Tsumo();
}

class Haitei extends Tsumo {
  const Haitei();
}

class Rinshan extends Tsumo {
  const Rinshan();
}
