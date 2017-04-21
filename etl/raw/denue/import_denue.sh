#!/usr/bin/env bash

#Read variables from config file
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat '../config.yaml' | shyaml get-value db.port)

RAW_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.raw)
EXTRACTED_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.extracted)


###################### DENUE ##########################
yes | unzip $RAW_DATA_FOLDER/denue_08_shp.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql -s 4326  -d -D -I $EXTRACTED_DATA_FOLDER"/denue_08_shp/conjunto_de_datos/denue_inegi_08_.shp" raw.denue | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

