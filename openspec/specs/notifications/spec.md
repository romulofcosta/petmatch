## Purpose

Delivers event notifications to tutors across push, in-app, and email channels: new match, new message, super like received, 10-likes milestone, app news, and premium renewal. Enforces per-channel frequency caps and per-user opt-in preference controls, routed through Firebase Cloud Messaging and a notifications Edge Function.

## Requirements

### Requirement: Event types map to notification channels

- **Description:** The system SHALL generate notifications for: new match (push + in-app), new message (push + in-app), super like received (push + in-app + email), 10 likes received (push + in-app), app news (in-app + email), and premium renewal (in-app + email).

#### Scenario: New match notification
- **WHEN** a reciprocal match is created
- **THEN** both tutors receive a push and an in-app notification

#### Scenario: Super like notification
- **WHEN** a tutor super-likes another tutor's pet
- **THEN** the target tutor receives a push, in-app, and email notification

### Requirement: Notification frequency is capped per channel

- **Description:** Push notifications SHALL be limited to a maximum of 5 per day per user, and email SHALL be limited to a maximum of 2 per week per user.

#### Scenario: Push cap reached
- **WHEN** a user would receive a 6th push notification in a day
- **THEN** the push is suppressed (the event may still show in-app)

### Requirement: Notification preferences are user controlled

- **Description:** Users SHALL be able to enable/disable notifications by category (new matches, messages, likes, marketing). Marketing notifications SHALL be off by default; new matches, messages, and likes SHALL default to on.

#### Scenario: Disabling message notifications
- **WHEN** a user turns off message notifications in settings
- **THEN** no push or in-app notifications for new messages are delivered to them
