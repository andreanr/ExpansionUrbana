#Read variables from config file
echo 'Reading db connection details from '$ROOT_FOLDER'/config.yaml'
DB_HOST=$(cat $ROOT_FOLDER'/config.yaml' | shyaml get-value db.host)
DB_USER=$(cat $ROOT_FOLDER'/config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat $ROOT_FOLDER'/config.yaml' | shyaml get-value db.database)

#create schemas
echo 'Creating schemas...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA raw;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA clean;"  
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA semantic;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA ml;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA results;"

echo 'Populating raw data...'

echo 'Creating buffer and grid...'
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "$ROOT_FOLDER/etl/utils.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "$ROOT_FOLDER/etl/buffers_and_grid.sql"

echo 'Populating clean data...'
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "$ROOT_FOLDER/etl/sql_script_raster.sql"

echo 'Done!'

