## 1. Foundation: Value Objects & Result Pattern

- [x] 1.1 Create `lib/domain/value_objects/result.dart` with `Result<T, E>` sealed class, `Success`, `Failure`, and `when` pattern matching. **Verify:** `flutter test test/unit/value_objects/result_test.dart` passes.
- [x] 1.2 Create `lib/domain/value_objects/failures/common_failure.dart` with base `Failure` class and `UnknownFailure`. **Verify:** `flutter test test/unit/value_objects/failures_test.dart` passes.
- [x] 1.3 Create `lib/domain/value_objects/failures/auth_failure.dart` with `ValidationFailure`, `NetworkFailure`, `ServerFailure`, `RateLimitedFailure`, `UnauthorizedFailure`, `PermissionFailure`. **Verify:** Unit tests cover each failure type with message/code.
- [x] 1.4 Create `lib/domain/value_objects/failures/pet_failure.dart` with `ValidationFailure`, `NetworkFailure`, `ServerFailure`, `PermissionFailure`, `NotFoundFailure`. **Verify:** Unit tests cover each failure type.
- [ ] 1.5 Create `lib/domain/value_objects/geo_point.dart` with `latitude`, `longitude`, validation (-90..90, -180..180), `toWkt()` → `POINT(lng lat)`, `fromPostgis(Map)` parsing GeoJSON. **Verify:** `flutter test test/unit/value_objects/geo_point_test.dart` passes (WKT round-trip, GeoJSON parsing, validation).
- [ ] 1.6 Create `lib/domain/value_objects/geohash.dart` with `encode(GeoPoint, precision)`, `decode(String)`, base32 alphabet. **Verify:** `flutter test test/unit/value_objects/geohash_test.dart` passes (encode/decode round-trip, known values like São Paulo → `6gyf4bf8m`).
- [ ] 1.7 Create `lib/domain/value_objects/email.dart` with validation regex, `value` getter. **Verify:** Unit tests cover valid/invalid emails.

## 2. Foundation: Domain Entities

- [ ] 2.1 Create `lib/domain/entities/user.dart` with `uid`, `email`, `displayName`, `photoUrl`, `phone`, `birthDate`, `GeoPoint location`, `Geohash geohash`, `city`, `state`, `country`, `preferences`, `subscription`, `stats`, `isActive`, `isVerified`, `isBanned`, `createdAt`, `updatedAt`, `lastActiveAt`, `age`, `isPremium`, `copyWith`. **Verify:** `flutter test test/unit/entities/user_test.dart` passes.
- [ ] 2.2 Create `lib/domain/entities/pet.dart` with `id`, `ownerId`, `name`, `PetType type`, `PetSex sex`, `breed`, `breedGroup`, `birthDate`, `weightKg`, `description`, `personalityTags`, `List<PetInterest> interests`, `mainPhotoUrl`, `photos`, `GeoPoint location`, `Geohash geohash`, `veterinary`, `microchipId`, `isActive`, `createdAt`, `updatedAt`, `ageMonths`, `ageText`, `isEligibleForMatching`, `canBreed`, `isDog`, `isCat`, `isMale`, `isFemale`, `copyWith`. **Verify:** `flutter test test/unit/entities/pet_test.dart` passes.
- [ ] 2.3 Create `lib/domain/entities/pet_type.dart` and `pet_sex.dart` and `pet_interest.dart` enums. **Verify:** Used in Pet entity, tests pass.

## 3. Foundation: Data Models (DTOs)

- [ ] 3.1 Create `lib/data/models/user_dto.dart` matching Supabase `users` table (snake_case fields, `location` as GeoJSON Map, `geohash` String). Implement `fromJson`, `toJson`, `toDomain()`, `fromDomain(User)`. **Verify:** `flutter test test/unit/models/user_dto_test.dart` passes (JSON round-trip, domain mapping).
- [ ] 3.2 Create `lib/data/models/pet_dto.dart` matching Supabase `pets` table (snake_case, `location` GeoJSON, `geohash` String, `interests` List<String>). Implement `fromJson`, `toJson`, `toDomain()`, `fromDomain(Pet, GeoPoint)`. **Verify:** `flutter test test/unit/models/pet_dto_test.dart` passes.
- [ ] 3.3 Create `lib/data/models/create_pet_params.dart` for Use Case input (form data without location — location comes from GeolocationService). **Verify:** Unit test passes.

