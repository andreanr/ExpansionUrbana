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
DROP table if exists grids_250.grid;
create table grids_250.grid as (
WITH grid_sub as (
	SELECT cell FROM 
		(SELECT (
		ST_Dump(makegrid_2d(buffer_geom, -- WGS84 SRID
 		250, 4486) -- cell step in meters
	)).geom AS cell from preprocess.buffer_2010) AS q_grid)
SELECT ROW_NUMBER() OVER (ORDER BY cell ASC) as cell_id,
	cell
FROM grid_sub);

CREATE INDEX ON grids_250.grid (cell_id);
CREATE INDEX ON grids_250.grid USING GIST (cell);