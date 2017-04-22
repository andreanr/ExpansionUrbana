--------------------------------------------
-- CROP Carreteras to use only metropolitan area
---------------------------------------------
-- Transform it to Mexican Datum of 1993 / UTM zone 13N EPSG:4486

DROP TABLE IF EXISTS preprocess.carreteras;

CREATE TABLE preprocess.carreteras AS (
	WITH transform_carreteras as (
		SELECT *, st_transform(geom, 4326) as geom_tr
		FROM raw.carreteras)
	SELECT gid,
	       CASE WHEN tipovia = 'CARRETERA' THEN 1 ELSE 0 END as carretera,
	       CASE WHEN tipovia = 'CALLE' THEN 1 ELSE 0 END as calle,
	       CASE WHEN tipovia = 'AVENIDA' THEN 1 ELSE 0 END as avenida,
	       tipovia as tipo_via,
	       tipo as tipo,
	       dere_tran as derecho_transito,
	       administra as administracion,
	       nume_carr as numero_carriles,
	       condicion,
	       st_transform(c.geom_tr, 4486) as geom
	FROM transform_carreteras as c
	JOIN preprocess.metropolitan_area AS metro
	ON st_within(c.geom_tr, metro.geom)
);

--------------------------------------------------
-- CROP aeropuertos to use only metropolitan area
---------------------------------------------------
 -- Transform it to Mexican Datum of 1993 / UTM zone 13N EPSG:4486

DROP TABLE IF EXISTS preprocess.aeropuertos;

CREATE TABLE preprocess.aeropuertos AS (
	WITH transform_aeropuertos as (
		SELECT *, st_transform(geom, 4326) as geom_tr
		FROM raw.aeropuertos)
	SELECT gid,
	       tipo,
	       st_transform(a.geom_tr, 4486) as geom
	FROM transform_aeropuertos as a
	JOIN preprocess.metropolitan_area AS metro
	ON st_within(a.geom_tr, metro.geom)
);


--------------------------------------------------
-- CROP vias ferreas to use only metropolitan area
---------------------------------------------------
-- Transform it to Mexican Datum of 1993 / UTM zone 13N EPSG:4486

DROP TABLE IF EXISTS preprocess.vias_ferreas;

CREATE TABLE preprocess.vias_ferreas AS (
	WITH transform_vias_ferreas as (
		SELECT *, st_transform(geom, 4326) as geom_tr
		FROM raw.vias_ferreas)
	SELECT gid,
	       tipo,
	       condicion,
	       st_transform(v.geom_tr, 4486) as geom
	FROM transform_vias_ferreas as v
	JOIN preprocess.metropolitan_area AS metro
	ON st_within(v.geom_tr, metro.geom)
);

