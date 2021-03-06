
DROP TABLE IF EXISTS hex_grid_250.centro_urbano;
CREATE TABLE hex_grid_250.centro_urbano as (
	SELECT cell_id,
	       ST_Distance(geom, st_centroid(cell)) /1000 AS centro_urbano_distancia_km
		FROM hex_grid_250.grid, preprocess.centro_urbano
);
