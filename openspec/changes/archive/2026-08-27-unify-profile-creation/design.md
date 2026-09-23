## Context

Profile creation today has three competing paths that drift from each other:

1. **`create_user_profile` SQL RPC** — writes a hardcoded geohash (`6gcb1y`) and ignores the real lat/lng; no consent handling.
2. **Direct `users` insert in `AuthRepository._insertUserProfile`** — used as a fallback when the RPC fails; also hardcoded geohash, no location, no consents.
3. **`create-profile` Edge Function index.ts** — already does real geohash (`encodeGeohash`), age/geo validation, inserts the profile, AND writes `consent_logs` (LGPD).

`AuthRepository.signUpWithEmail` currently calls the RPC, then falls back to direct insert; `createProfile` invokes the Edge Function but is used on the onboarding path. Two distinct flows exist depending on the screen, which is exactly the kind of divergence that causes production bugs.

## Goals / Non-Goals

**Goals:**
- A single, well-defined source of truth for creating a user profile.
- Preserve validation (age 18+, geo) and LGPD consent logging.
- Record an architecture convention so future write flows don't reintroduce duplication.

**Non-Goals:**
- Not changing how pets are located (separate change).
- Not refactoring login/session handling.
- Not building other Edge Functions yet.

## Decisions

### Decision: `create-profile` Edge Function is the canonical write path

Chosen option **(a) Edge Function**, per Decision A.

Rationale:
- It is the only path today that computes a **real geohash** and handles **LGPD consent** — both hard requirements.
- An Edge Function can coordinate the insert across `users` + `consent_logs` and, later, side effects (welcome push, audit log) without plpgsql verbosity.
- It already exists and is the most complete of the three.

Alternatives considered and rejected:
- **RPC SQL (`create_user_profile`)** — fast and transactional, but can only do SQL (no consent coordination without huge plpgsql), hardcoded geohash, and `SECURITY DEFINER` misuse risks privilege escalation. Reserved for purely transactional operations (counters/flags).
- **Direct client insert + RLS** — simplest but the orchestration/validation is not enforceable in RLS, and LGPD consent logging can't be guaranteed.

Resulting convention to record: **Edge Functions own facade/server logic that spans validation + side effects; SQL RPC is reserved for pure transactional DB operations.**

### Decision: remove/bypass the duplicate RPC and direct-insert paths

`signUpWithEmail` and `createProfile` will be unified so profile creation always routes through the `create-profile` Edge Function. The `create_user_profile` RPC becomes unused (mark deprecated; optionally drop in a migration). The direct-insert fallback in `_insertUserProfile` is removed.

### Decision: one geohash implementation

Geohash is computed only in the Edge Function (`_shared/geolocation.ts`). The hardcoded `'6gcb1y'` is removed from all path(s).

## Risks / Trade-offs

- **Edge Function adds one network hop** vs RPC (already the case for `createProfile`); acceptable — profile creation is not a high-frequency hot path.
- **Migration ordering**: if `create_user_profile` is dropped, ensure no other caller still uses it (search before dropping).
- **LGPD consent**: the Edge Function must remain the single place consents are written, so removing the RPC path doesn't silently drop consent logging.
- **Error mapping**: rely on the existing `createProfile` status-code check to surface failures consistently.
