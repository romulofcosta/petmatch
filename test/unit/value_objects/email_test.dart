import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/value_objects/email.dart';

void main() {
  group('Email.isValid', () {
    test('aceita endereços válidos comuns', () {
      for (final valid in [
        'user@domain.com',
        'user.name+tag@domain.co',
        'user_name@sub.domain.org',
        'user%name@domain.io',
        'user-name@domain.br',
      ]) {
        expect(Email.isValid(valid), isTrue, reason: 'deveria aceitar: $valid');
      }
    });

    test('aceita espaços ao redor (trim)', () {
      expect(Email.isValid('  user@domain.com  '), isTrue);
    });

    test('aceita letras maiúsculas (normaliza para minúsculas)', () {
      expect(Email.isValid('User@Domain.com'), isTrue);
    });

    test('rejeita sem @', () {
      expect(Email.isValid('usuariodomain.com'), isFalse);
    });

    test('rejeita sem domínio', () {
      expect(Email.isValid('user@'), isFalse);
      expect(Email.isValid('user@domain'), isFalse);
    });

    test('rejeita sem TLD', () {
      expect(Email.isValid('user@domain.'), isFalse);
    });

    test('rejeita com espaços internos', () {
      expect(Email.isValid('user name@domain.com'), isFalse);
      expect(Email.isValid('user@domain .com'), isFalse);
    });

    test('rejeita vazio', () {
      expect(Email.isValid(''), isFalse);
      expect(Email.isValid('   '), isFalse);
    });
  });

  group('Email.parse', () {
    test('cria Email válido e normaliza para minúsculas', () {
      final email = Email.parse('  Admin@Domain.Com ');

      expect(email.value, 'admin@domain.com');
    });

    test('gera FormatException para endereço inválido', () {
      expect(() => Email.parse('invalido'), throwsFormatException);
      expect(() => Email.parse('sem-arroba.com'), throwsFormatException);
    });

    test('igualdade por valor normalizado', () {
      final a = Email.parse('user@domain.com');
      final same = Email.parse('USER@domain.com');
      final different = Email.parse('other@domain.com');

      expect(a, equals(same));
      expect(a, isNot(equals(different)));
    });

    test('toString devolve o endereço', () {
      expect(Email.parse('user@domain.com').toString(), 'user@domain.com');
    });
  });
}
