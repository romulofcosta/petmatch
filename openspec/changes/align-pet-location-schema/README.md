# align-pet-location-schema

Align the pet location persistence between the Flutter code and the PostGIS schema: fix createPet (sends nonexistent lat/lng and misses NOT NULL location/geohash), fix nearby_pets (nonexistent age_months column), and remove the hardcoded geohash.
