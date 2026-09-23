## Context

See [proposal.md - Why](proposal.md) for motivation. Current state:

- **Domain entities** (`UserEntity`, `PetEntity`) use raw `double latitude`/`longitude` — mismatch with PostGIS `location GEOGRAPHY(POINT,4326)` + `geohash VARCHAR(12)`.
- **Data models** extend domain entities (`PetModel extends PetEntity`) — coupling domain to data layer.
- **Repositories** contain raw Supabase queries and `geolocator` calls — no Services layer, hard to test.
- **Providers** (`AuthNotifier`, `PetFormNotifier`) mix form state, business logic, navigation — no Use Cases.
- **Error handling** is `try/catch` with `AppException` hierarchy — no declarative `Result` pattern.
- **Geolocation** lives in `shared/services/` — should be in `data/services/`.
- **DI** is ad-hoc via Riverpod providers — no centralized container for test overrides.

Database schema (source of truth): `supabase/migrations/001_initial_schema.sql` defines `users.location GEOGRAPHY(POINT,4326) NOT NULL`, `users.geohash VARCHAR(12) NOT NULL`, `pets.location GEOGRAPHY(POINT,4326) NOT NULL`, `pets.geohash VARCHAR(12) NOT NULL`. The `nearby_pets` function uses `ST_DWithin` on `location` and reads `age_months` from `pets_with_age` view.

## Goals / Non-Goals

**Goals:**
- Align domain entities with PostGIS schema: `GeoPoint` + `Geohash` value objects, no raw lat/lng.
- Introduce Services layer (`SupabaseService`, `GeolocationService`, `AuthService`) to isolate external dependencies.
- Introduce Use Cases for complex flows (`CreatePetUseCase`, `SignUpUseCase`, `GetNearbyPetsUseCase`).
- Implement `Result<T, E>` pattern for declarative error handling across all layers.
- Centralize DI in `di/injection_container.dart` using `get_it` (or Riverpod modules) for testability.
- Restructure folders to match `flutter-apply-architecture-best-practices`: `data/`, `domain/`, `ui/features/*/view_models/`, `ui/features/*/views/`.
- Zero-downtime migration: each phase verified by tests before next phase.

**Non-Goals:**
- Not rewriting UI widgets (`PetCardWidget`, `AppButton`, `AppTextField`, etc.).
- Not changing Supabase schema or Edge Functions (already correct).
- Not adding new features (feed, matches, chat) — foundation only.
- Not migrating to `freezed`/`built_value` — can be follow-up.
- Not changing Riverpod for state management — keep `ChangeNotifier` ViewModels.

## Decisions

### Decision: Value objects for PostGIS-native types (GeoPoint, Geohash)

**Choice:** Create `GeoPoint` and `Geohash` as immutable value objects in `domain/value_objects/`.

**Rationale:**
- Domain entities should reflect the *database reality* (PostGIS point + geohash), not the *old broken schema* (lat/lng doubles).
- `GeoPoint.toWkt()` → `POINT(lng lat)` matches Supabase insert format.
- `GeoPoint.fromPostgis(Map)` parses GeoJSON `{'type': 'Point', 'coordinates': [lng, lat]}`.
- `Geohash.encode(GeoPoint)` / `Geohash.decode(String)` enables proximity queries.
- Validation in constructors prevents invalid coordinates from entering domain.

**Alternatives considered:**
- Keep `double latitude, longitude` on entities + extension methods for WKT. Rejected: still leaks schema mismatch, no validation, no encapsulation.
- Use `LatLng` from `google_maps_flutter` or `geolocator`. Rejected: adds UI dependency to domain, wrong coordinate order for WKT.

### Decision: Composition over inheritance for DTOs

**Choice:** `UserDto` / `PetDto` in `data/models/` have `toDomain()` and `fromDomain()` methods. They do NOT extend `User` / `Pet`.

**Rationale:**
- Decouples domain from data layer. DB schema changes (new columns, renamed columns) only affect DTOs.
- Explicit mapping makes transformations visible and testable.
- DTOs can have snake_case fields matching Supabase; domain uses camelCase.

**Alternatives considered:**
- Keep `extends` (current). Rejected: coupling caused the lat/lng mismatch bug.
- Use `freezed` with `fromJson`/`toJson`. Rejected: adds codegen complexity; manual DTOs are fine for current scale.

### Decision: Services layer wraps all external APIs

**Choice:** Three services in `data/services/`:
- `SupabaseService`: ALL raw Supabase/Postgres queries (insert, select, update, delete, RPC calls).
- `GeolocationService`: `geolocator` plugin wrapper, returns `Result<GeoPoint, LocationFailure>`.
- `AuthService`: Google/Apple OAuth wrappers (currently in `AuthRepository`).

**Rationale:**
- Repositories become thin orchestrators: `repository.createPet()` → `service.insertPet(dto)`.
- Services are easily mocked in tests (no `SupabaseClient`/`Geolocator` in repository tests).
- Single place to add retry logic, caching, logging, error translation.

