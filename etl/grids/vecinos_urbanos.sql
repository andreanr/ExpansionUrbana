CREATE table hex_grids_250.vecinos_urbanos AS (
WITH intersect_2000 AS (
	SELECT  cell_id,
   		cell,
		sum(st_area(ST_Intersection(geom, cell)) / st_area(cell)) as porcentage_ageb_share
	FROM hex_grids_250.grid
	LEFT JOIN preprocess.ageb_zm_2000
	ON st_intersects(cell, geom)
	GROUP BY cell_id
),zu_2000 AS (
	SELECT  cell_id,
		cell,
		CASE WHEN  porcentage_ageb_share >= 50/100.0 THEN 1 ELSE 0 END AS urbano
 	FROM intersect_2000
), vecinos_2000 AS (
	SELECT  cell_id,
		cell, 
		ARRAY(SELECT p.urbano
		      FROM zu_2000 p
		      WHERE ST_Touches(b.cell, p.cell) 
		      AND b.cell_id <> p.cell_id) AS vecinos_urbanos
		      FROM hex_grids_250.grid b
), intersect_2005 AS (
	SELECT  cell_id,
		cell,
		sum(st_area(ST_Intersection(geom, cell)) / st_area(cell)) as porcentage_ageb_share
	FROM hex_grids_250.grid
	LEFT JOIN preprocess.ageb_zm_2005
	ON st_intersects(cell, geom)
	GROUP BY cell_id
 ),zu_2005 AS (
	SELECT  cell_id,
		cell,
		CASE WHEN  porcentage_ageb_share >= 50/100.0 THEN 1 ELSE 0 END AS urbano
	FROM intersect_2005
), vecinos_2005 AS (
        SELECT  cell_id,
		cell,
		ARRAY(SELECT p.urbano
		      FROM zu_2005 p
                      WHERE ST_Touches(b.cell, p.cell)
                      AND b.cell_id <> p.cell_id) AS vecinos_urbanos
                      FROM hex_grids_250.grid b
), intersect_2010 AS (
        SELECT  cell_id,
                cell,
                sum(st_area(ST_Intersection(geom, cell)) / st_area(cell)) as porcentage_ageb_share
         FROM hex_grids_250.grid
         LEFT JOIN preprocess.ageb_zm_2010
         ON st_intersects(cell, geom)
         GROUP BY cell_id
 ),zu_2010 AS (
        SELECT  cell_id,
                cell,
                CASE WHEN  porcentage_ageb_share >= 50/100.0 THEN 1 ELSE 0 END AS urbano
        FROM intersect_2010
), vecinos_2010 AS (
        SELECT  cell_id,
                cell,
                ARRAY(SELECT p.urbano
                      FROM zu_2010 p
                      WHERE ST_Touches(b.cell, p.cell)
                      AND b.cell_id <> p.cell_id) AS vecinos_urbanos
                      FROM hex_grids_250.grid b
) SELECT cell_id,
	'2000'::TEXT as year,
	(SELECT SUM(s) FROM UNNEST(vecinos_urbanos) s) AS num_vecinos_urbanos
FROM vecinos_2000
	UNION
SELECT cell_id,
       '2005'::TEXT as year,
	 (SELECT SUM(s) FROM UNNEST(vecinos_urbanos) s) AS num_vecinos_urbanos
FROM vecinos_2005
	UNION
SELECT cell_id,
       '2010'::TEXT as year,
        (SELECT SUM(s) FROM UNNEST(vecinos_urbanos) s) AS num_vecinos_urbanos
FROM vecinos_2010
);