## 4. Foundation: Services Layer

- [ ] 4.1 Create `lib/domain/services/geolocation_service.dart` interface with `Future<Result<GeoPoint, LocationFailure>> getCurrentPosition()` and `Future<bool> isPermissionGranted()`. **Verify:** Interface compiles.
- [ ] 4.2 Create `lib/data/services/geolocation_service_impl.dart` implementing the interface, wrapping `geolocator` plugin, returning `Result<GeoPoint, LocationFailure>` (PermissionFailure, NetworkFailure). **Verify:** `flutter test test/unit/services/geolocation_service_test.dart` passes with mock `geolocator`.
- [ ] 4.3 Create `lib/domain/services/supabase_service.dart` interface with methods: `insertPet(Map)`, `getMyPets(String ownerId)`, `getPetById(String)`, `updatePet(String, Map)`, `softDeletePet(String)`, `insertUser(Map)`, `getUser(String)`, `updateUser(String, Map)`. **Verify:** Interface compiles.
- [ ] 4.4 Create `lib/data/services/supabase_service_impl.dart` implementing the interface, wrapping all raw Supabase queries from current `PetRepository` and `AuthRepository`. **Verify:** `flutter test test/unit/services/supabase_service_test.dart` passes with mock `SupabaseClient`.
- [ ] 4.5 Create `lib/domain/services/auth_service.dart` interface with `signInWithGoogle()`, `signInWithApple()`, `signInWithEmail()`, `signUpWithEmail()`. **Verify:** Interface compiles.
- [ ] 4.6 Create `lib/data/services/auth_service_impl.dart` extracting OAuth logic from current `AuthRepository`. **Verify:** Unit tests pass with mock `GoogleSignIn`/`SignInWithApple`.
- [ ] 4.7 Move `lib/shared/services/geolocation_service.dart` → `lib/data/services/geolocation_service_impl.dart` (already done in 4.2), delete old file. **Verify:** No import errors.

## 5. Foundation: Repository Interfaces & Implementations

- [ ] 5.1 Create `lib/domain/repositories/auth_repository.dart` interface with `signInWithEmail`, `signUpWithEmail`, `signInWithGoogle`, `signInWithApple`, `signOut`, `resetPassword`, `sendEmailVerification`, `createProfile`, `getProfile`, `updateProfile`, `authStateChanges` stream. All return `Result` or `Stream<Result>`. **Verify:** Interface compiles.
- [ ] 5.2 Create `lib/domain/repositories/pet_repository.dart` interface with `getMyPets`, `getPetById`, `createPet`, `updatePet`, `deletePet`, `togglePetActive`, `getNearbyPets`. All return `Result`. **Verify:** Interface compiles.
- [ ] 5.3 Create `lib/data/repositories/auth_repository_impl.dart` implementing `AuthRepository`, using `AuthService`, `SupabaseService`, `GeolocationService`. **Verify:** `flutter test test/unit/repositories/auth_repository_impl_test.dart` passes with mocked services.
- [ ] 5.4 Create `lib/data/repositories/pet_repository_impl.dart` implementing `PetRepository`, using `SupabaseService`, `GeolocationService`. **Verify:** `flutter test test/unit/repositories/pet_repository_impl_test.dart` passes with mocked services.
- [ ] 5.5 Create `lib/domain/repositories/nearby_pets_repository.dart` interface (or add to `PetRepository`) for `getNearbyPets` with filters. **Verify:** Interface compiles.

## 6. Foundation: Dependency Injection

- [ ] 6.1 Add `get_it: ^8.0.0` to `pubspec.yaml` dependencies. **Verify:** `flutter pub get` succeeds.
- [ ] 6.2 Create `lib/di/injection_container.dart` with `setup()` registering: all Service interfaces → impls, Repository interfaces → impls, Use Cases (Phase 7), ViewModels (Phase 9). Use `registerLazySingleton` for services/repos, `registerFactory` for ViewModels. **Verify:** `flutter test test/unit/di/injection_container_test.dart` passes (all bindings resolve).
- [ ] 6.3 Update `lib/main.dart` to call `await InjectionContainer.setup()` before `runApp`. **Verify:** App starts without DI errors.

