## 1. Consolidate profile creation to a single Edge Function path

- [x] 1.1 Search the codebase and DB for every caller of `create_user_profile`, direct `users` insert for profile creation, and `createProfile` / `create-profile` — produce a complete inventory of the three current paths. Inventory: (A) RPC `create_user_profile` defined `001:269`, called from `auth_repository.dart` `_insertUserProfile`; (B) direct `users` insert fallback in `_insertUserProfile` (from `signUpWithEmail` + `_createBasicProfile`); (C) Edge Function `create-profile` (canonical) via `AuthRepository.createProfile` — was dead code (nothing called it; onboarding used `updateProfile`).
- [x] 1.2 In `lib/features/auth/data/repositories/auth_repository.dart`, unify `signUpWithEmail` and the onboarding `createProfile` flow so profile creation always routes through the `create-profile` Edge Function. (`signUpWithEmail` no longer writes a profile; `onboarding_page` now calls `createProfile` with device geolocation + consents.)
- [x] 1.3 Remove the direct `users` insert fallback in `_insertUserProfile`, and stop calling the `create_user_profile` RPC for profile creation. (`_insertUserProfile`, `_createBasicProfile`, `defaultLat/defaultLng`, RPC + direct-insert all removed; `getProfile` returns null instead of auto-inserting.)
- [x] 1.4 Ensure LGPD consent is still written via the Edge Function in all creation flows (verify `consent_logs` is populated). (`onboarding` passes `terms_of_use`/`privacy_policy` consents to `create-profile`, which writes `consent_logs`.)
- [ ] 1.5 Verify: register a user via email, and confirm the profile row exists with a real geohash and consent records, with no RPC/direct-insert call. _(Blocker: no live/local Supabase instance — needs manual E2E.)_

## 2. Mark the old SQL RPC path as deprecated/removed

- [x] 2.1 Add a comment/migration marking `create_user_profile` as deprecated, or drop it in a new migration after confirming no remaining callers. (Migration `003_deprecate_create_user_profile.sql` drops it; no callers remain in app.)
- [x] 2.2 Remove the hardcoded `'6gcb1y'` geohash from any remaining path. (No `lib/` path writes it; the RPC that wrote it is dropped by `003`.)
- [x] 2.3 Verify: `rg` finds no remaining references to `create_user_profile` and no `'6gcb1y'` literal. (Behavior-level: no `rpc()`/insert path remains; the literal survives only in immutable historical migration `001` and the `003` drop migration docs.)

## 3. Record the architectural convention

- [x] 3.1 Update docs (e.g., `docs/development` or architecture) stating: Edge Functions own facade/server logic (validation + side effects); SQL RPC reserved for purely transactional DB operations. (`docs/architecture/03-edge-functions.md` — new "Convencao: Edge Function vs SQL RPC" section.)
- [x] 3.2 Verify: the convention is documented and reflected in the `openspec/config.yaml` context/rules. (config.yaml `design` rule already records the Edge Function vs SQL RPC convention.)

## 4. Tests

- [x] 4.1 Add/update widget/unit tests covering `signUpWithEmail` routing to the Edge Function (mock InvokeFunction) and no RPC/direct insert fallback. (`test/unit/auth_repository_test.dart`: asserts `signUpWithEmail` calls no `.from()`/`.rpc()`, and `createProfile` routes to `create-profile` Edge Function.)
- [x] 4.2 Verify: `flutter analyze` and the relevant test suite pass with no regressions. (8/8 tests pass; analyze has no errors and no new warnings.)
