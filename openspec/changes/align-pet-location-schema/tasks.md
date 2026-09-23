## 1. Fix `nearby_pets` SQL function

- [x] 1.1 In `supabase/migrations/001_initial_schema.sql`, fix the `nearby_pets` function to derive `age_months` from the `pets_with_age` view (or join it) instead of referencing the nonexistent `pets.age_months` column. (`FROM pets_with_age p`, verified columns exist.)
- [ ] 1.2 Verify: run `nearby_pets(lat, lng, radius)` against seeded PostGIS data and confirm it returns rows with correct `age_months` and `distance_km`, and no column-not-found error. _(Blocker: no local Postgres/Supabase instance confirmed — needs manual `supabase start` + query.)_

## 2. Wire device geolocation into pet creation

- [x] 2.1 In `lib/features/pets/data/repositories/pet_repository.dart`, change `createPet` to persist `location` (WKT `POINT(lng lat)`) and `geohash`, and remove the invalid `latitude`/`longitude` insert keys.
- [x] 2.2 Use `geolocator` (already in pubspec) in the pet creation flow (provider/page) to obtain the current position, request permission, and pass the computed point + geohash. (`GeolocationService` + `add_pet_page._submit`)
- [x] 2.3 Update `PetModel.toInsertMap` to accept and emit location/geohash.
- [x] 2.4 Handle permission-denied gracefully (prompt, allow retry, don't silently fail). (SnackBar in `_submit`, `LocationResult.denied`)
- [ ] 2.5 Verify: create a pet with a real location and confirm the row persists `location` (geography) and a real `geohash`, without runtime error. _(Blocker: needs device/live DB — covered statically via unit test 5.1.)_

## 3. Backfill / normalize existing pet rows

- [x] 3.1 Add an additive migration to backfill `location`/`geohash` for existing pet rows (or enforce at insert if no live data). Columns are NOT NULL (no backfill-able rows) and inserts now enforce geolocation; migration `002` re-applies the corrected `nearby_pets` additively.
- [ ] 3.2 Verify: migration applies cleanly against the current schema. _(Blocker: no live DB — additive form safe since it only `CREATE OR REPLACE FUNCTION`.)_

## 4. Remove hardcoded geohash

- [x] 4.1 Ensure no code/function writes the literal geohash `'6gcb1y'` for pets or profiles. Pet path clean (removed when fixing `createPet`); the remaining literals are the **profile** RPC + `AuthRepository._insertUserProfile`, explicitly owned by `unify-profile-creation`.
- [ ] 4.2 Verify: `rg` finds no `'6gcb1y'` across the repo. _(Pending: profile literals remain until `unify-profile-creation` is applied.)_

## 5. Tests

- [x] 5.1 Add unit tests for `createPet` asserting the insert payload contains `location` and `geohash` and no `latitude`/`longitude` keys. (`test/unit/pet_repository_test.dart` via `PetModel.toInsertMap` + `encodeGeohash`)
- [ ] 5.2 Add a smoke test for the `nearby_pets` function on seeded PostGIS data. _(Blocker: no seeded/local DB available.)_
- [x] 5.3 Verify: `flutter analyze` and the test suite pass with no regressions. (Ran via Windows `flutter`: 6/6 tests pass; analyze has no compile errors — only pre-existing info/warning lints. Fixed stale `widget_test.dart` referencing nonexistent `MyApp`.)
