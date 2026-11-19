```sql
CREATE TABLE IF NOT EXISTS stg.realty_raw (
    object_type   TEXT,
    region        TEXT,
    building_type TEXT,
    rooms         TEXT,
    area          TEXT,
    price         TEXT,
    latitude      TEXT,
    longitude     TEXT,
    district      TEXT,
    load_ts       TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dds.listings (
    listing_id    BIGSERIAL PRIMARY KEY,
    object_type   SMALLINT,
    building_type SMALLINT,
    rooms         SMALLINT,
    area          NUMERIC(10,2),
    price         NUMERIC(14,0),
    price_per_sqm NUMERIC(12,2),
    district      TEXT,
    latitude      DOUBLE PRECISION,
    longitude     DOUBLE PRECISION,
    load_ts       TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_dds_rooms ON dds.listings (rooms);
CREATE INDEX IF NOT EXISTS idx_dds_building_type ON dds.listings (building_type);