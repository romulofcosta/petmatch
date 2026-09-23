## MODIFIED Requirements

### Requirement: Pet registration captures required fields and validates them

- **Description:** Pet registration SHALL collect the pet's name (2-30 letters/spaces), type (dog|cat), sex (male|female), breed (from the controlled list), birth date, a main photo, at least one interest (socialization|breeding|adoption), and a geolocated position. The birth date MUST be at least 120 days old per Lei 17.972/24 and at most 20 years. The pet's position SHALL be persisted as a native PostGIS point (`location`) together with a real `geohash` derived from the tutor's current device location; placeholder or absent coordinates SHALL NOT be accepted.
- **Note:** Optional fields include up to 6 additional photos, weight (0.5-80kg), description (max 500 chars), up to 5 personality tags, neutered/vaccines/pedigree flags, veterinarian info, health notes (max 300 chars), and microchip ID.

#### Scenario: Pet under 120 days old
- **WHEN** a tutor enters a pet birth date less than 120 days ago
- **THEN** registration is rejected with an age validation error

#### Scenario: Missing interests
- **WHEN** a tutor submits a pet with no interests selected
- **THEN** registration is rejected

#### Scenario: Missing geolocation
- **WHEN** a tutor submits a pet without a device-derived location
- **THEN** registration is rejected or the location is explicitly requested before submission

#### Scenario: Successful creation persists location
- **WHEN** a pet is created with a valid device location
- **THEN** the pet row stores a PostGIS `location` point and a real `geohash`

### Requirement: Pet photos are validated and moderated

- **Description:** Pet photos SHALL be JPG, PNG, or HEIC, no larger than 1MB, with a minimum resolution of 400x400px and a 1:1 or 4:5 aspect ratio. Main photo MUST be required. Prohibited content (nudity, violence, dead animals) SHALL be rejected, and photos MUST pass automated content moderation before publishing.

#### Scenario: Oversized photo upload
- **WHEN** a user uploads a photo larger than 1MB
- **THEN** the upload is rejected

#### Scenario: Prohibited content detected
- **WHEN** content moderation flags a photo as containing prohibited content
- **THEN** the photo is not published

### Requirement: Owner pet limit depends on subscription plan

- **Description:** A tutor on the free plan SHALL register at most 2 pets; premium tutors SHALL be allowed unlimited pets.

#### Scenario: Free user exceeds pet limit
- **WHEN** a free tutor attempts to add a third pet
- **THEN** the operation is blocked with a plan-limit error

### Requirement: Pet profiles are visible and editable by their owner

- **Description:** A pet's owner SHALL be able to view, update, and delete their own pets, and the pet SHALL be visible to other active users in discovery. Inactive, banned, or soft-deleted pets MUST NOT appear to others.

#### Scenario: Editing own pet
- **WHEN** an owner updates their pet's profile
- **THEN** the changes are saved and reflected in discovery

### Requirement: Pet operations use Result pattern for error handling

- **Description:** All pet operations (create, read, update, delete, toggle active) SHALL return a `Result<Pet, PetFailure>` or `Result<List<Pet>, PetFailure>` instead of throwing exceptions. The `PetFailure` hierarchy SHALL include `ValidationFailure`, `NetworkFailure`, `ServerFailure`, `PermissionFailure`, and `NotFoundFailure`. ViewModels SHALL handle failures declaratively without try/catch.

#### Scenario: Create pet with invalid age returns failure
- **WHEN** a tutor submits a pet with birth date less than 120 days ago
- **THEN** the operation returns `Result.failure(ValidationFailure('Pet deve ter pelo menos 120 dias de vida'))`
- **AND** the ViewModel displays the error message without crashing

#### Scenario: Create pet without location returns failure
- **WHEN** geolocation permission is denied and no location is available
- **THEN** the operation returns `Result.failure(PermissionFailure('Localização necessária para cadastrar pet'))`

### Requirement: Domain entities use PostGIS-native location types

- **Description:** The `Pet` domain entity SHALL use `GeoPoint` (latitude/longitude) and `Geohash` value objects instead of raw `double latitude` and `double longitude` fields. The entity SHALL NOT contain fields that do not exist in the database schema (the database uses `location GEOGRAPHY(POINT,4326)` and `geohash VARCHAR(12)`).

#### Scenario: Pet entity created from DTO
- **WHEN** a `PetDto` from Supabase is converted to a `Pet` entity
- **THEN** the `Pet` entity contains a `GeoPoint` parsed from the PostGIS `location` field
- **AND** the `Pet` entity contains a `Geohash` from the `geohash` field
- **AND** no raw `latitude`/`longitude` doubles exist on the entity

### Requirement: Pet creation encapsulates geolocation capture in a Use Case

- **Description:** The `CreatePetUseCase` SHALL orchestrate the full pet creation flow: validate input (age, interests, required fields), request device geolocation via `GeolocationService`, compute geohash, and delegate persistence to `PetRepository`. The ViewModel SHALL only collect form data and call the Use Case.

#### Scenario: Create pet use case succeeds with real location
- **WHEN** valid form data is submitted and geolocation permission is granted
- **THEN** the Use Case returns `Result.success(pet)` with `location` and `geohash` populated
- **AND** the pet is persisted in Supabase with correct PostGIS columns

#### Scenario: Create pet use case fails on permission denied
- **WHEN** valid form data is submitted but geolocation permission is denied
- **THEN** the Use Case returns `Result.failure(PermissionFailure)` without attempting persistence