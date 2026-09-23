## Purpose

Provides private, real-time messaging between matched tutors: text/photo/location/audio/video messages, unread indicators, message moderation (links, phone numbers, profanity, spam), and daily sending limits that differ between free and premium plans.

## Requirements

### Requirement: Chat is only available after a match

- **Description:** Chat SHALL be available only after a confirmed match, and either tutor SHALL be able to start the conversation. A tutor SHALL be able to block the other party at any time, which removes access.

#### Scenario: Unmatched user attempts to chat
- **WHEN** a user tries to open a conversation without a confirmed match
- **THEN** the conversation is not accessible

### Requirement: Message types and daily limits depend on subscription plan

- **Description:** Free users SHALL send up to 50 text messages/day per conversation, 1 photo/day, and 3 location shares/day, and MUST NOT send audio or video. Premium users SHALL have unlimited text/photos and SHALL be able to send audio and video messages. Supported message types are text, photo, location, audio, and video.

#### Scenario: Free user exceeds daily text limit
- **WHEN** a free user sends a 51st text message in a day in one conversation
- **THEN** the message is blocked with a limit error

#### Scenario: Free user attempts voice message
- **WHEN** a free user tries to send an audio message
- **THEN** the message is rejected as premium-only

### Requirement: Messages are delivered in real time

- **Description:** Messages SHALL appear instantly via Supabase Realtime, and the app SHALL support read receipts and send read/message-notification events.

#### Scenario: Real-time delivery
- **WHEN** a matched tutor sends a message
- **THEN** the recipient sees it immediately without a manual refresh

### Requirement: Chat content is moderated

- **Description:** Messages SHALL be moderated: external links blocked, phone numbers blocked until a confirmed match context is established, abusive words flagged by moderation AI, spam limited to a maximum of 10 identical consecutive messages, and a report button SHALL be available on every message.

#### Scenario: Spam detection
- **WHEN** a user sends more than 10 identical messages in a row
- **THEN** further identical messages are blocked

#### Scenario: Link blocking
- **WHEN** a user sends a message containing an external link
- **THEN** the link is blocked or stripped from the message
