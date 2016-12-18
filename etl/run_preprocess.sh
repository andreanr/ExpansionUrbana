#Read variables from config file
echo 'Reading db connection details from ../config.yaml'
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)

echo 'Creating buffer and grid...'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "preprocess/metropolitan_municipios.sql"

echo 'Cut ageb to metropolitan area'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "preprocess/cut_agebs.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "preprocess/utils.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "preprocess/buffers_and_grid.sql"

echo 'Project iter'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "preprocess/project_iter.sql"