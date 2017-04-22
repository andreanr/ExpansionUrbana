-- ##################################
-- Create Postgis extension
CREATE EXTENSION postgis;


--######################################
-- Insert INEGI geographical information:
--      Lambert Conformal Conic, double standard parallel
--      Units: Meter
--      Coordinate System Type:
--      Datum: World Geodetic System of 1984.
--      False Origin
--      Northing: 0.0000
--      Easting: 2500000.000
--      Projection Parameters
--      Origin latitude: 12° 0’ 0.0’’
--      Origin longitude: -102° 0’ 0.0’’
--      Northern standard parallel: 29° 30’ 0.0’’
--      Southern standard parallel: 17° 30’ 0.0’’

DELETE FROM spatial_ref_sys where srid = 939;

INSERT into spatial_ref_sys (
	srid, 
	auth_name, 
	auth_srid, 
	proj4text, 
	srtext) 
values ( 939, 
	'sr-org', 
	39, 
	'+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +ellps=WGS84 +units=m +no_defs ',
       	'PROJCS["unnamed",GEOGCS["WGS 84",DATUM["unknown",SPHEROID["WGS84",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["standard_parallel_1",17.5],PARAMETER["standard_parallel_2",29.5],PARAMETER["latitude_of_origin",12],PARAMETER["central_meridian",-102],PARAMETER["false_easting",2500000],PARAMETER["false_northing",0]]'
);
