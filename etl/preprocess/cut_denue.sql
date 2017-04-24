--------------------------------------------
-- CROP Carreteras to use only metropolitan area
---------------------------------------------
-- Transform it to Mexican Datum of 1993 / UTM zone 13N EPSG:4486

DROP TABLE IF EXISTS preprocess.denue;

CREATE TABLE preprocess.denue AS (
	WITH denue_tr AS (
		SELECT *, st_transform(geom, 4326) as geom_tr
		FROM raw.denue)
	SELECT id,
	       per_ocu,
	       to_date((regexp_matches(fecha_alta, '([[A-Za-z]+) ([0-9]+)'))[2], 'YYYY') AS year_alta,
	       st_transform(d.geom_tr, 4486) as geom
	FROM denue_tr as d
	JOIN preprocess.metropolitan_area AS metro
	ON st_within(d.geom_tr, metro.geom)
);

CREATE INDEX ON preprocess.denue (year_alta);
	
