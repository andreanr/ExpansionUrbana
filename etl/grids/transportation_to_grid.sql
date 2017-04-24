
CREATE TABLE grids.aeropuertos as (
	SELECT cell_id,
	       ST_Distance(st_centroid(geom), cell) /1000 AS aeropuerto_distancia_km
	FROM preprocess.grid_250, preprocess.aeropuertos
  );

CREATE INDEX ON grids.aeropuertos (cell_id);

CREATE TABLE grids.vias_ferreas as (
	SELECT cell_id,
	       min(ST_Distance(st_centroid(geom), cell) /1000) AS via_ferrea_distancia_km
	FROM preprocess.grid_250, preprocess.vias_ferreas
	GROUP BY cell_id
);

CREATE INDEX ON grids.vias_ferreas (cell_id);

CREATE TABLE grids.carreteras as (
	SELECT cell_id,
	       min(CASE WHEN derecho_transito = 'CUOTA' 
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS cuota_distancia_km,
	       min(CASE WHEN derecho_transito = 'LIBRE' 
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS libre_distancia_km,
	       min(CASE WHEN tipo_via = 'CARRETERA' 
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS carretera_distancia_km,
	       min(CASE WHEN tipo_via = 'CALLE' 
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS calle_distancia_km,
	       min(CASE WHEN tipo_via = 'AVENIDA' 
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS avenida_distancia_km,
	       min(CASE WHEN numero_carriles = '1'
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS carriles_1_distancia_km,
	       min(CASE WHEN numero_carriles = '2'
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS carriles_2_distancia_km,
	       min(CASE WHEN numero_carriles = '4'
		   THEN ST_Distance(st_centroid(geom), cell) /1000.0 
		   ELSE NULL END) AS carriles_4_distancia_km
	FROM preprocess.grid_250, preprocess.carreteras
	GROUP BY cell_id
); 
  
CREATE INDEX ON grids.carreteras (cell_id);
	       
	       
