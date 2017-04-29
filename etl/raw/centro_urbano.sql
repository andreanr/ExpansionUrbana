
-- Make point
DROP TABLE IF EXISTS raw.centro_urbano;
CREATE TABLE raw.centro_urbano as (
	SELECT ST_SetSRID(ST_MakePoint(-106.0754889,28.6391952), 4326) as geom
);
