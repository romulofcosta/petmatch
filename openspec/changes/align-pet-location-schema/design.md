## Context

Pet location persistence is inconsistent between the Flutter code and the PostGIS schema:

- The `pets` table has `location GEOGRAPHY(POINT,4326) NOT NULL` and `geohash VARCHAR(12) NOT NULL`.
- `PetRepository.createPet` builds an insert map with `latitude`/`longitude` keys (nonexistent columns) and omits `location`/`geohash` → the insert always errors.
- No geolocation code exists anywhere in `lib/` despite `geolocator`/`geocoding` being declared in `pubspec.yaml`.
- The `nearby_pets` SQL function selects `p.age_months`, which only exists on the `pets_with_age` view, not the base `pets` table → the function fails.
- The RPC `create_user_profile` writes a hardcoded geohash (`6gcb1y`).

## Goals / Non-Goals

**Goals:**
- Make pet creation succeed and persist native PostGIS location + real geohash.
- Make `nearby_pets` discovery function execute correctly (accurate age, real distance).
- Wire device geolocation into pet creation.
- Remove the hardcoded geohash.

**Non-Goals:**
- Not building the feed UI or swipe/match flows.
- Not changing the schema's storage model (PostGIS is retained — that is the decision).
- Not covering pricing or other Edge Functions.

## Decisions

### Decision: keep PostGIS-native storage (Decision B-a)

Persist `location` GEOGRAPHY point + `geohash`, not numeric `lat`/`lng`. PostGIS proximity (`ST_DWithin`, `ST_Distance`) is the core of discovery, and the geohash enables fast coarse filtering. The Flutter code is corrected to write these columns, not the schema changed to numeric.

### Decision: Flutter computes the point and geohash before insert

The client obtains the tutor's current position via `geolocator`, encodes the geohash (shared helper equivalent to `_shared/geolocation.ts`), and sends `location` as a WKT point string plus `geohash` in the insert map. `PetRepository.createPet` no longer sends `latitude`/`longitude`.

Implementation sketch (data-plane concern, lives in the pets repository/provider):
- Acquire `Position` from `geolocator` (request permission after pet form).
- Build `location: "POINT(lng lat)"` and compute `geohash`.
- Insert with the correct keys.

### Decision: `nearby_pets` derives age from `pets_with_age`

Fix the function to SELECT from the `pets_with_age` view (which computes `age_months`) or join it, so `age_months` resolves correctly, instead of referencing the nonexistent `pets.age_months` column. Verify PostGIS `ST_DWithin`/`ST_Distance` still operate on `p.location`.

### Decision: geohash is never hardcoded

The hardcoded `'6gcb1y'` is removed from the profile RPC (handled by unify-profile-creation) and any pet path. Real geohashes are computed everywhere.

## Risks / Trade-offs

- **Geolocation permission friction**: location is optional per business rules (feed degrades gracefully); pet creation should handle permission-denied by prompting rather than silently failing.
- **WKT formatting**: the `location` string must be valid WKT (`POINT(lng lat)` — note lng before lat); a malformed string errors the insert.
- **Migration**: an additive migration may be needed if existing pet rows lack `location`/`geohash`; the decision is to backfill or enforce at insert going forward.
- **Testing**: `nearby_pets` should be smoke-tested against seeded PostGIS data (supabase/seed).
