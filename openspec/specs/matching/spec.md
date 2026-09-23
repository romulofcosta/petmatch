## Purpose

Handles discovery and pairing: the feed of nearby pets, swipe actions (like, pass, super like), reciprocal matching, and post-match actions (unmatch, block). Enforces plan-based daily limits (20 likes / 1 super like free; unlimited premium), self-like prevention, and breeding compatibility rules.

## Requirements

### Requirement: Feed ranks nearby pets by proximity and compatibility

- **Description:** The feed SHALL present pets ordered by priority: same city/region, then compatible interests, then compatible breeds (same size), then complete profiles, then recent tutor activity, and finally pets not recently viewed. Proximity filtering across a configurable radius MUST be backed by PostGIS distance queries.

#### Scenario: Feed near a user
- **WHEN** a tutor opens the feed with a location and radius
- **THEN** active, unbanned pets within the radius are returned ordered by the ranking criteria

### Requirement: Swipe actions are recorded per tutor-pet pair

- **Description:** A tutor SHALL be able to like, super like, or pass a pet. A tutor MUST NOT swipe their own pet, and there SHALL be only one swipe record per (tutor, pet) pair.

#### Scenario: Swiping own pet
- **WHEN** a tutor attempts to swipe their own pet
- **THEN** the action is rejected

#### Scenario: Duplicate swipe
- **WHEN** a tutor swipes the same pet twice
- **THEN** the second swipe is not recorded as a new action

### Requirement: Daily swipe limits depend on subscription plan

- **Description:** Free users SHALL be limited to 20 likes/day and 1 super like/day; premium users SHALL have unlimited likes and super likes. Pass is always unlimited. Quotas SHALL reset at 00:00 local time.

#### Scenario: Free user exceeds daily likes
- **WHEN** a free tutor attempts a 21st like in one day
- **THEN** the like is blocked and a plan-limit message is shown

### Requirement: Match occurs only when both parties like

- **Description:** A match SHALL be created only when both tutors like each other's pets. Matching MUST respect breeding compatibility rules: same-species generally, and for the breeding interest same-species opposite-sex pairs with dog+cat and same-sex pairs not recommended/not allowed.

#### Scenario: Reciprocal like creates a match
- **WHEN** tutor A likes tutor B's pet and tutor B has already liked tutor A's pet
- **THEN** a match is created and both tutors are notified

#### Scenario: Incompatible breeding pair
- **WHEN** a breeding-interest like is made between same-sex or cross-species pets
- **THEN** no match is formed for breeding

### Requirement: Matches can be unmatched and blocked

- **Description:** A tutor SHALL be able to unmatch (removing the match) or block the other user, which SHALL remove any existing match and prevent future matches.

#### Scenario: Blocking a matched user
- **WHEN** a tutor blocks a user they are matched with
- **THEN** the match is removed and no new match can be formed with that user
