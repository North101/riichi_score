class Riichi {
  const Riichi({
    this.ippatsu = false,
  });

  final bool ippatsu;
}

class DoubleRiichi extends Riichi {
  const DoubleRiichi({
    super.ippatsu,
  });
}
