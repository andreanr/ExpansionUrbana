-------------------------------------------------------------------------------------------------
----------------------------------------- Buffers -----------------------------------------------
-------------------------------------------------------------------------------------------------
--2000
DROP table if exists  preprocess.buffer_2000;
create table preprocess.buffer_2000 as (
select  st_buffer(st_multi(st_union(geom)),7000) as buffer_geom from preprocess.ageb_zm_2000);
--2005
DROP table if exists preprocess.buffer_2005;
create table preprocess.buffer_2005 as (
select  st_buffer(st_multi(st_union(geom)),7000) as buffer_geom from preprocess.ageb_zm_2005);
--2010
DROP table if exists preprocess.buffer_2010;
create table preprocess.buffer_2010 as (
select  st_buffer(st_multi(st_union(geom)),7000) as buffer_geom from preprocess.ageb_zm_2010);


-------------------------------------------------------------------------------------------------
--------------------------------------- Generate Grid -------------------------------------------
-------------------------------------------------------------------------------------------------
-- DROP table if exists grids_250.grid;
-- create table grids_250.grid as (
-- WITH grid_sub as (
-- 	SELECT cell FROM 
-- 		(SELECT (
-- 		ST_Dump(makegrid_2d(buffer_geom, -- WGS84 SRID
--  		250, 4486) -- cell step in meters
-- 	)).geom AS cell from preprocess.buffer_2010) AS q_grid)
-- SELECT ROW_NUMBER() OVER (ORDER BY cell ASC) as cell_id,
-- 	cell
-- FROM grid_sub);
-- 
-- CREATE INDEX ON grids_250.grid (cell_id);
-- CREATE INDEX ON grids_250.grid USING GIST (cell);

--------------------------------------------------------------------------------------------
------------------------------------ Generate Hexagons -------------------------------------
--------------------------------------------------------------------------------------------
DROP table if EXISTS hex_grid_250.grid;
CREATE TABLE hex_grid_250.grid (cell_id serial not null primary key);
SELECT addgeometrycolumn('hex_grid_250', 'grid','cell', 0, 'POLYGON', 2);

DROP FUNCTION genhexagons(float, float, float, float, float);
CREATE OR REPLACE FUNCTION genhexagons(side_length float, xmin float,ymin  float,xmax float,ymax float  )
RETURNS float AS $total$
declare
    c float :=side_length; --lado
    a float :=c/2; --lado/2
    b float :=c * sqrt(3)/2; --apotema
    height float := 2*a+c;  --1.1547*width;
    ncol float :=ceil(abs(xmax-xmin)/(2*b));
    nrow float :=ceil(abs(ymax-ymin)/(2*c));

    polygon_string varchar := 'POLYGON((' ||
                                        0 || ' ' || 0     || ' , ' ||
                                        b || ' ' || a     || ' , ' ||
                                        b || ' ' || a+c   || ' , ' ||
                                        0 || ' ' || a+c+a || ' , ' ||
                                     -1*b || ' ' || a+c   || ' , ' ||
                                     -1*b || ' ' || a     || ' , ' ||
                                        0 || ' ' || 0     ||
                                '))';
BEGIN
    INSERT INTO hex_grid_250.grid (cell) SELECT st_translate(cell, x_series*(2*b)+xmin, y_series*(2*(a+c))+ymin)
    from generate_series(0, ncol::int , 1) as x_series,
    generate_series(0, nrow::int,1 ) as y_series,
    (
       SELECT polygon_string::geometry as cell
       UNION
       SELECT ST_Translate(polygon_string::geometry, b , a+c)  as cell
    ) as two_hex;
    ALTER TABLE hex_grid_250.grid
    ALTER COLUMN cell TYPE geometry(Polygon, 4486)
    USING ST_SetSRID(cell,4486);
    RETURN NULL;
END;
$total$ LANGUAGE plpgsql;

with geom_bbox as (
   SELECT
        125 as side_length,
        ST_XMin(buffer_geom) as xmin,
        ST_YMin(buffer_geom) as ymin,
        ST_XMax(buffer_geom) as xmax,
        ST_YMax(buffer_geom) as ymax
FROM preprocess.buffer_2010
GROUP BY buffer_geom)
SELECT genhexagons(side_length,xmin,ymin,xmax,ymax)
FROM geom_bbox;

