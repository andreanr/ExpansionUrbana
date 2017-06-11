# Read variables from config file
echo 'Reading db connection details from ../config.yaml'
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
ROOT_PATH=$(cat '../config.yaml' | shyaml get-value db.root)

#'Dropping grids schema'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "DROP SCHEMA if exists hex_grid_250 CASCADE;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE SCHEMA hex_grid_250;"

echo 'Create grid'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/buffers_and_grid.sql"

echo 'Censo urbano to grid'

echo 'Censo rural to grid'

echo 'Slope to grid'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/slope_to_grid.sql"

echo 'transportation to grid'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/transportation_to_grid.sql"

echo 'denue to grid'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/denue_to_grid.sql"

echo 'Distancia a localidades rurales'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/loc_rurales_distancia.sql"

echo 'Distancia a areas urbanas'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/zonas_urbanas_distance.sql"

echo 'Distancia centro urbano'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/centro_urbano_distance.sql"

echo 'Vecinos urbanos'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < "grids/vecinos_urbanos.sql"
