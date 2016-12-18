DROP TABLE IF EXISTS preprocess.metropolitan_area;
CREATE table preprocess.metropolitan_area as
    SELECT 'ZMChihuahua'::text AS  zona,
           st_union(st_transform(geom, 4326)) AS geom
    FROM raw.municipios_2010
       WHERE cve_ent = '08'
       AND cve_mun in ('002','004','019');
