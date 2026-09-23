import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/entities/pet_interest.dart';

void main() {
  group('PetInterest', () {
    test('cobre todos os interesses suportados pelo banco', () {
      final dbValues =
          PetInterest.values.map((interest) => interest.toDb()).toList();

      expect(
        dbValues,
        containsAll(['socialization', 'breeding', 'adoption']),
      );
      // Mesmo conjunto da constraint CHECK do schema.
      expect(dbValues.toSet(), {'socialization', 'breeding', 'adoption'});
    });

    test('fromDb resolve os valores conhecidos', () {
      expect(PetInterest.fromDb('socialization'), PetInterest.socialization);
      expect(PetInterest.fromDb('breeding'), PetInterest.breeding);
      expect(PetInterest.fromDb('adoption'), PetInterest.adoption);
    });

    test('fromDb rejeita valor desconhecido com erro tipado', () {
      expect(() => PetInterest.fromDb('grooming'), throwsFormatException);
      expect(() => PetInterest.fromDb(''), throwsFormatException);
    });

    test('toDb escreve o valor esperado pelo banco', () {
      expect(PetInterest.socialization.toDb(), 'socialization');
      expect(PetInterest.breeding.toDb(), 'breeding');
      expect(PetInterest.adoption.toDb(), 'adoption');
    });
  });
}
