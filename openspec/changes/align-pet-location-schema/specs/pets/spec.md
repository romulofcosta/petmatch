## MODIFIED Requirements

### Requirement: Pet registration captures required fields, location, and validates them

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
