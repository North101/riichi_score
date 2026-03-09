enum FuReason {
  base(20),
  closedRon(10),
  tsumo(2),
  tripletSimpleOpen(2),
  tripletSimpleClosed(4),
  tripletTerminalOpen(4),
  tripletTerminalClosed(8),
  kanSimpleOpen(8),
  kanSimpleClosed(16),
  kanTerminalOpen(16),
  kanTerminalClosed(32),
  valuePair(2),
  tankiWait(2),
  kanchanWait(2),
  penchanWait(2),
  sevenPairs(25)
  ;

  const FuReason(this.fu);

  final int fu;
}
