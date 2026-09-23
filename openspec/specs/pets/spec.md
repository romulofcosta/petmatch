## Purpose

Manages pet profiles owned by tutors: CRUD of pets, photo handling with moderation, breed/, birth-date (>=120 days) and interests validation, and plan-based limits on how many pets an owner can register (2 free / unlimited premium).

## Requirements

### Requirement: Pet registration captures required fields and validates them

- **Description:** Pet registration SHALL collect the pet's name (2-30 letters/spaces), type (dog|cat), sex (male|female), breed (from the controlled list), birth date, a main photo, and at least one interest (socialization|breeding|adoption). The birth date MUST be at least 120 days old per Lei 17.972/24 and at most 20 years.
- **Note:** Optional fields include up to 6 additional photos, weight (0.5-80kg), description (max 500 chars), up to 5 personality tags, neutered/vaccines/pedigree flags, veterinarian info, health notes (max 300 chars), and microchip ID.

#### Scenario: Pet under 120 days old
- **WHEN** a tutor enters a pet birth date less than 120 days ago
- **THEN** registration is rejected with an age validation error

#### Scenario: Missing interests
- **WHEN** a tutor submits a pet with no interests selected
- **THEN** registration is rejected

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
