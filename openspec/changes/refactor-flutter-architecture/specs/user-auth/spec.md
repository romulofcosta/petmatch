## MODIFIED Requirements

### Requirement: Tutor registration enforces required fields and age

- **Description:** Users SHALL register with display name (2-100 chars), a valid email, and a password of at least 8 characters containing one uppercase letter, one number, and one special character. Registration MUST require the tutor to be 18 years or older. The registration flow SHALL validate age client-side before submission and server-side in the `create-profile` Edge Function.
- **Note:** Phone and profile photo are optional. Geolocation (latitude/longitude) is required for profile creation and SHALL be captured via device geolocation during onboarding.

#### Scenario: Underage user attempts registration
- **WHEN** a user submits a birth date that is less than 18 years before today
- **THEN** registration is rejected and no account is created
- **AND** an age validation error is returned

#### Scenario: Weak password attempted
- **WHEN** a user submits a password missing one required character class
- **THEN** registration is rejected with a password-strength error

#### Scenario: Missing geolocation during onboarding
- **WHEN** a user completes registration but denies geolocation permission
- **THEN** the onboarding flow requests permission again before profile creation
- **AND** profile creation does not proceed without valid coordinates

### Requirement: Multiple sign-in methods are supported

- **Description:** Users SHALL be able to sign in with email and password, or with Google and Apple OAuth. Apple sign-in MUST be offered on iOS. All sign-in methods SHALL resolve to a valid tutor profile via the `create-profile` Edge Function if one does not exist.

#### Scenario: Google sign-in
- **WHEN** a user authenticates via Google
- **THEN** the app signs the user in and creates/fetches their tutor profile

#### Scenario: Apple sign-in on iOS
- **WHEN** a user authenticates via Apple on iOS
- **THEN** the app signs the user in and creates/fetches their tutor profile

### Requirement: Failed sign-in attempts are rate limited

- **Description:** The system SHALL allow a maximum of 5 failed sign-in attempts before temporarily blocking the account for 15 minutes.

#### Scenario: Repeated failed logins
- **WHEN** a user provides incorrect credentials 5 times in a row
- **THEN** sign-in is blocked for 15 minutes
- **AND** the block is lifted automatically afterward

### Requirement: Password recovery uses a time-limited email link

- **Description:** Users SHALL be able to recover their password via an emailed link that is valid for 24 hours and usable only once.

#### Scenario: Password reset link
- **WHEN** a user requests a password reset
- **THEN** a single-use link valid for 24 hours is emailed to them
- **AND** a second use of the same link is rejected

### Requirement: Banned, inactive, or deleted accounts are blocked from access

- **Description:** The app SHALL reject access (redirect to login) for users whose profile is banned, inactive, or soft-deleted.

#### Scenario: Banned user tries to open the app
- **WHEN** a signed-in user's profile is flagged as banned
- **THEN** they are redirected to the login screen

### Requirement: Account deletion is permanent and removes personal data

- **Description:** Users SHALL be able to delete their account, permanently losing all personal data. Deletion SHALL soft-delete the row (set deleted_at) and then anonymize personal fields per LGPD (name, email, phone, photo, location), keeping anonymized data for audit.

#### Scenario: User deletes account
- **WHEN** a user confirms account deletion
- **THEN** their personal data is anonymized and the account is excluded from the app
- **AND** anonymized records are retained for audit/legal retention

### Requirement: Tutor profile creation flows through a single Edge Function path

- **Description:** User profile creation SHALL be performed exclusively through the `create-profile` Edge Function, which is responsible for validating age (18+) and geo, computing the real geohash, inserting the profile row, and recording consent. The app MUST NOT create profiles via a direct table insert or the `create_user_profile` SQL RPC. SQL RPCs SHALL be reserved for purely transactional database operations and MUST NOT be used for profile creation.

#### Scenario: Profile created through Edge Function
- **WHEN** a new tutor registers and a profile is created
- **THEN** the `create-profile` Edge Function performs validation, computes the real geohash, inserts the profile, and records consent
- **AND** no direct table insert or `create_user_profile` RPC is used

#### Scenario: Direct insert attempted
- **WHEN** a profile creation would bypass the Edge Function (e.g., legacy direct `users` insert)
- **THEN** it is not part of the accepted creation flow and is rejected or removed

### Requirement: Profile location uses real computed geohash

- **Description:** When a profile is created, its `geohash` SHALL be computed from the supplied latitude/longitude by the Edge Function. Hardcoded placeholder geohashes (e.g., `6gcb1y`) SHALL NOT be written as the profile's location.

#### Scenario: Real geohash stored
- **WHEN** a profile is created with a latitude/longitude
- **THEN** the stored `geohash` matches a real encoding of those coordinates

### Requirement: Auth operations use Result pattern for error handling

- **Description:** All authentication operations (sign in, sign up, profile creation, password reset) SHALL return a `Result<User, AuthFailure>` instead of throwing exceptions. The `AuthFailure` hierarchy SHALL include `ValidationFailure`, `NetworkFailure`, `ServerFailure`, `RateLimitedFailure`, and `UnauthorizedFailure`. ViewModels SHALL handle failures declaratively without try/catch.

#### Scenario: Sign in with invalid credentials returns failure
- **WHEN** a user provides incorrect email/password
- **THEN** the operation returns `Result.failure(UnauthorizedFailure('Email ou senha incorretos'))`
- **AND** the ViewModel displays the error message without crashing

#### Scenario: Network error returns failure
- **WHEN** the device has no internet connectivity
- **THEN** the operation returns `Result.failure(NetworkFailure('Erro de conexão. Verifique sua internet'))`

### Requirement: Domain entities use PostGIS-native location types

- **Description:** The `User` domain entity SHALL use `GeoPoint` (latitude/longitude) and `Geohash` value objects instead of raw `double latitude` and `double longitude` fields. The entity SHALL NOT contain fields that do not exist in the database schema (the database uses `location GEOGRAPHY(POINT,4326)` and `geohash VARCHAR(12)`).

#### Scenario: User entity created from DTO
- **WHEN** a `UserDto` from Supabase is converted to a `User` entity
- **THEN** the `User` entity contains a `GeoPoint` parsed from the PostGIS `location` field
- **AND** the `User` entity contains a `Geohash` from the `geohash` field
- **AND** no raw `latitude`/`longitude` doubles exist on the entity