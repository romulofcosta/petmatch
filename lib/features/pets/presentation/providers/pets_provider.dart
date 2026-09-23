import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/pet_repository.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/repositories/pet_repository_interface.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final petRepositoryProvider = Provider<PetRepositoryInterface>((ref) {
  return PetRepository();
});

final myPetsProvider = FutureProvider<List<PetEntity>>((ref) async {
  final repository = ref.read(petRepositoryProvider);
  return repository.getMyPets();
});

final petCountProvider = Provider<int>((ref) {
  final petsAsync = ref.watch(myPetsProvider);
  return petsAsync.when(
    data: (pets) => pets.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final canAddPetProvider = Provider<bool>((ref) {
  final count = ref.watch(petCountProvider);
  final result = ref.watch(authStateProvider).valueOrNull;
  final isPremium = result?.user?.isPremium ?? false;
  if (isPremium) return true;
  return count < 2;
});

class PetFormNotifier extends StateNotifier<AsyncValue<void>> {
  final PetRepositoryInterface _repository;

  PetFormNotifier(this._repository) : super(const AsyncData(null));

  Future<PetEntity?> createPet({
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
  }) async {
    state = const AsyncLoading();
    try {
      final pet = await _repository.createPet(
        name: name,
        type: type,
        sex: sex,
        breed: breed,
        breedGroup: breedGroup,
        birthDate: birthDate,
        interests: interests,
        mainPhotoUrl: mainPhotoUrl,
        weightKg: weightKg,
        description: description,
        personalityTags: personalityTags,
        photos: photos,
        latitude: latitude,
        longitude: longitude,
      );
      state = const AsyncData(null);
      return pet;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

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
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.updatePet(
        petId: petId,
        name: name,
        type: type,
        sex: sex,
        breed: breed,
        breedGroup: breedGroup,
        birthDate: birthDate,
        weightKg: weightKg,
        description: description,
        personalityTags: personalityTags,
        interests: interests,
        mainPhotoUrl: mainPhotoUrl,
        photos: photos,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deletePet(String petId) async {
    state = const AsyncLoading();
    try {
      await _repository.deletePet(petId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final petFormProvider =
    StateNotifierProvider<PetFormNotifier, AsyncValue<void>>((ref) {
  return PetFormNotifier(ref.read(petRepositoryProvider));
});