## 7. Use Cases

- [ ] 7.1 Create `lib/domain/use_cases/create_pet_use_case.dart` with `CreatePetParams` input, validates age ≥120 days, interests not empty, calls `GeolocationService.getCurrentPosition()`, computes `Geohash`, calls `PetRepository.createPet()`. Returns `Result<Pet, PetFailure>`. **Verify:** `flutter test test/unit/use_cases/create_pet_use_case_test.dart` passes (success, validation failures, permission failure).
- [ ] 7.2 Create `lib/domain/use_cases/sign_up_use_case.dart` with validation (age ≥18, password strength), calls `AuthService.signUpWithEmail()`, then `AuthRepository.createProfile()` with geolocation. Returns `Result<User, AuthFailure>`. **Verify:** Unit tests pass.
- [ ] 7.3 Create `lib/domain/use_cases/sign_in_use_case.dart` with email/password, Google, Apple methods. Returns `Result<User, AuthFailure>`. **Verify:** Unit tests pass.
- [ ] 7.4 Create `lib/domain/use_cases/get_nearby_pets_use_case.dart` with filters (type, breed, sex, interest, radius, limit, offset), calls `PetRepository.getNearbyPets()`. Returns `Result<List<Pet>, PetFailure>`. **Verify:** Unit tests pass.
- [ ] 7.5 Create `lib/domain/use_cases/update_profile_use_case.dart` with validation, calls `AuthRepository.updateProfile()`. Returns `Result<User, AuthFailure>`. **Verify:** Unit tests pass.
- [ ] 7.6 Create `lib/domain/use_cases/get_my_pets_use_case.dart`, `delete_pet_use_case.dart`, `toggle_pet_active_use_case.dart` for completeness. **Verify:** Unit tests pass.
- [ ] 7.7 Register all Use Cases in `InjectionContainer.setup()`. **Verify:** DI test resolves all Use Cases.

## 8. ViewModels: Auth Feature

- [ ] 8.1 Create `lib/ui/features/auth/view_models/auth_view_model.dart` extending `ChangeNotifier`, using `SignInUseCase`, `SignUpUseCase`, `SignOutUseCase`. State: `AsyncValue<User?> user`, `String? error`, `bool isLoading`. Methods: `signInWithEmail`, `signUpWithEmail`, `signInWithGoogle`, `signInWithApple`, `signOut`, `resetPassword`. Handle `Result` via `when()`. **Verify:** `flutter test test/unit/view_models/auth_view_model_test.dart` passes.
- [ ] 8.2 Create `lib/ui/features/auth/view_models/onboarding_view_model.dart` using `SignUpUseCase` (which internally calls `createProfile` with geolocation), `GeolocationService`. State: form fields, `AsyncValue<void>`, `String? error`. Method: `completeOnboarding()`. **Verify:** Unit tests pass.
- [ ] 8.3 Update `lib/features/auth/presentation/pages/login_page.dart` to use `AuthViewModel` via `Provider`/`Consumer`. Remove direct `AuthRepository` calls. **Verify:** Widget test `test/widget/auth/login_page_test.dart` passes.
- [ ] 8.4 Update `lib/features/auth/presentation/pages/register_page.dart` to use `AuthViewModel`. **Verify:** Widget test passes.
- [ ] 8.5 Update `lib/features/auth/presentation/pages/onboarding_page.dart` to use `OnboardingViewModel`. **Verify:** Widget test passes.
- [ ] 8.6 Add Riverpod providers for new ViewModels in `lib/ui/features/auth/view_models/providers.dart` (or keep in same file). **Verify:** Providers resolve correctly in tests.

## 9. ViewModels: Pets Feature

