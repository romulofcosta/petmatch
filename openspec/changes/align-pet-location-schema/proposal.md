## Why

The pet module's schema and Flutter code have **diverged**, breaking the core write/read path:

- `PetRepository.createPet` sends `latitude`/`longitude` columns that **do not exist** on the `pets` table (which has `location GEOGRAPHY NOT NULL` + `geohash NOT NULL`), and fails to populate either NOT NULL field → **every pet creation errors at runtime**.
- The `nearby_pets` SQL function references `p.age_months`, a column that only exists on the `pets_with_age` view, not on `pets` → **proximity discovery always fails**.
- `users` profile creation wrote a **hardcoded geohash** in the RPC path.

We are choosing to keep **PostGIS-native** storage (`location` GEOGRAPHY + `geohash`) as the source of truth for pet location, and fixing the code to match the schema (not the reverse).

## What Changes

- **Fix `PetRepository.createPet`** to persist `location` (a PostGIS point) and `geohash` (precomputed on the client via geolocator), removing the invalid `latitude`/`longitude` insert keys.
- **Fix the `nearby_pets` SQL function** so age is derived correctly (join `pets_with_age` or compute inline) instead of referencing a nonexistent `pets.age_months` column.
- **Introduce real geolocation access** in Flutter (geolocator) for pet creation, since no location code exists today despite the dependency being declared.
- **Remove the hardcoded geohash** from any remaining profile/pet creation path, computing real geohashes.
- **Non-goals:** this change does not cover the feed UI, swipe/match logic, or pricing. It fixes the data foundation only.

## Capabilities

### New Capabilities
_None._

### Modified Capabilities
- `pets`: require pet creation to persist native PostGIS location and geohash (obtained from device geolocation), and correct the required pet data contract that both the client insert and the `nearby_pets` discovery function rely on.

## Impact

- **Flutter:** `lib/features/pets/data/repositories/pet_repository.dart` (createPet), `lib/features/pets/presentation/providers/pets_provider.dart` and `add_pet_page.dart` (geolocation capture via `geolocator`), plus `pet_model.dart` (`toInsertMap`).
- **Supabase:** `supabase/migrations/001_initial_schema.sql` — correct the `nearby_pets` function; add a migration to fix/derive location data if needed.
- **Behavior:** pet creation succeeds and populates `location`/`geohash`; proximity discovery works.
