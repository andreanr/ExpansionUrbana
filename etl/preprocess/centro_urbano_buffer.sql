
--##################################
-- CREATE BUFFER FOR CENTRO URBANO
--#################################

DROP TABLE IF EXISTS preprocess.centro_urbano;
CREATE TABLE preprocess.centro_urbano AS (
	SELECT st_buffer(st_transform(geom, 4486), 500) as geom
	FROM raw.centro_urbano
);
