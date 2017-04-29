--###################################
-- Distancia a zonas urbanas
--###################################

DROP TABLE IF EXISTS grids_250.zonas_urbanas_distancia;
CREATE TABLE grids_250.zonas_urbanas_distancia AS (
	SELECT cell_id,
    	       '2000' AS "year",
    	        min(st_distance(geom, st_centroid(cell))) / 1000.0 AS zona_urbana_distancia_min
	FROM preprocess.ageb_zm_2000, grids_250.grid
	GROUP BY cell_id
	UNION
	SELECT cell_id,
	       '2005' AS "year",
	        min(st_distance(geom, st_centroid(cell))) / 1000.0 AS zona_urbana_distancia_min
	FROM preprocess.ageb_zm_2005, grids_250.grid
	GROUP BY cell_id
	UNION
	SELECT cell_id,
	       '2010' AS "year",
	       min(st_distance(geom, st_centroid(cell))) / 1000.0 AS zona_urbana_distancia_min
	FROM preprocess.ageb_zm_2010, grids_250.grid
	GROUP BY cell_id
);

CREATE INDEX ON grids_250.zonas_urbanas_distancia (cell_id, "year");
