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
----------------------------- Function to generate grid -----------------------------------------
-------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.makegrid_2d (
  bound_polygon public.geometry,
  grid_step integer,
  metric_srid integer = 28408 --metric SRID (this particular is optimal for the Western Russia)
)
RETURNS public.geometry AS
$body$
DECLARE
  BoundM public.geometry; --Bound polygon transformed to the metric projection (with metric_srid SRID)
  Xmin DOUBLE PRECISION;
  Xmax DOUBLE PRECISION;
  Ymax DOUBLE PRECISION;
  X DOUBLE PRECISION;
  Y DOUBLE PRECISION;
  sectors public.geometry[];
  i INTEGER;
BEGIN
  BoundM := ST_Transform($1, $3); --From WGS84 (SRID 4326) to the metric projection, to operate with step in meters
  Xmin := ST_XMin(BoundM);
  Xmax := ST_XMax(BoundM);
  Ymax := ST_YMax(BoundM);

  Y := ST_YMin(BoundM); --current sector's corner coordinate
  i := -1;
  <<yloop>>
  LOOP
    IF (Y > Ymax) THEN  --Better if generating polygons exceeds the bound for one step. You always can crop the result. But if not you may get not quite correct data for outbound polygons (e.g. if you calculate frequency per sector)
        EXIT;
    END IF;

    X := Xmin;
    <<xloop>>
    LOOP
      IF (X > Xmax) THEN
          EXIT;
      END IF;

      i := i + 1;
      sectors[i] := ST_GeomFromText('POLYGON(('||X||' '||Y||', '||(X+$2)||' '||Y||', '||(X+$2)||' '||(Y+$2)||', '||X||' '||(Y+$2)||', '||X||' '||Y||'))', $3);

      X := X + $2;
    END LOOP xloop;
    Y := Y + $2;
  END LOOP yloop;

  RETURN ST_Transform(ST_Collect(sectors), ST_SRID($1));
END;
$body$
LANGUAGE 'plpgsql';

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
create table raw.grid_250 as (
SELECT cell FROM 
(SELECT (
ST_Dump(makegrid_2d(buffer_geom, -- WGS84 SRID
 250, 4486) -- cell step in meters
)).geom AS cell from raw.buffer_2010) AS q_grid)
