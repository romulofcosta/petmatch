import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/entities/pet_type.dart';

void main() {
  group('PetType', () {
    test('cobre todos os tipos suportados pelo banco', () {
      final dbValues = PetType.values.map((type) => type.toDb()).toList();

      expect(dbValues, containsAll(['dog', 'cat']));
      expect(dbValues, ['dog', 'cat']);
    });

    test('fromDb resolve os valores conhecidos', () {
      expect(PetType.fromDb('dog'), PetType.dog);
      expect(PetType.fromDb('cat'), PetType.cat);
    });

    test('fromDb arredonda corretamente para case exato (case-sensitive)', () {
      expect(() => PetType.fromDb('Dog'), throwsFormatException);
    });

    test('fromDb rejeita valor desconhecido com erro tipado', () {
      expect(() => PetType.fromDb('bird'), throwsFormatException);
      expect(() => PetType.fromDb(''), throwsFormatException);
    });

    test('toDb escreve o valor esperado pelo banco', () {
      expect(PetType.dog.toDb(), 'dog');
      expect(PetType.cat.toDb(), 'cat');
    });
  });
}
