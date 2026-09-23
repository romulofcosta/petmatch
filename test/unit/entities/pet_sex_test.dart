import 'package:flutter_test/flutter_test.dart';
import 'package:petmatch/domain/entities/pet_sex.dart';

void main() {
  group('PetSex', () {
    test('cobre todos os sexos suportados pelo banco', () {
      final dbValues = PetSex.values.map((sex) => sex.toDb()).toList();

      expect(dbValues, ['male', 'female']);
    });

    test('fromDb resolve os valores conhecidos', () {
      expect(PetSex.fromDb('male'), PetSex.male);
      expect(PetSex.fromDb('female'), PetSex.female);
    });

    test('fromDb rejeita valor desconhecido com erro tipado', () {
      expect(() => PetSex.fromDb('other'), throwsFormatException);
      expect(() => PetSex.fromDb(''), throwsFormatException);
    });

    test('toDb escreve o valor esperado pelo banco', () {
      expect(PetSex.male.toDb(), 'male');
      expect(PetSex.female.toDb(), 'female');
    });
  });
}
