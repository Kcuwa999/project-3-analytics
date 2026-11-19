INSERT INTO dds.listings
    (object_type, building_type, rooms, area, price, price_per_sqm,
     district, latitude, longitude, load_ts)
SELECT
    object_type::SMALLINT,
    building_type::SMALLINT,
    rooms::SMALLINT,
    area::NUMERIC(10,2),
    price::NUMERIC(14,0),
    ROUND(price::NUMERIC / NULLIF(area::NUMERIC, 0), 2),
    district,
    latitude::DOUBLE PRECISION,
    longitude::DOUBLE PRECISION,
    NOW()
FROM stg.realty_raw
WHERE price ~ '^[0-9]+(\.[0-9]+)?$'
  AND area  ~ '^[0-9]+(\.[0-9]+)?$'
  AND price::NUMERIC > 100000
  AND area::NUMERIC BETWEEN 5 AND 1000
  AND COALESCE(latitude, '')  ~ '^(5[5-6]|56\.[0-9]*|55\.[0-9]*)'
  AND COALESCE(longitude, '') ~ '^(3[6-8]|37\.[0-9]*|36\.[0-9]*|38\.[0-9]*)'
  AND COALESCE(latitude, '')  ~ '^[0-9.]+$'
  AND COALESCE(longitude, '') ~ '^[0-9.]+$';
