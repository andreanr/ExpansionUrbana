
-- raster
select * from raw.elevacion_digital;

-- metadata
select (st_metadata(rast)).* from raw.elevacion_digital;
--cuenta metadata
select count((st_metadata(rast))) from raw.elevacion_digital;
-- numero de bandas
select st_numbands(rast) from raw.elevacion_digital;

-- tipo de dato de la banda: 16BUIentero de 16 bits con signo -32768,32767
select st_bandmetadata(rast,1) from raw.elevacion_digital;

-- resumen de los estadisticos 
select st_summarystats(rast,1) from raw.elevacion_digital;

-- para cada valor diferente del raster o de una capa del rastyer cuantos pixeles tienen el mismo valor
select st_valuecount(rast,1) from raw.elevacion_digital;

-- numero de piexeles de una banda
select st_count(rast,1) from raw.elevacion_digital;
-- histograma
select st_histogram(rast,1) from raw.elevacion_digital;
-- vectorizar
select (rc).x, (rc).y, (rc).val, st_astext((rc).geom) as geom 
from (select st_pixelaspolygons(rast,1) as rc from raw.elevacion_digital) foo;

-------------------------------------------------------------------------------------------------
------------------------------------------- SLOPE -----------------------------------------------
-------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS preprocess.slope;
create table preprocess.slope as 
select rid, st_slope(rast,1,'32BF','PERCENT') as rast_percent, st_slope(rast,1) as rast_degrees
from raw.elevacion_digital;


select st_summarystats(rast_percent,1) from slope;

select st_valuecount(rast_percent,1) from slope order by st_valuecount(rast_percent,1) desc;
select st_valuecount(rast_degrees,1) from slope order by st_valuecount(rast_degrees,1) desc