**Alternatives considered:**
- Keep queries in repositories. Rejected: current `PetRepository` is 170 lines with mixed concerns.
- Use `Repository` as service (no separate layer). Rejected: repositories should return domain entities, not raw maps.

### Decision: Use Cases for complex flows

**Choice:** Domain Use Cases in `domain/use_cases/`:
- `CreatePetUseCase` — validates age/interests, calls `GeolocationService`, delegates to `PetRepository`.
- `SignUpUseCase` — validates age, calls `AuthService`, calls `create-profile` Edge Function.
- `SignInUseCase` — email/password, Google, Apple; returns `Result<User, AuthFailure>`.
- `GetNearbyPetsUseCase` — calls `PetRepository.getNearby()` with filters.
- `UpdateProfileUseCase` — validates, calls `AuthRepository.updateProfile()`.

**Rationale:**
- ViewModels become pure presentation: collect form data → call Use Case → handle `Result`.
- Use Cases are reusable (e.g., `CreatePetUseCase` called from AddPetPage AND future import flow).
- Business logic (age validation, geolocation capture) is unit-testable without UI.

**Alternatives considered:**
- Keep logic in ViewModels. Rejected: `PetFormNotifier` + `AddPetPage._submit()` already tangle validation + geolocation + persistence.
- Put logic in Repositories. Rejected: repositories should be data access only; validation is domain logic.

### Decision: Result<T, E> pattern for error handling

**Choice:** `Result<T, E>` sealed class in `domain/value_objects/result.dart` with `Success`/`Failure`. Feature-specific failure hierarchies: `AuthFailure`, `PetFailure`, `CommonFailure`.

**Rationale:**
- Eliminates `try/catch` in ViewModels; failures are values, not control flow.
- Exhaustive matching via `result.when(success: ..., failure: ...)` ensures all error paths handled.
- Failure types enable specific UI (e.g., `PermissionFailure` → show permission rationale; `NetworkFailure` → show retry button).
- `originalError` field preserves stack traces for logging.

**Alternatives considered:**
- Keep `AppException` + `try/catch`. Rejected: exceptions are for exceptional cases; validation failures are expected.
- Use `Either<Failure, Success>` from `dartz`/`fpdart`. Rejected: adds dependency; sealed class is native and sufficient.

### Decision: Centralized DI with get_it

**Choice:** `di/injection_container.dart` using `get_it` (singleton registrations). Initialize in `main.dart` before `runApp`. Riverpod providers reference `get_it` for ViewModel injection.

**Rationale:**
- `get_it` is lightweight, widely used, supports `registerLazySingleton`, `registerFactory`.
- Easy to override in tests: `get_it.registerSingleton<PetRepository>(MockPetRepository())`.
- Riverpod providers stay simple: `Provider((ref) => get_it<AuthViewModel>())`.

**Alternatives considered:**
- Pure Riverpod DI (current). Rejected: hard to override in widget tests; no centralized view of bindings.
- `riverpod_generator` with `@riverpod` on classes. Rejected: adds codegen; `get_it` is simpler for this migration.

### Decision: Folder structure matches flutter-apply-architecture-best-practices

**Choice:** Rename `presentation/providers/` → `ui/features/*/view_models/`, `presentation/pages/` → `ui/features/*/views/`, `shared/services/` → `data/services/`. Add `domain/value_objects/`, `domain/use_cases/`, `domain/failures/`, `data/models/`, `di/`.

**Rationale:**
- Clear layer boundaries: `data/` = external concerns, `domain/` = business logic, `ui/` = presentation.
- Matches skill recommendation exactly.
- Scales to new features (feed, matches, chat) with consistent structure.

**Alternatives considered:**
- Keep current structure, just add new files. Rejected: current naming (`providers` for ViewModels) is confusing.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| **Phased migration breaks existing features** | Phase 1 (foundation) creates new files only; old code runs unchanged. Phase 2 (Use Cases) adds new logic. Phase 3 (ViewModels) migrates one page at a time with widget tests. Phase 4 deletes old code. |
| **DTO ↔ Domain mapping boilerplate** | Acceptable for ~10 entities. Use code snippets/templates. `freezed` can be adopted later if boilerplate becomes painful. |
| **Result pattern learning curve** | Document patterns in `domain/value_objects/result.dart` with examples. Team onboarding includes Result usage guide. |
| **get_it + Riverpod dual DI** | `get_it` for class bindings (Repository, Service, UseCase); Riverpod for ViewModel state. Clear separation: `get_it` = object graph, Riverpod = reactive state. |
| **GeoPoint/Geohash precision mismatch with PostGIS** | Use precision 9 (~2.5m) for geohash; PostGIS `GEOGRAPHY` is exact. Tests verify round-trip: `GeoPoint → WKT → PostGIS → GeoJSON → GeoPoint` preserves coordinates within 0.0001°. |
| **Existing tests break during migration** | Update tests incrementally per phase. Phase 1: update DTO/Service/Repository tests. Phase 2: add Use Case tests. Phase 3: update ViewModel/widget tests. |
| **No freezed/built_value for immutability** | Use `const` constructors, `Equatable` mixin, manual `copyWith`. Acceptable for current entity count. |
| **Edge Function `create-profile` still has hardcoded geohash** | Out of scope (owned by `unify-profile-creation`). This refactor only fixes client-side pet path. |