- [ ] 9.1 Create `lib/ui/features/pets/view_models/pets_view_model.dart` extending `ChangeNotifier`, using `GetMyPetsUseCase`, `DeletePetUseCase`, `TogglePetActiveUseCase`. State: `AsyncValue<List<Pet>> pets`, `String? error`. Methods: `loadPets()`, `deletePet(id)`, `toggleActive(id)`. **Verify:** `flutter test test/unit/view_models/pets_view_model_test.dart` passes.
- [ ] 9.2 Create `lib/ui/features/pets/view_models/add_pet_view_model.dart` using `CreatePetUseCase`. State: form fields (name, type, sex, breed, breedGroup, birthDate, interests, weight, description, personalityTags, photos), `AsyncValue<void>`, `String? error`. Method: `submit()`. **Verify:** Unit tests pass.
- [ ] 9.3 Update `lib/features/pets/presentation/pages/pets_page.dart` to use `PetsViewModel`. **Verify:** Widget test `test/widget/pets/pets_page_test.dart` passes.
- [ ] 9.4 Update `lib/features/pets/presentation/pages/add_pet_page.dart` to use `AddPetViewModel`. Remove inline geolocation logic (now in Use Case). **Verify:** Widget test passes.
- [ ] 9.5 Add Riverpod providers for new ViewModels. **Verify:** Providers resolve correctly.

## 10. Routing & App Integration

- [ ] 10.1 Update `lib/routes/app_router.dart` if any route paths changed (should not). **Verify:** `flutter analyze` passes.
- [ ] 10.2 Update any remaining pages/widgets that reference old providers (e.g., `authStateProvider`, `petFormProvider`) to use new ViewModels. **Verify:** `flutter analyze` passes, no deprecated provider usage.
- [ ] 10.3 Update `lib/app.dart` if theme/initialization changed. **Verify:** App builds.

## 11. Cleanup & Verification

- [ ] 11.1 Delete `lib/features/auth/domain/repositories/auth_repository_interface.dart`. **Verify:** No import errors.
- [ ] 11.2 Delete `lib/features/pets/domain/repositories/pet_repository_interface.dart`. **Verify:** No import errors.
- [ ] 11.3 Delete `lib/features/auth/presentation/providers/auth_provider.dart`. **Verify:** No import errors.
- [ ] 11.4 Delete `lib/features/pets/presentation/providers/pets_provider.dart`. **Verify:** No import errors.
- [ ] 11.5 Delete `lib/features/auth/domain/entities/user_entity.dart` (replaced by `domain/entities/user.dart`). **Verify:** No import errors.
- [ ] 11.6 Delete `lib/features/pets/domain/entities/pet_entity.dart` (replaced by `domain/entities/pet.dart`). **Verify:** No import errors.
- [ ] 11.7 Delete `lib/features/auth/data/models/user_model.dart` (replaced by `data/models/user_dto.dart`). **Verify:** No import errors.
- [ ] 11.8 Delete `lib/features/pets/data/models/pet_model.dart` (replaced by `data/models/pet_dto.dart`). **Verify:** No import errors.
- [ ] 11.9 Delete `lib/features/auth/data/repositories/auth_repository.dart` (replaced by `data/repositories/auth_repository_impl.dart`). **Verify:** No import errors.
- [ ] 11.10 Delete `lib/features/pets/data/repositories/pet_repository.dart` (replaced by `data/repositories/pet_repository_impl.dart`). **Verify:** No import errors.
- [ ] 11.11 Run `flutter analyze` — **Verify:** Zero errors, zero warnings (pre-existing lints acceptable).
- [ ] 11.12 Run `flutter test` — **Verify:** All unit + widget tests pass (target: >80% coverage on domain/data layers).
- [ ] 11.13 Manual end-to-end test on device/emulator with live Supabase: sign up → onboarding (geolocation) → create pet (geolocation) → view pets → edit pet → delete pet. **Verify:** All flows work, data persists with correct `location`/`geohash`.

## 12. Documentation & Follow-up

- [ ] 12.1 Update `README.md` or `docs/architecture.md` with new layer structure and patterns (Result, Use Cases, DI). **Verify:** Documentation reflects current code.
- [ ] 12.2 Create ADR (Architecture Decision Record) for: Result pattern, Value Objects, Services layer, Use Cases, DI with get_it. **Verify:** ADR files in `docs/adr/`.
- [ ] 12.3 File follow-up OpenSpec changes for: `freezed` migration, `core-architecture` → shared package, feed/matches features using new foundation.