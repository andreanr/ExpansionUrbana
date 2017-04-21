--#####################################
-- CREATE SLOPE IN PERCENT AND DEGREES
--#####################################

DROP TABLE IF EXISTS preprocess.slope;

create table preprocess.slope as ( 
WITH rast_tr as (
	SELECT 
	       ST_Transform(st_union(rast), 4486) as rast
	FROM raw.elevacion_digital)
select 
       st_tile(st_slope(rast,1,'32BF','PERCENT'), 100, 100, TRUE) as rast_percent,
       st_tile(st_slope(rast,1), 100, 100, TRUE) as rast_degrees
from rast_tr);

CREATE INDEX ON preprocess.slope USING gist( ST_ConvexHull(rast_percent) );
CREATE INDEX ON preprocess.slope USING gist( ST_ConvexHull(rast_degrees) );
