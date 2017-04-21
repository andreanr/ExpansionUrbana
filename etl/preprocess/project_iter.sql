
--### 2000 ####

DROP TABLE IF EXISTS preprocess.iter_2000;
CREATE TABLE preprocess.iter_2000 AS
WITH t_decimal AS (
	SELECT entidad || mun || loc as cve_loc,
	       -(substring(longitud::text, 1,3)::int +
	       substring(longitud::text, 4,2)::float/60 +
	       substring(longitud::text, 6, 2)::float/3600) as longitud_decimal,
               substring(latitud::text, 1,2)::int +
	       substring(latitud::text, 3,2)::float/60 +
	       substring(latitud::text, 5,2)::float/3600 as latitud_decimal,
	       *
	FROM raw.iter_2000
	WHERE latitud is not null and longitud is not null
	AND pobtot < 2500),
    t_transform AS (
 	SELECT   *,
       		ST_Transform(ST_SetSRID(ST_Point(longitud_decimal, latitud_decimal), 4326), 4486) as geom
 	FROM t_decimal)
SELECT iter.* 
FROM t_transform as iter
JOIN preprocess.metropolitan_area AS metro
ON st_within(iter.geom, st_transform(metro.geom, 4486)) ;

CREATE INDEX ON preprocess.iter_2000 USING GIST (geom);

--### 2005 ####

DROP TABLE IF EXISTS preprocess.iter_2005;
CREATE TABLE preprocess.iter_2005 AS
WITH t_decimal AS (
	SELECT entidad || mun || loc as cve_loc,
	       -(substring(longitud::text, 1,3)::int +
	       substring(longitud::text, 4,2)::float/60 +
	       substring(longitud::text, 6, 2)::float/3600) as longitud_decimal,
               substring(latitud::text, 1,2)::int +
	       substring(latitud::text, 3,2)::float/60 +
	       substring(latitud::text, 5,2)::float/3600 as latitud_decimal,
	       *
	FROM raw.iter_2005
	WHERE latitud is not null and longitud is not null
	AND p_total < 2500),
     t_transform AS (
	 SELECT *, 
	        ST_Transform(ST_SetSRID(ST_Point(longitud_decimal, latitud_decimal), 4326), 4486) as geom
	 FROM t_decimal)
SELECT iter.*
FROM t_transform as iter
JOIN preprocess.metropolitan_area AS metro
ON st_within(iter.geom, st_transform(metro.geom, 4486));

CREATE INDEX ON preprocess.iter_2010 USING GIST (geom);

--### 2010 ####

DROP TABLE IF EXISTS preprocess.iter_2010;
CREATE TABLE preprocess.iter_2010 AS
WITH t_decimal AS (
	SELECT entidad || mun || loc as cve_loc,
	       -(substring(longitud::text, 1,3)::int +
	       substring(longitud::text, 4,2)::float/60 +
	       substring(longitud::text, 6, 2)::float/3600) as longitud_decimal,
               substring(latitud::text, 1,2)::int +
	       substring(latitud::text, 3,2)::float/60 +
	       substring(latitud::text, 5,2)::float/3600 as latitud_decimal,
	       *
	FROM raw.iter_2010
	WHERE latitud is not null and longitud is not null
	AND pobtot < 2500),
     t_transform AS (
 	SELECT *, 
	       ST_Transform(ST_SetSRID(ST_Point(longitud_decimal, latitud_decimal), 4326), 4486) as geom
 	FROM t_decimal)
SELECT iter.*
FROM t_transform as iter
JOIN preprocess.metropolitan_area AS metro
ON st_within(iter.geom, st_transform(metro.geom, 4486));

CREATE INDEX ON preprocess.iter_2010 USING GIST (geom);


