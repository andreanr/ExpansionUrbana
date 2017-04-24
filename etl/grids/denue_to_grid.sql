

CREATE TABLE grids.denue as (
	WITH denue_grouped AS (
		SELECT year_alta, 
		per_ocu, 
		st_union(geom) AS geom
		FROM preprocess.denue
		GROUP BY year_alta, per_ocu
	)
	SELECT 
		cell_id,
		year_alta,
		min(CASE WHEN per_ocu IN ('0 a 5 personas', '6 a 10 personas') 
			THEN st_distance(cell, ST_ClosestPoint(geom, cell)) / 1000.0
			ELSE NULL END) AS unidades_economicas_micro_distancia_km,
		min(CASE WHEN per_ocu IN ('11 a 30 personas', '31 a 50 personas')
			THEN st_distance(cell, ST_ClosestPoint(geom, cell)) / 1000.0
			ELSE NULL END) AS unidades_economicas_pequenas_distancia_km,
		min(CASE WHEN per_ocu IN ('51 a 100 personas', '101 a 250 personas')
			THEN st_distance(cell, ST_ClosestPoint(geom, cell)) / 1000.0
			ELSE NULL END) AS unidades_economicas_medianas_distancia_km,
		min(CASE WHEN per_ocu like ('251%')
			THEN st_distance(cell, ST_ClosestPoint(geom, cell)) / 1000.0
			ELSE NULL END) AS unidades_economicas_grandes_distancia_km
	FROM preprocess.grid_250, denue_grouped
	GROUP BY cell_id, year_alta
);

CREATE INDEX ON grids.denue (cell_id, year_alta);