#!/usr/bin/env bash

#Read variables from config file
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat '../config.yaml' | shyaml get-value db.port)

RAW_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.raw)
EXTRACTED_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.extracted)


## MUNICIPIOS 2010
yes | unzip $RAW_DATA_FOLDER/702825292812_s.zip -d $EXTRACTED_DATA_FOLDER
yes | unzip $EXTRACTED_DATA_FOLDER/mgm2010v5_0.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql -s 939 -d -D -I -W "latin1" $EXTRACTED_DATA_FOLDER"/Municipios_2010_5.shp" raw.municipios_2010 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER


## 2015
yes | unzip $RAW_DATA_FOLDER/702825217341_s.zip -d $EXTRACTED_DATA_FOLDER/702825217341_s
shp2pgsql -s 939  -d -D -I -W "latin1" $EXTRACTED_DATA_FOLDER"/702825217341_s/conjunto_de_datos/poligonos_localidades_urbanas_y_rurales.shp" raw.urbano_2015 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

### 2010
yes | unzip $EXTRACTED_DATA_FOLDER/mgau2010v5_0.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql -s 939  -d -D -I -W "latin1" $EXTRACTED_DATA_FOLDER"/AGEB_urb_2010_5.shp" raw.ageb_2010 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

# 2005
yes | unzip $RAW_DATA_FOLDER/702825292850_s.zip -d $EXTRACTED_DATA_FOLDER
yes | unzip $EXTRACTED_DATA_FOLDER/mgau2005v_1_0.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql -s 939 -d -D -I $EXTRACTED_DATA_FOLDER"/agebs_urb_2005.shp" raw.ageb_2005 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

# 2000
yes | unzip $RAW_DATA_FOLDER/702825292843_s.zip -d $EXTRACTED_DATA_FOLDER
yes | unzip $EXTRACTED_DATA_FOLDER/mgau2000.zip -d $EXTRACTED_DATA_FOLDER
shp2pgsql  -s 939 -d -D -I $EXTRACTED_DATA_FOLDER"/agebs_urb_2000.shp" raw.ageb_2000 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

# Zonas Metropolitanas
# shp2pgsql -s 4326 -d -D -I "$EXTRACTED_FOLDER/zonas_metropolitanas.shp" raw.zonas_metropolitanas | psql -d $DB_NAME -h $DB_HOST -U $DB_USER
