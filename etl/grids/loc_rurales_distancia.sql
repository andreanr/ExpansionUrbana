--#################################
-- Distancia a Localidades Rurales
--################################


DROP TABLE IF EXISTS grids_250.localidades_rurales_distance;
CREATE TABLE grids_250.localidades_rurales_distance AS (
SELECT cell_id, 
       '2000' AS "year",
       min(st_distance(geom, st_centroid(cell))) / 1000.0 AS loc_rurales_distancia_min
FROM preprocess.iter_2000, grids_250.grid
GROUP BY cell_id
UNION
SELECT cell_id, 
       '2005' AS "year",
       min(st_distance(geom, st_centroid(cell))) / 1000.0 AS loc_rurales_distancia_min
FROM preprocess.iter_2005, grids_250.grid
GROUP BY cell_id
UNION
SELECT cell_id, 
       '2010' AS "year",
       min(st_distance(geom, st_centroid(cell))) / 1000.0 AS loc_rurales_distancia_min
FROM preprocess.iter_2010, grids_250.grid
GROUP BY cell_id
);

CREATE INDEX ON grids_250.localidades_rurales_distance (cell_id, "year");
