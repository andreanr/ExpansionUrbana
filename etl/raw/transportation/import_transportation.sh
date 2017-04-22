#!/usr/bin/env bash

#Read variables from config file
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat '../config.yaml' | shyaml get-value db.port)

RAW_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.raw)
EXTRACTED_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.extracted)


####################### Aeropuertos ####################
yes |  unzip $RAW_DATA_FOLDER/aeropuerto.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql -s 939 -d -D -I $EXTRACTED_DATA_FOLDER"/Aeropuerto.shp"  raw.aeropuertos | psql -d $DB_NAME -h $DB_HOST -U  $DB_USER

################### Carreteras #########################
yes | unzip $RAW_DATA_FOLDER/carreviali08.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql -s 939 -d -D -I -W "latin1"  $EXTRACTED_DATA_FOLDER"/Red_de_Carreteras_08_Chih.shp" raw.carreteras | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

################## Vías Férreas #######################
yes | unzip $RAW_DATA_FOLDER/viaFerrea.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql  -s 939 -d -D -I $EXTRACTED_DATA_FOLDER"/ViaFerrea.shp" raw.vias_ferreas | psql -d $DB_NAME -h $DB_HOST -U $DB_USER
