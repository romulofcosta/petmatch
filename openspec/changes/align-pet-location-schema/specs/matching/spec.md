## MODIFIED Requirements

### Requirement: Feed ranks nearby pets by proximity and compatibility

- **Description:** The feed SHALL present active, unbanned pets ordered by priority: same city/region, then compatible interests, then compatible breeds (same size), then complete profiles, then recent tutor activity, and finally pets not recently viewed. Proximity SHALL be computed with PostGIS distance queries over the pet's native `location` point, and the query MUST return each pet's computed age correctly (from birth date) rather than referencing a nonexistent column.

#### Scenario: Feed near a user
- **WHEN** a tutor opens the feed within a search radius
- **THEN** active, unbanned pets within the radius are returned with an accurate computed age and distance

#### Scenario: Proximity function executes without error
- **WHEN** the `nearby_pets` discovery function is invoked
- **THEN** it executes successfully using the pet's `location` and correct age derivation
- **AND** it does not reference the nonexistent `pets.age_months` column
