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

DELETE FROM spatial_ref_sys where srid = 909090;
INSERT into spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text)
values (909090, 'sr-org', 7759, '', '+proj=lcc +lat_1=1.75 +lat_2=29.5 +lat_0=12.0 +lon_0=-102.0 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs');
