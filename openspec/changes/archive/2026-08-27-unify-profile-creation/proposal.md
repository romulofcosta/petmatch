## Why

Profile creation currently flows through **three conflicting paths**: the `create_user_profile` SQL RPC, a direct table insert in Flutter, and the `create-profile` Edge Function — each with subtle differences (e.g., the RPC writes a hardcoded geohash, the direct insert omits location). This divergence is a root cause of bugs and will compound as more write flows are added. We need a single, well-defined source of truth for user profile creation before building further.

## What Changes

- **Establish the `create-profile` Edge Function as the single source of truth** for creating a user profile. It already owns validation (age 18+, geo), real geohash computation, consent logging, and profile insertion.
- **Remove/bypass the `create_user_profile` SQL RPC** as a write path for Flutter (the app currently tries RPC first, then falls back to direct insert).
- **Remove the direct `users` insert fallback in `AuthRepository`**; route all profile creation through the Edge Function.
- **Reserve SQL RPCs for purely transactional operations** (counters, flags) going forward — recorded as an architectural convention.
- **Non-goals:** this change does *not* touch pet location (handled in a separate change), pricing, or build edge functions for other flows.

## Capabilities

### New Capabilities
_None — no new capability is introduced._

### Modified Capabilities
- `user-auth`: specify a single creation path for tutor profiles (Edge Function) and remove the multiple-path (RPC/direct-insert) behavior from the accepted flows.

## Impact

- **Flutter:** `lib/features/auth/data/repositories/auth_repository.dart` — simplify `signUpWithEmail` and remove `_insertUserProfile` / RPC / direct-insert fallback; funnel through `createProfile`.
- **Supabase:** `migrations/001_initial_schema.sql` — `create_user_profile` RPC becomes unused (optionally dropped or documented as deprecated); the Edge Function `supabase/functions/create-profile/index.ts` becomes canonical.
- **Docs:** reflects that Edge Functions own facade/server logic while SQL RPC is reserved for transactional DB operations.
- **Behavior:** one consistent creation path, fixing the hardcoded-geohash and incomplete-location divergence.