## Migration Plan (Detailed)

### Phase 1: Foundation (Week 1-2)
**Goal:** New domain/types/services/repositories coexist with old code.

1. `domain/value_objects/` — `geo_point.dart`, `geohash.dart`, `result.dart`, `failures/*`
2. `domain/entities/user.dart`, `pet.dart` — new entities with `GeoPoint` + `Geohash`
3. `data/models/user_dto.dart`, `pet_dto.dart` — DTOs with `toDomain()`/`fromDomain()`
4. `data/services/supabase_service.dart` — wrap all pet/user queries
5. Move `shared/services/geolocation_service.dart` → `data/services/geolocation_service.dart`, update to return `Result`
6. `data/services/auth_service.dart` — extract OAuth from `AuthRepository`
7. `domain/repositories/auth_repository.dart`, `pet_repository.dart` — interfaces
8. `data/repositories/auth_repository_impl.dart`, `pet_repository_impl.dart` — implementations using services
9. `di/injection_container.dart` — register all bindings
10. Update `main.dart` to initialize DI before `runApp`
11. **Verify:** Unit tests for DTOs, Services, Repositories (mock services). Old UI still works.

### Phase 2: Use Cases (Week 2)
**Goal:** Business logic extracted, testable in isolation.

1. `domain/use_cases/create_pet_use_case.dart`
2. `domain/use_cases/sign_up_use_case.dart`
3. `domain/use_cases/sign_in_use_case.dart`
4. `domain/use_cases/get_nearby_pets_use_case.dart`
5. `domain/use_cases/update_profile_use_case.dart`
6. Register Use Cases in DI
7. **Verify:** Unit tests for each Use Case (mock repositories). Old UI still works.

### Phase 3: ViewModels & UI Migration (Week 3-4)
**Goal:** One feature at a time, old providers coexist.

1. `ui/features/auth/view_models/auth_view_model.dart` — uses `SignInUseCase`, `SignUpUseCase`
2. `ui/features/auth/view_models/onboarding_view_model.dart` — uses `SignUpUseCase` + geolocation
3. Update `LoginPage`, `RegisterPage`, `OnboardingPage` to new ViewModels
4. `ui/features/pets/view_models/pets_view_model.dart` — uses `GetMyPetsUseCase` (new), `DeletePetUseCase`
5. `ui/features/pets/view_models/add_pet_view_model.dart` — uses `CreatePetUseCase`
6. Update `PetsPage`, `AddPetPage` to new ViewModels
7. **Verify:** Widget tests for each migrated page. Manual smoke test: sign up → onboarding → create pet → view pets.

### Phase 4: Cleanup (Week 4)
**Goal:** Remove dead code, verify full test suite.

1. Delete `lib/features/auth/domain/repositories/auth_repository_interface.dart`
2. Delete `lib/features/pets/domain/repositories/pet_repository_interface.dart`
3. Delete `lib/features/auth/presentation/providers/auth_provider.dart`
4. Delete `lib/features/pets/presentation/providers/pets_provider.dart`
5. Delete old `UserEntity`, `PetEntity` (replaced by domain entities)
6. Delete old `UserModel`, `PetModel` (replaced by DTOs)
7. Delete old `AuthRepository`, `PetRepository` (replaced by impls)
8. `flutter analyze` — zero errors
9. Full test suite — all pass
10. **Verify:** End-to-end manual test on device/emulator with live Supabase.

## Open Questions

1. **Use `get_it` or Riverpod modules for DI?**
   - `get_it` is simpler for this migration. Riverpod modules add codegen. Can decide in Phase 1.

2. **Where to put `Email` value object?**
   - Currently only used in auth. Could live in `domain/value_objects/email.dart` or stay as `String` in domain. Defer to Phase 1.

3. **Should `GeolocationService` be an interface + implementation?**
   - Yes, for testability. `GeolocationService` interface in `domain/services/`, impl in `data/services/`. Add in Phase 1.

4. **How to handle `PetFormNotifier` state during migration?**
   - `AddPetViewModel` will replace it. Keep both during Phase 3, delete in Phase 4.

5. **Does `GetNearbyPetsUseCase` belong in `pets` or `matching` capability?**
   - It's pet discovery, used by feed. For now, `domain/use_cases/get_nearby_pets_use_case.dart` under `pets`. Can move to `matching` later.