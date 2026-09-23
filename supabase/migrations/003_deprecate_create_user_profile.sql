-- PetMatch - Deprecate create_user_profile SQL RPC
-- Data: 2026-08-27
--
-- Profile creation is now the sole responsibility of the `create-profile` Edge
-- Function (see change "unify-profile-creation"): it validates age/geo,
-- computes the real geohash, inserts the `users` row and records LGPD
-- `consent_logs`. The Flutter app no longer invokes this RPC (no callers
-- remain), so it is dropped. This also removes the hardcoded placeholder
-- geohash `6gcb1y` that it wrote.

DROP FUNCTION IF EXISTS create_user_profile(
    p_uid UUID,
    p_display_name TEXT,
    p_birth_date DATE,
    p_lng FLOAT,
    p_lat FLOAT
);
