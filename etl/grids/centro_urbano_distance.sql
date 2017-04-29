
DROP TABLE IF EXISTS grids_250.centro_urbano;
CREATE TABLE grids_250.centro_urbano as (
	SELECT cell_id,
	       ST_Distance(geom, st_centroid(cell)) /1000 AS centro_urbano_distancia_km
		FROM grids_250.grid, preprocess.centro_urbano
);
