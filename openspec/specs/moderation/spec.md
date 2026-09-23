## Purpose

Provides community safety and trust: user/pet/message reports with categorized review workflows, post-match star reviews with consequences on the reviewed profile, the level-based ban system (warning, 7-day, 30-day, permanent), moderation of prohibited content, and the controlled breed whitelist.

## Requirements

### Requirement: Users, pets, and messages can be reported

- **Description:** Users SHALL be able to report a user, pet, or message, choosing from categories including animal abuse, animal neglect, fake profile, harassment, scam, spam, inappropriate content, and minor using app. Reports SHALL be reviewed within 24h and the reporter SHALL be notified of the outcome.

#### Scenario: Reporting content
- **WHEN** a user submits a report with a category and optional description
- **THEN** the report is created as pending and queued for review
- **AND** the reporter is notified of the final resolution

### Requirement: Post-match reviews influence profile standing

- **Description:** A reviewer SHALL be able to rate a matched tutor 1-5 stars (with optional tags and a max 300-char comment) once per match, available 24h after the first chat and optional. Average ratings below 2.0 SHALL add an "attention" badge, below 1.5 SHALL trigger manual profile review, and below 1.0 SHALL allow banning.

#### Scenario: Low average rating
- **WHEN** a tutor's average review rating drops below 2.0
- **THEN** their profile is flagged with an "attention" badge

### Requirement: Levels of enforcement apply to violations

- **Description:** Violations SHALL escalate through: warning (first minor), 7-day suspension (second minor or first moderate), 30-day temporary ban (serious), and permanent ban (harassment, animal abuse, crime). Prohibited content (nudity, violence, drugs, hate speech, spam) SHALL be removed and the responsible account sanctioned.

#### Scenario: Permanent ban for animal abuse
- **WHEN** a user is confirmed for animal abuse
- **THEN** their account is permanently banned and authorities are notified

### Requirement: Breed list is controlled by CNPF whitelist

- **Description:** Pets SHALL only be selectable from an official (CNPF) breed list; breeds not on the list MUST NOT be selectable.

#### Scenario: Unlisted breed selection
- **WHEN** a user tries to select a breed not present in the CNPF whitelist
- **THEN** the breed is not available for selection
