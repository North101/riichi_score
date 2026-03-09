import 'package:riichi_score/score.dart';
import 'package:riichi_score/tile.dart';
import 'package:riichi_score/win.dart';
import 'package:test/test.dart';

void main() {
  final calculator = const ScoreCalculator();

  group('ScoreCalculator', () {
    test('calculates base points for low han/fu', () {
      final result = calculator.calculate(
        han: 2,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, isNull);
      // base points = fu * 2^(2+han) = 30 * 2^(2+2) = 30 * 16 = 480
      expect(result.basePoints, equals(480));
      expect(result.payment, isA<TsumoPayment>());
    });

    test('detects mangan at 5 han', () {
      final result = calculator.calculate(
        han: 5,
        fu: 30,
        seatWind: Wind.east,
        agari: const Ron(from: Wind.south),
      );

      expect(result.limit, equals(Limit.mangan));
      expect(result.basePoints, equals(Limit.mangan.points));
      expect(result.payment, isA<RonPayment>());
    });

    test('detects mangan at 4 han, 40+ fu', () {
      final result = calculator.calculate(
        han: 4,
        fu: 40,
        seatWind: Wind.east,
        agari: const Ron(from: Wind.south),
      );

      expect(result.limit, equals(Limit.mangan));
      expect(result.basePoints, equals(Limit.mangan.points));
    });

    test('does not detect mangan at 4 han, 30 fu', () {
      final result = calculator.calculate(
        han: 4,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, isNull);
    });

    test('detects haneman, baiman, sanbaiman, yakuman', () {
      expect(
        calculator.calculate(han: 6, fu: 30, seatWind: Wind.east, agari: const Tsumo()).limit,
        Limit.haneman,
      );
      expect(
        calculator.calculate(han: 8, fu: 30, seatWind: Wind.east, agari: const Tsumo()).limit,
        Limit.baiman,
      );
      expect(
        calculator.calculate(han: 11, fu: 30, seatWind: Wind.east, agari: const Tsumo()).limit,
        Limit.sanbaiman,
      );
      expect(
        calculator.calculate(han: 13, fu: 30, seatWind: Wind.east, agari: const Tsumo()).limit,
        Limit.yakuman,
      );
    });

    test('calculates tsumo payment with honba', () {
      final result = calculator.calculate(
        han: 2,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
        honbaCount: 2,
      );

      final payment = result.payment as TsumoPayment;
      expect(payment.honbaCount, 2);
      expect(payment.basePoints, result.basePoints);
      expect(payment.winner, Wind.east);
    });

    test('calculates ron payment with honba', () {
      final result = calculator.calculate(
        han: 2,
        fu: 30,
        seatWind: Wind.east,
        agari: const Ron(from: Wind.south),
        honbaCount: 1,
      );

      final payment = result.payment as RonPayment;
      expect(payment.honbaCount, 1);
      expect(payment.from, Wind.south);
      expect(payment.winner, Wind.east);
    });
  });

  group('ScoreCalculator limits', () {
    test('yakuman (>=13 han)', () {
      final result = calculator.calculate(
        han: 13,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, Limit.yakuman);
    });

    test('sanbaiman (11-12 han)', () {
      final result = calculator.calculate(
        han: 11,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, Limit.sanbaiman);
    });

    test('baiman (8-10 han)', () {
      final result = calculator.calculate(
        han: 8,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, Limit.baiman);
    });

    test('haneman (6-7 han)', () {
      final result = calculator.calculate(
        han: 6,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, Limit.haneman);
    });
  });

  group('Mangan boundary tests', () {
    test('5 han is mangan', () {
      final result = calculator.calculate(
        han: 5,
        fu: 20,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, Limit.mangan);
    });

    test('4 han + 40 fu is mangan', () {
      final result = calculator.calculate(
        han: 4,
        fu: 40,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, Limit.mangan);
    });

    test('4 han + 30 fu is NOT mangan', () {
      final result = calculator.calculate(
        han: 4,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, isNull);
    });

    test('3 han + 70 fu is mangan', () {
      final result = calculator.calculate(
        han: 3,
        fu: 70,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, Limit.mangan);
    });

    test('3 han + 60 fu is NOT mangan', () {
      final result = calculator.calculate(
        han: 3,
        fu: 60,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.limit, isNull);
    });
  });

  group('Payment type tests', () {
    test('ron creates RonPayment', () {
      final result = calculator.calculate(
        han: 2,
        fu: 30,
        seatWind: Wind.east,
        agari: const Ron(from: Wind.south),
      );

      expect(result.payment, isA<RonPayment>());
    });

    test('tsumo creates TsumoPayment', () {
      final result = calculator.calculate(
        han: 2,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
      );

      expect(result.payment, isA<TsumoPayment>());
    });

    test('honba increases base payment', () {
      final result = calculator.calculate(
        han: 2,
        fu: 30,
        seatWind: Wind.east,
        agari: const Tsumo(),
        honbaCount: 2,
      );

      final payment = result.payment as TsumoPayment;
      expect(payment.honbaCount, 2);
    });
  });
}
