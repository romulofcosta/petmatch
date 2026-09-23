import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/geohash.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/repositories/pet_repository_interface.dart';
import '../models/pet_model.dart';

class PetRepository implements PetRepositoryInterface {
  final SupabaseClient _supabase;

  PetRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  String get _currentUserId {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw const AppAuthException(message: 'Usuário não autenticado');
    return uid;
  }

  @override
  Future<List<PetEntity>> getMyPets() async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('owner_id', _currentUserId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((map) => PetModel.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException(message: 'Erro ao carregar pets: $e');
    }
  }

  @override
  Future<PetEntity?> getPetById(String petId) async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('id', petId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (response == null) return null;
      return PetModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  @override
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
  }) async {
    try {
      final uid = _currentUserId;

      final data = {
        'owner_id': uid,
        'name': name,
        'type': type,
        'sex': sex,
        'breed': breed,
        'breed_group': breedGroup,
        'birth_date': birthDate.toIso8601String().split('T')[0],
        'weight_kg': weightKg,
        'description': description,
        'personality_tags': personalityTags ?? [],
        'interests': interests,
        'main_photo_url': mainPhotoUrl,
        'photos': photos ?? [],
        'location': 'POINT($longitude $latitude)',
        'geohash': encodeGeohash(latitude, longitude),
      };

      final response = await _supabase
          .from('pets')
          .insert(data)
          .select()
          .single();

      return PetModel.fromMap(response);
    } catch (e) {
      throw AppException(message: 'Erro ao criar pet: $e');
    }
  }

  @override
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
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (type != null) updates['type'] = type;
      if (sex != null) updates['sex'] = sex;
      if (breed != null) updates['breed'] = breed;
      if (breedGroup != null) updates['breed_group'] = breedGroup;
      if (birthDate != null) {
        updates['birth_date'] = birthDate.toIso8601String().split('T')[0];
      }
      if (weightKg != null) updates['weight_kg'] = weightKg;
      if (description != null) updates['description'] = description;
      if (personalityTags != null) updates['personality_tags'] = personalityTags;
      if (interests != null) updates['interests'] = interests;
      if (mainPhotoUrl != null) updates['main_photo_url'] = mainPhotoUrl;
      if (photos != null) updates['photos'] = photos;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
        await _supabase.from('pets').update(updates).eq('id', petId);
      }
    } catch (e) {
      throw AppException(message: 'Erro ao atualizar pet: $e');
    }
  }

  @override
  Future<void> deletePet(String petId) async {
    try {
      await _supabase.from('pets').update({
        'deleted_at': DateTime.now().toIso8601String(),
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', petId);
    } catch (e) {
      throw AppException(message: 'Erro ao excluir pet: $e');
    }
  }

  @override
  Future<void> togglePetActive(String petId, bool isActive) async {
    try {
      await _supabase.from('pets').update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', petId);
    } catch (e) {
      throw AppException(message: 'Erro ao alterar status do pet: $e');
    }
  }
}
