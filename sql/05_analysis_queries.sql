SELECT rooms, median_price_sqm, p25_price_sqm, p75_price_sqm
FROM cdm.rooms_metrics ORDER BY rooms;

SELECT rooms, price_quartile, avg_price_sqm, listings_cnt
FROM cdm.price_segments ORDER BY rooms, price_quartile;

SELECT building_type, avg_price_sqm, pct_vs_market
FROM cdm.building_type_metrics ORDER BY pct_vs_market DESC;

SELECT district, market_share_pct, avg_price_sqm, price_rank
FROM cdm.district_share ORDER BY market_share_pct DESC LIMIT 15;

SELECT width_bucket(price_per_sqm, 50000, 1000000, 19) AS price_bucket,
       COUNT(*) AS listings_cnt
FROM dds.listings
WHERE price_per_sqm BETWEEN 50000 AND 1000000
GROUP BY 1 ORDER BY 1;
