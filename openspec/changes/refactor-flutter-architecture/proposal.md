## Why

The current Flutter codebase has **architectural drift** that creates maintenance burden, testing difficulty, and schema mismatches:

1. **Domain entities mirror the *old* broken schema** — `PetEntity` and `UserEntity` use `latitude`/`longitude` doubles, but the database uses PostGIS `location GEOGRAPHY` + `geohash`. This forces awkward parsing in `PetModel.fromMap()` (lines 30-46) and will cause bugs when the schema evolves.

2. **Data models inherit from domain entities** — `PetModel extends PetEntity`, `UserModel extends UserEntity`. This couples domain to data layer; any DB change ripples into domain.

3. **No Services layer** — Repositories (`PetRepository`, `AuthRepository`) contain raw Supabase queries and `geolocator` calls directly. Hard to unit test, swap data sources, or add caching/retry logic.

4. **ViewModels mix form state, business logic, and navigation** — `PetFormNotifier` + `AddPetPage._submit()` + `PetRepository` all tangle validation, geolocation capture, persistence, and cache invalidation.

5. **No Use Cases layer** — Complex flows (create pet, sign up, nearby pets) have no reusable, testable home. Logic is scattered across UI, providers, and repositories.

6. **Primitive error handling** — Only `try/catch` with `AppException` hierarchy. No `Result<T, E>` pattern; callers can't handle failures declaratively.

7. **Inconsistent layer naming** — `providers/` actually holds ViewModels; `shared/services/` holds a data service (`GeolocationService`).

---

## What Changes

### Target Architecture (per flutter-apply-architecture-best-practices)

```
lib/
├── app.dart, main.dart
├── core/                          # theme, constants, errors, utils, config (keep)
├── data/
│   ├── models/                    # DTOs (API/DB shapes) — user_dto.dart, pet_dto.dart
│   ├── repositories/              # Repository implementations — auth_repository_impl.dart, pet_repository_impl.dart
│   └── services/                  # External API wrappers — supabase_service.dart, geolocation_service.dart, auth_service.dart
├── domain/
│   ├── entities/                  # Clean domain models — user.dart, pet.dart
│   ├── value_objects/             # GeoPoint, Geohash, Email, etc.
│   ├── repositories/              # Repository interfaces (contracts) — auth_repository.dart, pet_repository.dart
│   ├── use_cases/                 # Business logic — create_pet_use_case.dart, sign_up_use_case.dart, get_nearby_pets_use_case.dart
│   └── failures/                  # Domain failures — validation_failure.dart, auth_failure.dart, network_failure.dart
├── ui/
│   ├── core/                      # Shared widgets, theme (keep)
│   └── features/
│       ├── auth/
│       │   ├── view_models/       # AuthViewModel, OnboardingViewModel
│       │   └── views/             # LoginPage, RegisterPage, OnboardingPage
│       ├── pets/
│       │   ├── view_models/       # PetsViewModel, AddPetViewModel
│       │   ├── views/             # PetsPage, AddPetPage
│       │   └── widgets/           # PetCardWidget
│       ├── feed/
│       │   ├── view_models/
│       │   └── views/
│       └── matches/
│           ├── view_models/
│           └── views/
└── di/                            # Dependency injection — injection_container.dart
```

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| **Composition over inheritance** | DTOs have `toDomain()` / `fromDomain()`; entities know nothing of DTOs |
| **PostGIS-native domain types** | `GeoPoint` + `Geohash` value objects match `location` + `geohash` columns |
| **Services layer** | `SupabaseService` wraps all raw queries; `GeolocationService` wraps platform plugin |
| **Use Cases for complex flows** | `CreatePetUseCase` encapsulates validation + geolocation + persistence |
| **Result/Either for errors** | `Result<T, Failure>` enables declarative error handling in ViewModels |
| **Riverpod for DI + State** | Keep Riverpod; add `di/` module for centralized binding (makes testing easier) |
| **ViewModels = `ChangeNotifier`** | Simple, testable, works with `ListenableBuilder` |

### Non-Goals

- Not rewriting UI widgets (PetCardWidget, AppButton, etc. stay)
- Not changing Supabase schema (already correct PostGIS)
- Not adding new features (feed, matches, chat) — this is foundation only
- Not migrating to `freezed`/`built_value` yet (can be follow-up)

---

## Impact

### Files to Create (~35 new files)

| Layer | Files |
|-------|-------|
| `domain/value_objects/` | `geo_point.dart`, `geohash.dart`, `email.dart`, `result.dart`, `failures/*.dart` |
| `domain/entities/` | `user.dart`, `pet.dart` (replace current entities) |
| `domain/repositories/` | `auth_repository.dart`, `pet_repository.dart` (rename interfaces) |
| `domain/use_cases/` | `create_pet_use_case.dart`, `sign_up_use_case.dart`, `get_nearby_pets_use_case.dart`, `sign_in_use_case.dart`, `update_profile_use_case.dart` |
| `data/models/` | `user_dto.dart`, `pet_dto.dart` |
| `data/services/` | `supabase_service.dart`, `geolocation_service.dart` (move), `auth_service.dart` |
| `data/repositories/` | `auth_repository_impl.dart`, `pet_repository_impl.dart` |
| `ui/features/auth/view_models/` | `auth_view_model.dart`, `onboarding_view_model.dart` |
| `ui/features/pets/view_models/` | `pets_view_model.dart`, `add_pet_view_model.dart` |
| `di/` | `injection_container.dart` |

