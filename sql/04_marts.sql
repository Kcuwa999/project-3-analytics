CREATE TABLE IF NOT EXISTS cdm.rooms_metrics AS
SELECT
    rooms,
    COUNT(*)                                                    AS listings_cnt,
    ROUND(AVG(area), 1)                                         AS avg_area,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price_per_sqm), 0) AS p25_price_sqm,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY price_per_sqm), 0) AS median_price_sqm,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price_per_sqm), 0) AS p75_price_sqm,
    ROUND(AVG(price_per_sqm), 0)                                AS avg_price_sqm
FROM dds.listings
WHERE rooms IN (-1, 1, 2, 3) AND area IS NOT NULL AND price_per_sqm IS NOT NULL
GROUP BY rooms;

CREATE TABLE IF NOT EXISTS cdm.price_segments AS
WITH segmented AS (
    SELECT
        rooms,
        price,
        price_per_sqm,
        NTILE(4) OVER (PARTITION BY rooms ORDER BY price_per_sqm) AS price_quartile
    FROM dds.listings
    WHERE rooms IN (-1, 1, 2, 3) AND price_per_sqm IS NOT NULL
)
SELECT
    rooms,
    price_quartile,
    COUNT(*)                              AS listings_cnt,
    ROUND(AVG(price_per_sqm), 0)          AS avg_price_sqm,
    ROUND(AVG(price), 0)                  AS avg_price,
    ROUND(AVG(price_per_sqm) / SUM(AVG(price_per_sqm)) OVER (), 3) AS quartile_share_of_market
FROM segmented
GROUP BY rooms, price_quartile;

CREATE TABLE IF NOT EXISTS cdm.building_type_metrics AS
WITH market_avg AS (
    SELECT ROUND(AVG(price_per_sqm), 0) AS market_avg_pps
    FROM dds.listings
    WHERE building_type IN (2, 3, 4) AND price_per_sqm IS NOT NULL
)
SELECT
    l.building_type,
    COUNT(*)                                                    AS listings_cnt,
    ROUND(AVG(l.price_per_sqm), 0)                              AS avg_price_sqm,
    ROUND(100.0 * AVG(l.price_per_sqm) / m.market_avg_pps - 100, 1) AS pct_vs_market
FROM dds.listings l
CROSS JOIN market_avg m
WHERE l.building_type IN (2, 3, 4) AND l.price_per_sqm IS NOT NULL
GROUP BY l.building_type, m.market_avg_pps;

CREATE TABLE IF NOT EXISTS cdm.district_share AS
SELECT
    district,
    COUNT(*)                                                    AS listings_cnt,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)          AS market_share_pct,
    ROUND(AVG(price_per_sqm), 0)                                AS avg_price_sqm,
    RANK() OVER (ORDER BY AVG(price_per_sqm) DESC)              AS price_rank
FROM dds.listings
WHERE district IS NOT NULL AND district <> '' AND price_per_sqm IS NOT NULL
GROUP BY district;

CREATE TABLE IF NOT EXISTS cdm.price_extremes AS
WITH ranked AS (
    SELECT
        rooms, price, area, price_per_sqm, district,
        ROW_NUMBER() OVER (PARTITION BY rooms ORDER BY price_per_sqm DESC) AS rnk_desc,
        ROW_NUMBER() OVER (PARTITION BY rooms ORDER BY price_per_sqm ASC)  AS rnk_asc
    FROM dds.listings
    WHERE rooms IN (-1, 1, 2, 3) AND price_per_sqm IS NOT NULL
)
SELECT rooms, price, area, price_per_sqm, district,
       CASE WHEN rnk_asc = 1 THEN 'cheapest' END AS extreme_type
FROM ranked WHERE rnk_asc = 1
UNION ALL
SELECT rooms, price, area, price_per_sqm, district,
       CASE WHEN rnk_desc = 1 THEN 'most_expensive' END AS extreme_type
FROM ranked WHERE rnk_desc = 1;
