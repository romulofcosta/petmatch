import '../entities/pet_entity.dart';

abstract class PetRepositoryInterface {
  Future<List<PetEntity>> getMyPets();
  Future<PetEntity?> getPetById(String petId);
  Future<PetEntity> createPet({
    required String name,
    required String type,
    required String sex,
    required String breed,
    required String breedGroup,
    required DateTime birthDate,
    required List<String> interests,
    required String mainPhotoUrl,
    required double latitude,
    required double longitude,
    double? weightKg,
    String? description,
    List<String>? personalityTags,
    List<String>? photos,
  });
  Future<void> updatePet({
    required String petId,
    String? name,
    String? type,
    String? sex,
    String? breed,
    String? breedGroup,
    DateTime? birthDate,
    double? weightKg,
    String? description,
    List<String>? personalityTags,
    List<String>? interests,
    String? mainPhotoUrl,
    List<String>? photos,
  });
  Future<void> deletePet(String petId);
  Future<void> togglePetActive(String petId, bool isActive);
}
