## ADDED Requirements

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