### Files to Modify (~15 files)

| File | Change |
|------|--------|
| `lib/features/auth/domain/entities/user_entity.dart` | → `domain/entities/user.dart` (new, uses `GeoPoint`) |
| `lib/features/pets/domain/entities/pet_entity.dart` | → `domain/entities/pet.dart` (new, uses `GeoPoint`) |
| `lib/features/auth/data/models/user_model.dart` | → `data/models/user_dto.dart` (composition, `toDomain()`) |
| `lib/features/pets/data/models/pet_model.dart` | → `data/models/pet_dto.dart` (composition, `toDomain()`) |
| `lib/features/auth/data/repositories/auth_repository.dart` | → `data/repositories/auth_repository_impl.dart` (uses services) |
| `lib/features/pets/data/repositories/pet_repository.dart` | → `data/repositories/pet_repository_impl.dart` (uses services) |
| `lib/shared/services/geolocation_service.dart` | → `data/services/geolocation_service.dart` (returns `Result`) |
| `lib/features/auth/presentation/providers/auth_provider.dart` | → `ui/features/auth/view_models/auth_view_model.dart` |
| `lib/features/pets/presentation/providers/pets_provider.dart` | → `ui/features/pets/view_models/pets_view_model.dart` + `add_pet_view_model.dart` |
| `lib/features/auth/presentation/pages/*.dart` | Update to new ViewModels |
| `lib/features/pets/presentation/pages/*.dart` | Update to new ViewModels |
| `lib/main.dart` | Initialize DI container |
| `pubspec.yaml` | Add `get_it` or `riverpod` module deps if needed |

### Files to Delete (~8 files)

| File | Reason |
|------|--------|
| `lib/features/auth/domain/repositories/auth_repository_interface.dart` | Replaced by `domain/repositories/auth_repository.dart` |
| `lib/features/pets/domain/repositories/pet_repository_interface.dart` | Replaced by `domain/repositories/pet_repository.dart` |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Replaced by ViewModels |
| `lib/features/pets/presentation/providers/pets_provider.dart` | Replaced by ViewModels |

---

## Capabilities

### Modified Capabilities
- `auth`: Sign up/in, profile creation, profile update — now use Use Cases + Services + Result pattern
- `pets`: CRUD + geolocation — now use Use Cases + Services + Result pattern

### New Capabilities
- `core/architecture`: Result pattern, value objects, DI container — reusable across features

---

## Migration Strategy (Phased, Zero-Downtime)

### Phase 1: Foundation (no UI changes)
1. Add `domain/value_objects/` — `GeoPoint`, `Geohash`, `Result`, `Failures`
2. Add `domain/entities/user.dart`, `pet.dart` (with `GeoPoint` + `geohash`)
3. Add `data/models/user_dto.dart`, `pet_dto.dart` (with `toDomain()`/`fromDomain()`)
4. Add `data/services/supabase_service.dart`, move `geolocation_service.dart` → `data/services/`
5. Add `domain/repositories/auth_repository.dart`, `pet_repository.dart`
6. Add `data/repositories/auth_repository_impl.dart`, `pet_repository_impl.dart` (delegate to services)
7. Add `di/injection_container.dart` with all bindings
8. **Verify**: Unit tests pass for DTOs, Services, Repositories (mock services)

### Phase 2: Use Cases (no UI changes)
1. Add `domain/use_cases/` for each complex flow
2. Wire Use Cases → Repositories in DI
3. **Verify**: Unit tests pass for Use Cases (mock repositories)

### Phase 3: ViewModels (UI changes begin)
1. Add `ui/features/auth/view_models/auth_view_model.dart`, `onboarding_view_model.dart`
2. Add `ui/features/pets/view_models/pets_view_model.dart`, `add_pet_view_model.dart`
3. Update pages to use new ViewModels (one page at a time)
4. **Verify**: Widget tests pass; manual smoke test each page

### Phase 4: Cleanup
1. Delete old interface/provider files
2. Remove `latitude`/`longitude` from any remaining code
3. `flutter analyze` + full test suite green

---

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| **Big bang refactor breaks things** | Phased approach; each phase verified by tests before next |
| **Domain entities change breaks DTOs** | DTOs are separate; `toDomain()` is single conversion point |
| **Riverpod providers → ViewModels migration** | Do one feature at a time; old providers coexist during transition |
| **Team unfamiliar with Result pattern** | Keep `Failure` hierarchy simple; document patterns in `core/result/` |
| **DI container adds complexity** | Start simple with `get_it` or Riverpod modules; only bind interfaces |

---

## Success Criteria

- [ ] `flutter analyze` passes with no errors
- [ ] All unit tests pass (target: >80% coverage on domain/data layers)
- [ ] All widget tests pass
- [ ] Manual verification: sign up → onboarding → create pet → view pets works end-to-end
- [ ] No `latitude`/`longitude` in domain layer
- [ ] No raw Supabase calls in repositories (all via `SupabaseService`)
- [ ] No `geolocator` calls outside `GeolocationService`
- [ ] ViewModels have zero business logic (only form state + Use Case delegation)