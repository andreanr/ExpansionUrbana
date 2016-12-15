#!/usr/bin/env bash

#Read variables from config file
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat '../config.yaml' | shyaml get-value db.port)

RAW_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.raw)
EXTRACTED_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.extracted)

############# rasters de elevacion digital ##############
# raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 "$EXTRACTED_FOLDER/702825548681_b/h1310mde.bil" raw.elevacion_digital_1 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER
# raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 "$EXTRACTED_FOLDER/702825548698_b/h1311mde.bil" raw.elevacion_digital_2 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

yes | unrar e $RAW_DATA_FOLDER/CEM_V3_R120_E08.rar $EXTRACTED_DATA_FOLDER
raster2pgsql -s 4019  -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 $EXTRACTED_DATA_FOLDER"/Chihuahua30_R120m.bil" raw.elevacion_digital | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

