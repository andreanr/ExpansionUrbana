#!/usr/bin/env bash

#Read variables from config file
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat '../config.yaml' | shyaml get-value db.port)

RAW_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.raw)
EXTRACTED_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.extracted)

############# rasters de elevacion digital ##############
yes | unzip $RAW_DATA_FOLDER/702825548681_b -d  $EXTRACTED_DATA_FOLDER
yes | unzip $RAW_DATA_FOLDER/702825548698_b -d  $EXTRACTED_DATA_FOLDER

rm -R $EXTRACTED_DATA_FOLDER/geography
mkdir $EXTRACTED_DATA_FOLDER/geography

cp $EXTRACTED_DATA_FOLDER/702825548681_b/* $EXTRACTED_DATA_FOLDER/geography/
cp $EXTRACTED_DATA_FOLDER/702825548698_b/* $EXTRACTED_DATA_FOLDER/geography/

raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 $EXTRACTED_DATA_FOLDER/geography/*.bil raw.elevacion_digital > elev.sql 
psql -d $DB_NAME -h $DB_HOST -U $DB_USER -f elev.sql

