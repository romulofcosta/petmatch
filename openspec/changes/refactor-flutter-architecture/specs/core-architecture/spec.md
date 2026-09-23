## Purpose

Provides foundational architecture building blocks used across all PetMatch features: the Result/Either pattern for declarative error handling, domain value objects (GeoPoint, Geohash, Email) that match the PostGIS schema, domain failure hierarchies, and the dependency injection container. This capability ensures consistency, testability, and schema alignment throughout the codebase.

## ADDED Requirements

### Requirement: Result pattern enables declarative error handling

- **Description:** The system SHALL provide a `Result<T, E>` sealed class with `Success<T, E>` and `Failure<T, E>` variants. All Use Cases, Repositories, and Services SHALL return `Result` types instead of throwing exceptions. ViewModels SHALL handle outcomes via `result.when(success: ..., failure: ...)` without try/catch blocks.

#### Scenario: Successful operation returns Success
- **WHEN** a Use Case executes successfully
- **THEN** it returns `Result.success(value)` containing the domain entity

#### Scenario: Failed operation returns Failure
- **WHEN** a Use Case encounters a validation error, network error, or server error
- **THEN** it returns `Result.failure(failure)` with a typed `Failure` instance
- **AND** the ViewModel can pattern-match on the failure type to show appropriate UI

#### Scenario: Network error is distinguishable from validation error
- **WHEN** a repository call fails due to no internet connectivity
- **THEN** the failure is a `NetworkFailure` (not a generic exception)
- **AND** the ViewModel can show a "check connection" message specifically

### Requirement: GeoPoint value object matches PostGIS GEOGRAPHY

- **Description:** The `GeoPoint` value object SHALL represent a WGS84 coordinate (latitude, longitude) with validation (-90 to 90, -180 to 180). It SHALL provide `toWkt()` returning `POINT(lng lat)` for Supabase inserts and `fromPostgis(Map)` for parsing PostGIS GeoJSON responses. It SHALL be immutable and equatable.

#### Scenario: GeoPoint converts to WKT for insert
- **WHEN** a `GeoPoint(latitude: -23.5505, longitude: -46.6333)` is inserted
- **THEN** `toWkt()` returns `POINT(-46.6333 -23.5505)` (longitude first per WKT spec)

#### Scenario: GeoPoint parses from PostGIS GeoJSON
- **WHEN** Supabase returns `{'type': 'Point', 'coordinates': [-46.6333, -23.5505]}`
- **THEN** `GeoPoint.fromPostgis(json)` returns `GeoPoint(latitude: -23.5505, longitude: -46.6333)`

#### Scenario: Invalid coordinates are rejected
- **WHEN** constructing `GeoPoint(latitude: 100, longitude: 0)`
- **THEN** construction throws `ArgumentError` / returns `Result.failure(ValidationFailure)`

### Requirement: Geohash value object provides encoding/decoding

- **Description:** The `Geohash` value object SHALL encode a `GeoPoint` to a base32 geohash string (default precision 9, ~2.5m). It SHALL provide `encode(GeoPoint)` and `decode(String)` for bounding box queries. It SHALL be immutable and equatable.

#### Scenario: Geohash encodes a coordinate
- **WHEN** encoding `GeoPoint(latitude: -23.5505, longitude: -46.6333)` at precision 9
- **THEN** the result is `6gyf4bf8m` (or equivalent base32 encoding)

#### Scenario: Geohash decodes to bounding box
- **WHEN** decoding a geohash string
- **THEN** the result includes min/max latitude/longitude for proximity queries

### Requirement: Domain failure hierarchies categorize errors

- **Description:** The system SHALL define `Failure` base class with feature-specific hierarchies: `AuthFailure` (Validation, Network, Server, RateLimited, Unauthorized), `PetFailure` (Validation, Network, Server, Permission, NotFound), and `CommonFailure` (Unknown). Each failure SHALL carry a user-facing message and optional technical code.

#### Scenario: Auth failure carries localized message
- **WHEN** an `UnauthorizedFailure` is created
- **THEN** its `message` is `'Email ou senha incorretos'` (Portuguese, user-facing)

#### Scenario: Failure includes technical code for logging
- **WHEN** a `NetworkFailure` wraps a `SocketException`
- **THEN** its `code` is `'socket_exception'` and `originalError` preserves the exception

### Requirement: Dependency injection container binds interfaces to implementations

- **Description:** The `di/injection_container.dart` SHALL register all Repository interfaces → implementations, Service interfaces → implementations, and Use Cases. It SHALL be initialized in `main.dart` before `runApp`. Tests SHALL be able to override bindings with mocks via `get_it` or Riverpod `ProviderScope` overrides.

#### Scenario: Production bindings resolve correctly
- **WHEN** the app starts
- **THEN** `PetRepository` resolves to `PetRepositoryImpl`
- **AND** `PetRepositoryImpl` receives `SupabaseService` and `GeolocationService` instances

#### Scenario: Test bindings override with mocks
- **WHEN** a widget test sets up a `ProviderScope` with overridden providers
- **THEN** `PetRepository` resolves to a `MockPetRepository`
- **AND** the test can verify interactions without network calls

### Requirement: Services layer isolates external dependencies

- **Description:** The `data/services/` layer SHALL contain stateless classes wrapping external APIs: `SupabaseService` (all raw Supabase/Postgres queries), `GeolocationService` (geolocator plugin), `AuthService` (Google/Apple OAuth). Repositories SHALL depend on Service interfaces, not concrete Supabase/geolocator classes.

#### Scenario: SupabaseService encapsulates all pet queries
- **WHEN** `PetRepositoryImpl` needs to insert a pet
- **THEN** it calls `supabaseService.insertPet(dto)` instead of `_supabase.from('pets').insert(...)`
- **AND** the service handles the raw query, mapping, and error translation

#### Scenario: GeolocationService returns Result
- **WHEN** `GeolocationService.getCurrentPosition()` is called
- **THEN** it returns `Result<GeoPoint, LocationFailure>`
- **AND** permission denied returns `PermissionFailure`, not an exception

### Requirement: DTOs use composition and explicit domain mapping

- **Description:** Data Transfer Objects (`UserDto`, `PetDto`) SHALL NOT inherit from domain entities. They SHALL provide `toDomain()` → `User`/`Pet` and `fromDomain(User)` / `fromDomain(Pet)` factory constructors. DTOs SHALL match the exact Supabase column names and types (snake_case, PostGIS GeoJSON for location).

#### Scenario: PetDto maps to Pet entity
- **WHEN** `PetDto.fromJson(supabaseResponse).toDomain()` is called
- **THEN** the resulting `Pet` has `GeoPoint` and `Geohash` (not raw doubles)
- **AND** all optional fields map correctly (null → null, empty list → empty list)

#### Scenario: Pet entity maps to DTO for insert
- **WHEN** `PetDto.fromDomain(pet, geoPoint)` is called
- **THEN** the DTO contains `location: 'POINT(lng lat)'` and `geohash: '6gyf4bf8m'`
- **AND** no `latitude`/`longitude` keys exist in the insert map