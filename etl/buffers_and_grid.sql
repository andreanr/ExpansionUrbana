-------------------------------------------------------------------------------------------------
----------------------------------------- Buffers -----------------------------------------------
-------------------------------------------------------------------------------------------------
--2000
create table raw.buffer_2000 as (
select  st_buffer(st_multi(st_union(geom)),7000) as buffer_geom from raw.ageb_2000_vars);
--2005
create table raw.buffer_2005 as (
select  st_buffer(st_multi(st_union(geom)),7000) as buffer_geom from raw.ageb_2005_vars);
--2010
create table raw.buffer_2010 as (
select  st_buffer(st_multi(st_union(geom)),7000) as buffer_geom from raw.ageb_2010_vars);



-------------------------------------------------------------------------------------------------
--------------------------------------- Generate Grid -------------------------------------------
-------------------------------------------------------------------------------------------------
create table raw.grid_250 as (
SELECT cell FROM 
(SELECT (
ST_Dump(makegrid_2d(buffer_geom, -- WGS84 SRID
 250, 4486) -- cell step in meters
)).geom AS cell from raw.buffer_2010) AS q_grid)
