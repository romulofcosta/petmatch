## Purpose

Ensures Brazilian LGPD (Lei 13.709/2018) compliance for personal data handling: consent capture and logging, data subject rights (access, correction, portability, deletion, revocation), retention periods, deletion/export flows, and auditing. Pet (animal) data is generally out of LGPD scope; tutor personal data is in scope.

## Requirements

### Requirement: Consent is captured and logged per treatment

- **Description:** The app SHALL collect and log explicit consent for each data processing (terms of use, privacy policy, location, push notifications), recording user id, consent type, granted flag, IP, user-agent, version, and timestamp. Consent for location and push MUST be active opt-in.

#### Scenario: First-run consent
- **WHEN** a tutor first opens the app and accepts terms/privacy
- **THEN** consent is recorded in the consent log with version and timestamp
- **AND** additional opt-ins for location and push are requested and recorded separately

### Requirement: Data subject rights are implementable by the user

- **Description:** The app SHALL let the tutor access their data ("My Data"), correct it, and revoke consent from settings. The user SHALL be able to export their data in a portable format (JSON/CSV) and delete their account, with personal data anonymized and audit/legal records retained per retention policy.

#### Scenario: Data export request
- **WHEN** a user requests a data export
- **THEN** a portable JSON/CSV export of their personal data is provided

#### Scenario: Consent revocation
- **WHEN** a user revokes consent in settings
- **THEN** the revocation is logged and the associated processing stops

### Requirement: Retention periods are enforced

- **Description:** The system SHALL retain: account data while active; payment data and audit logs for 5 years; consent logs while active plus 5 years; messages for 1 year after account deletion; photos while active. Anonymized data MAY be kept for audit and aggregate metrics.

#### Scenario: Audit log retention
- **WHEN** a user account is deleted
- **THEN** anonymized audit records are retained for the required 5-year period

### Requirement: Deletion anonymizes personal data per policy

- **Description:** On account deletion the system SHALL soft-delete the account, replace the name with a placeholder, hash the email, and remove phone, photo, and exact location, while keeping anonymized records.

#### Scenario: Account deletion anonymization
- **WHEN** a user's account is deleted
- **THEN** their personal fields are replaced/anonymized and the account is excluded from the app

### Requirement: Administrative LGPD obligations are tracked

- **Description:** The project SHALL maintain a designated DPO, a privacy impact report (RIPD) before launch, a 72h incident-notification channel to ANPD, and operation logs. These are organizational requirements recorded as documentation deliverables.

#### Scenario: Incident notification procedure
- **WHEN** a personal-data incident occurs
- **THEN** there is a defined procedure to notify ANPD within 72 hours
