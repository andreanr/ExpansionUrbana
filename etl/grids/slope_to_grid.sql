--##############
-- SLOP to GRID
--##############

-- slope in percentage
CREATE TABLE hex_grid_250.slope AS (
    WITH clip_slope_pct AS (
        SELECT cell_id,
	       ST_SummaryStats(st_union(st_clip(rast_percent, 1, cell, True))) AS stats_pct
	FROM hex_grid_250.grid
	LEFT JOIN preprocess.slope
	ON ST_Intersects(rast_percent, cell)
	GROUP BY cell_id
    ),
    clip_slope_degrees AS (
	SELECT cell_id,
		ST_SummaryStats(st_union(st_clip(rast_degrees, 1, cell, True))) AS stats_degrees
	FROM hex_grid_250.grid
	LEFT JOIN preprocess.slope
	ON ST_Intersects(rast_degrees, cell)
	GROUP BY cell_id
     )
	SELECT cell_id,
		(stats_pct).min AS min_slope_pct,
		(stats_pct).max AS max_slope_pct,
		(stats_pct).mean AS mean_slope_pct,
		(stats_pct).stddev AS stddev_slope_pct,
		(stats_degrees).min AS min_slope_degrees,
		(stats_degrees).max AS max_slope_degrees,
		(stats_degrees).mean AS mean_slope_degrees,
		(stats_degrees).stddev AS stddev_slope_degrees
	FROM clip_slope_pct
	JOIN clip_slope_degrees
	USING (cell_id)
	);

CREATE INDEX ON hex_grid_250.slope_percentages (cell_id);


