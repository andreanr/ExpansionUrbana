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
DROP table if exists preprocess.grid_250;
create table preprocess.grid_250 as (
SELECT cell FROM 
(SELECT (
ST_Dump(makegrid_2d(buffer_geom, -- WGS84 SRID
 250, 4486) -- cell step in meters
)).geom AS cell from preprocess.buffer_2010) AS q_grid)
