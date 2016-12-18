#Read variables from config file
echo 'Reading db connection details from ../config.yaml'
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)

#Create extension and add inegi spatial reference
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME < 'add_spatial_ref.sql'

#create schemas
echo 'Dropping schemas if exists...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists raw CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists preprocess CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists clean CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists semantic CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists ml CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists results CASCADE;"

echo 'Creating schemas...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA raw;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA preprocess;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA clean;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA semantic;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA ml;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA results;"

echo 'Populating raw data...'
sh input/ageb_shapefiles/import_ageb_shapefiles.sh
sh input/census/import_census.sh
sh input/denue/import_denue.sh
sh input/geography/import_geography.sh
sh input/transportation/import_transportation.sh

echo 'Running pre-process'
sh run_preprocess.sh

echo 'Done!'
