## Purpose

Manages the freemium model: premium subscription plans (monthly/yearly), Stripe-backed checkout, automatic renewal with webhooks, cancellation, refunds, and per-plan feature entitlement (unlimited likes/super likes, advanced filters, larger search radius, unlimited pets and chat types). Also handles paid à la carte items (super likes, boost, 7-day highlight) and NFS-e invoice emission.

## Requirements

### Requirement: Premium subscription is purchased via Stripe checkout

- **Description:** A user SHALL be able to subscribe to a monthly or yearly premium plan through Stripe Checkout. On `checkout.session.completed`, an Edge Function SHALL create the subscription record and update `users.subscription` to `premium_<plan>` with an expiry date.

#### Scenario: Successful checkout
- **WHEN** a user completes a paid checkout session
- **THEN** a subscription is created, the user's subscription state is upgraded, and a confirmation push is sent

### Requirement: Subscription renews automatically via webhook

- **Description:** On `invoice.paid` the subscription SHALL renew and extend its expiry. On `invoice.payment_failed` the subscription SHALL be marked `past_due`, the user notified, and Stripe MUST retry up to 3 times over 7 days before cancellation.

#### Scenario: Payment failure
- **WHEN** a recurring payment fails
- **THEN** the subscription is marked past_due and the user is notified of the failed payment
- **AND** the system retries up to 3 times over 7 days

### Requirement: Plan feature entitlements differ between free and premium

- **Description:** Premium SHALL entitle the user to unlimited pets, unlimited likes and super likes, advanced filters (exact breed, neutered-only, pedigree-only), "see who liked you", audio/video messages, search radius up to 100km (vs 30km free), no ads, and a monthly boost. Precision of the configured search radius MUST be reflected in discovery queries.

#### Scenario: Premium advanced filter
- **WHEN** a premium user applies a pedigree-only filter
- **THEN** only pedigree pets matching the filter are shown

#### Scenario: Free search radius cap
- **WHEN** a free user searches beyond 30km
- **THEN** results are capped/reset to the 30km free radius

### Requirement: Subscriptions can be cancelled and refunded

- **Description:** A user SHALL be able to cancel their subscription, keeping premium benefits until the paid period ends, after which the account returns to free. Refunds SHALL be processed by admin and recorded in the audit log.

#### Scenario: Cancel subscription
- **WHEN** a user cancels a paid subscription
- **THEN** premium access continues until the period end
- **AND** the account then reverts to the free plan

### Requirement: Paid à la carte items are supported

- **Description:** The system SHALL support one-time purchases of super likes (R$4.90), a 24h boost (R$9.90), and a 7-day highlight (R$14.90), granting the corresponding temporary benefits.

#### Scenario: Purchasing a boost
- **WHEN** a user buys a 24h boost
- **THEN** their pets are boosted in the feed for 24 hours

### Requirement: NFS-e invoices are emitted for subscriptions

- **Description:** After each confirmed payment, an Edge Function SHALL emit an NFS-e via the NFe.io/Tiny ERP API, store the generated PDF in Supabase Storage, email the link to the user, and record the emission in the audit log.

#### Scenario: Invoice emission after payment
- **WHEN** a subscription payment is confirmed
- **THEN** an NFS-e is generated, stored, and its link emailed to the user
