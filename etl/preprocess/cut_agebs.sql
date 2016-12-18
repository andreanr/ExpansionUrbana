---------------------------------------------
-- CROP AGEB to use only metropolitan area
---------------------------------------------
-- Transform it to Mexican Datum of 1993 / UTM zone 13N EPSG:4486

-- AGEB 2000
DROP TABLE IF EXISTS preprocess.ageb_zm_2000;
CREATE TABLE preprocess.ageb_zm_2000 AS 
    WITH transform_ageb as (
	select gid,
	       clvagb as clave_ageb,
	       st_transform(geom, 4326) as geom
	from raw.ageb_2000)
    SELECT ageb.gid,
           ageb.clave_ageb,
	   st_transform(ageb.geom, 4486) as geom
    FROM transform_ageb AS ageb
    JOIN preprocess.metropolitan_area AS metro
    ON st_within(ageb.geom, metro.geom);

-- AGEB 2005
DROP TABLE IF EXISTS preprocess.ageb_zm_2005;
CREATE TABLE preprocess.ageb_zm_2005 AS
    WITH transform_ageb as (
	select gid,
	       clave as clave_ageb,
	       st_transform(geom, 4326) as geom
	from raw.ageb_2005)
     SELECT ageb.gid,
            ageb.clave_ageb,
	    st_transform(ageb.geom, 4486) as geom
     FROM transform_ageb AS ageb
     JOIN preprocess.metropolitan_area AS metro
     ON st_within(ageb.geom, metro.geom);

-- AGEB 2010
DROP TABLE IF EXISTS preprocess.ageb_zm_2010;
CREATE TABLE preprocess.ageb_zm_2010 AS
    WITH transform_ageb as (
	select gid,
	       cvegeo as clave_ageb,
	       st_transform(geom, 4326) as geom
	from raw.ageb_2010)
     SELECT ageb.gid,
            ageb.clave_ageb,
	    st_transform(ageb.geom, 4486) as geom
     FROM transform_ageb AS ageb
     JOIN preprocess.metropolitan_area AS metro
     ON st_within(ageb.geom, metro.geom);

