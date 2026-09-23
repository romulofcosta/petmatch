-- PetMatch - Additive migration: re-apply corrected nearby_pets function
-- Data: 2026-08-27
--
-- The `location` (GEOGRAPHY) and `geohash` columns are NOT NULL, so no valid pet
-- row can exist without them; pet creation now enforces geolocation at insert
-- time (see align-pet-location-schema). This migration re-applies the corrected
-- `nearby_pets` function, which previously referenced the nonexistent
-- `pets.age_months` column and therefore failed at runtime. Age is now read from
-- the `pets_with_age` view.

CREATE OR REPLACE FUNCTION nearby_pets(
    p_lat FLOAT,
    p_lng FLOAT,
    p_radius_km FLOAT,
    p_type TEXT DEFAULT NULL,
    p_breed TEXT DEFAULT NULL,
    p_sex TEXT DEFAULT NULL,
    p_interest TEXT DEFAULT NULL,
    p_limit INT DEFAULT 50,
    p_offset INT DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    type VARCHAR,
    breed VARCHAR,
    sex VARCHAR,
    age_months INT,
    main_photo_url TEXT,
    distance_km FLOAT,
    interests TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.type,
        p.breed,
        p.sex,
        p.age_months,
        p.main_photo_url,
        ROUND((ST_Distance(
            p.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
        ) / 1000)::NUMERIC, 2)::FLOAT AS distance_km,
        p.interests
    FROM pets_with_age p
    WHERE p.is_active = true
        AND p.is_banned = false
        AND ST_DWithin(
            p.location,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
            p_radius_km * 1000
        )
        AND (p_type IS NULL OR p.type = p_type)
        AND (p_breed IS NULL OR p.breed = p_breed)
        AND (p_sex IS NULL OR p.sex = p_sex)
        AND (p_interest IS NULL OR p_interest = ANY(p.interests))
    ORDER BY distance_km ASC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
