
select column_name from information_schema.columns
where table_schema = 'preprocess'
and table_name = 'ageb_zm_2010'
intersect
select column_name from information_schema.columns
where table_schema = 'preprocess'
and table_name = 'ageb_zm_2005'
order by column_name;


drop view IF EXISTS  poblacion_cell;
create TABLE poblacion_cell as (
with t1 as (
	select 
		cell_id,
		cell,
		st_area(geom) as area_ageb,
		st_area(cell) as area_cell,
		st_area(ST_Intersection(geom, cell)) as share_area,
		st_area(ST_Intersection(geom, cell)) / st_area(geom) as porcentage_ageb_share,
		st_area(ST_Intersection(geom, cell)) / st_area(cell) as porcentage_cell_share,
		poblacion_total
	from preprocess.grid_250
	left join preprocess.ageb_zm_2010
	on st_intersects(cell, geom))
,new_values as (
	select 
		*, 
		(porcentage_ageb_share * poblacion_total)::int as value_cell
	from t1
	where share_area is not null
	order by porcentage_cell_share desc
	)
select cell_id, cell, sum(value_cell) as pob_total_per_cell
from new_values
group by 1,2);


select *  from preprocess.iter_2010 limit 10;
select * from preprocess.iter_2005 limit 10;

-- make a function!!! 
UPDATE preprocess.iter_2005 as t_old
SET geom = t_new.geom,
FROM preprocess.iter_2010 as t_new
where t_old.cve_loc = t_new.cve_loc;



-- from 2010 to 2005
select t_old.cve_loc, t_old.geom, t_new.geom
from preprocess.iter_2005 as t_old
join preprocess.iter_2010 as t_new
on t_old.cve_loc = t_new.cve_loc
and ST_Distance(t_old.geom, t_new.geom) > 0;

-- from 2010 to 2000
select t_old.cve_loc, t_old.geom, t_new.geom
from preprocess.iter_2000 as t_old
join preprocess.iter_2010 as t_new
on t_old.cve_loc = t_new.cve_loc
and ST_Distance(t_old.geom, t_new.geom) > 0;

-- from 2005 to 2000
select t_old.cve_loc, t_old.geom, t_new.geom
from preprocess.iter_2000 as t_old
join preprocess.iter_2005 as t_new
on t_old.cve_loc = t_new.cve_loc
and ST_Distance(t_old.geom, t_new.geom) > 0;


-- slope
SELECT * FROM
from preprocess.grid_250
LEFT JOIN preprocess.slope

