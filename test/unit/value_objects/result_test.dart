import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/value_objects/result.dart';

// Hierarquia mínima para os testes (as reais entram nas sub-issues #36-#38).
sealed class TestFailure {
  const TestFailure(this.message);
  final String message;
}

class NetworkFailure extends TestFailure {
  const NetworkFailure() : super('network');

  @override
  String toString() => 'NetworkFailure()';
}

class ServerFailure extends TestFailure {
  const ServerFailure() : super('server');

  @override
  String toString() => 'ServerFailure()';
}

void main() {
  group('Result<T, E>', () {
    group('Success', () {
      test('carrega o valor', () {
        const Result<int, TestFailure> result = Success(42);

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.valueOrNull, 42);
        expect(result.errorOrNull, isNull);
      });

      test('quando retorna o valor, com equals por tipo', () {
        const Result<int, TestFailure> result = Success(42);

        expect(result, isA<Success<int, TestFailure>>());
        expect((result as Success<int, TestFailure>).value, 42);
      });

      test('quando(instância) retorna o valor tipado', () {
        const Result<int, TestFailure> result = Success(42);

        expect(result.when(success: (v) => v, failure: (_) => -1), 42);
      });
    });

    group('Failure', () {
      test('carrega o erro', () {
        const Result<int, TestFailure> result = Failure(NetworkFailure());

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkFailure>());
        expect(result.valueOrNull, isNull);
      });

      test('quando retorna o erro, preservando o tipo', () {
        const Result<int, TestFailure> result = Failure(NetworkFailure());

        expect(
          result,
          isA<Failure<int, TestFailure>>(),
        );
        expect(
          (result as Failure<int, TestFailure>).error,
          isA<NetworkFailure>(),
        );
      });

      test('quando(instância) retorna o erro tipado', () {
        const Result<int, TestFailure> result = Failure(ServerFailure());

        expect(
          result.when(success: (v) => -1, failure: (e) => e.message),
          'server',
        );
      });
    });

    group('when()', () {
      test('executa apenas o callback do caso atual (success)', () {
        const Result<int, TestFailure> result = Success(10);

        var successCalls = 0;
        var failureCalls = 0;

        final killer = result.when(
          success: (value) {
            successCalls++;
            return value;
          },
          failure: (error) {
            failureCalls++;
            return -1;
          },
        );

        expect(killer, 10);
        expect(successCalls, 1);
        expect(failureCalls, 0);
      });

      test('executa apenas o callback do caso atual (failure)', () {
        const Result<int, TestFailure> result = Failure(NetworkFailure());

        var successCalls = 0;
        var failureCalls = 0;

        final killer = result.when(
          success: (value) {
            successCalls++;
            return value;
          },
          failure: (error) {
            failureCalls++;
            return error.message;
          },
        );

        expect(killer, 'network');
        expect(successCalls, 0);
        expect(failureCalls, 1);
      });

      test('permite mapear ambos os lados com tipos de retorno diferentes', () {
        const Result<int, TestFailure> result = Success(7);

        final label = result.when(
          success: (value) => 'valor=$value',
          failure: (error) => 'erro=${error.message}',
        );

        expect(label, 'valor=7');
      });
    });

    group('igualdade e toString', () {
      test('Success com mesmo valor é igual', () {
        const a = Success<int, TestFailure>(1);
        const b = Success<int, TestFailure>(1);
        const c = Success<int, TestFailure>(2);

        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });

      test('Failure com mesmo erro é igual', () {
        const a = Failure<int, TestFailure>(NetworkFailure());
        const b = Failure<int, TestFailure>(NetworkFailure());
        const c = Failure<int, TestFailure>(ServerFailure());

        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });

      test('toString identifica o caso', () {
        const ok = Success<int, TestFailure>(1);
        const err = Failure<int, TestFailure>(NetworkFailure());

        expect(ok.toString(), 'Success(1)');
        expect(err.toString(), 'Failure(NetworkFailure())');
      });
    });
  });
}
