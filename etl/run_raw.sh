#Read variables from config file
echo 'Reading db connection details from ../config.yaml'
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)

#Create extension and add inegi spatial reference
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < 'add_spatial_ref.sql'

#create schemas
echo 'Dropping schemas if exists...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists raw CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists preprocess CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists clean CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists grids_250 CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists grids_500 CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists semantic CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists ml CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists results CASCADE;"

echo 'Creating schemas...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA raw;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA preprocess;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA clean;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA grids_250;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA grids_500;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA semantic;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA ml;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA results;"

echo 'Populating raw data...'
sh raw/import_ageb_shapefiles.sh
sh raw/import_census.sh
sh raw/import_denue.sh
sh raw/import_geography.sh
sh raw/import_transportation.sh
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "raw/centro_urbano.sql"

echo 'Running pre-process'
sh run_preprocess.sh

echo 'Done!'
