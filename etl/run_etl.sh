#Read variables from config file
echo 'Reading db connection details from ../config.yaml'
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)

#create schemas
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION postgis";
echo 'Dropping schemas if exists...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists raw CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists clean CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists semantic CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists ml CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists results CASCADE;"

echo 'Creating schemas...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA raw;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA clean;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA semantic;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA ml;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA results;"

echo 'Populating raw data...'
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME < 'add_spatial_ref.sql'
sh input/ageb_shapefiles/import_ageb_shapefiles.sh
sh input/census/import_census.sh
sh input/denue/import_denue.sh
sh input/geography/import_geography.sh
sh input/transportation/import_transportation.sh

echo 'Creating buffer and grid...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "utils.sql"
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "$ROOT_FOLDER/etl/buffers_and_grid.sql"

echo 'Populating clean data...'
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "$ROOT_FOLDER/etl/sql_script_raster.sql"

echo 'Done!'

