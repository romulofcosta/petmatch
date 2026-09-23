import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/value_objects/failures/common_failure.dart';
import 'package:petmatch/domain/value_objects/failures/unknown_failure.dart';

void main() {
  group('CommonFailure (base)', () {
    test('carrega message, code e originalError', () {
      const failure = _StubFailure(
        message: 'algo falhou',
        code: 'stub',
        originalError: 'causa',
      );

      expect(failure.message, 'algo falhou');
      expect(failure.code, 'stub');
      expect(failure.originalError, 'causa');
    });

    test('code padrão é unknown quando não informado', () {
      const failure = _StubFailure(message: 'sem code');

      expect(failure.code, 'unknown');
      expect(failure.originalError, isNull);
    });

    test('toString inclui tipo, message e code', () {
      const failure = _StubFailure(message: 'x', code: 'y');

      expect(failure.toString(), contains('_StubFailure'));
      expect(failure.toString(), contains('message: x'));
      expect(failure.toString(), contains('code: y'));
    });
  });

  group('UnknownFailure', () {
    test('carrega mensagem e código específico', () {
      const failure = UnknownFailure(message: 'boom');

      expect(failure, isA<CommonFailure>());
      expect(failure.code, 'unknown_error');
      expect(failure.message, 'boom');
    });

    test('fromError preserva o erro original para logging', () {
      final cause = StateError('postgres down');
      final failure = UnknownFailure.fromError(cause);

      expect(failure.message, 'Erro inesperado. Tente novamente.');
      expect(failure.originalError, same(cause));
    });

    test('fromError aceita mensagem customizada', () {
      final failure = UnknownFailure.fromError(
        const FormatException('bad json'),
        message: 'Falha ao interpretar resposta.',
      );

      expect(failure.message, 'Falha ao interpretar resposta.');
      expect(failure.originalError, isA<FormatException>());
    });
  });
}

class _StubFailure extends CommonFailure {
  const _StubFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}
