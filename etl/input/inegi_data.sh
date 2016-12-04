#!/usr/bin/env bash

#Read variables from config file
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat '../config.yaml' | shyaml get-value db.port)

ROOT_FOLDER=$(cat '../config.yaml' | shyaml get-value root.etl)
ZIP_FOLDER=$ROOT_FOLDER'/input/zip'
EXTRACTED_FOLDER=$ROOT_FOLDER'/input/extracted'

####################### AGEBS ##########################
# 2015
#unzip $ZIP_FOLDER/702825217341_s.zip -d $EXTRACTED_FOLDER
#shp2pgsql -s 4326 -d -D -I $EXTRACTED_FOLDER"/conjunto_de_datos/areas_geoestadisticas_basicas.shp" raw.ageb_2015 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

## 2010
yes | unzip $ZIP_FOLDER/702825292812_s.zip -d $EXTRACTED_FOLDER
yes | unzip $EXTRACTED_FOLDER/mgau2010v5_0.zip -d $EXTRACTED_FOLDER
shp2pgsql  -d -D -I -W "latin1" $EXTRACTED_FOLDER"/AGEB_urb_2010_5.shp" raw.ageb_2010 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

# 2005
yes | unzip $ZIP_FOLDER/702825292850_s.zip -d $EXTRACTED_FOLDER
yes | unzip $EXTRACTED_FOLDER/mgau2005v_1_0.zip -d $EXTRACTED_FOLDER
shp2pgsql  -d -D -I $EXTRACTED_FOLDER"/agebs_urb_2005.shp" raw.ageb_2005 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

# 2000
yes | unzip $ZIP_FOLDER/702825292843_s.zip -d $EXTRACTED_FOLDER
yes | unzip $EXTRACTED_FOLDER/mgau2000.zip -d $EXTRACTED_FOLDER
shp2pgsql  -d -D -I $EXTRACTED_FOLDER"/agebs_urb_2000.shp" raw.ageb_2000 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

# Zonas Metropolitanas
# shp2pgsql -s 4326 -d -D -I "$EXTRACTED_FOLDER/zonas_metropolitanas.shp" raw.zonas_metropolitanas | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

###################### CENSO ###########################


############# rasters de elevacion digital ##############
# raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 "$EXTRACTED_FOLDER/702825548681_b/h1310mde.bil" raw.elevacion_digital_1 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER
# raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 "$EXTRACTED_FOLDER/702825548698_b/h1311mde.bil" raw.elevacion_digital_2 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

yes | unrar e $ZIP_FOLDER/CEM_V3_R120_E08.rar $EXTRACTED_FOLDER
raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 $EXTRACTED_FOLDER"/Chihuahua30_R120m.bil" raw.elevacion_digital | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

###################### ITER ########################### 
# 2010
yes | unzip $ZIP_FOLDER/iter_nalcsv10.zip -d $EXTRACTED_FOLDER
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.iter_2010;"
head -n 100 $EXTRACTED_FOLDER'/iter_00_cpv2010/conjunto_de_datos/iter_00_cpv2010.csv' | dos2unix | csvsql -e latin1 -i "postgresql" --no-constraints --tables raw.iter_2010 | tr -d "\"" >> $EXTRACTED_FOLDER"/iter2010.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_FOLDER"/iter2010.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "COPY raw.iter_2010 FROM '$EXTRACTED_FOLDER/iter_00_cpv2010/conjunto_de_datos/iter_00_cpv2010.csv' DELIMITER ','  CSV header;"

### 2005
yes | unzip $ZIP_FOLDER/iter_naltxt05.zip -d $EXTRACTED_FOLDER
#head -n 100 $EXTRACTED_FOLDER"/ITER_NALTXT05.txt" | dos2unix | csvsql --tabs -e latin1 -i "postgresql" --no-constraints --tables raw.iter_2005 | tr -d "\"" >> $EXTRACTED_FOLDER"/iter2005.sql"
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.iter_2005;"
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_FOLDER"/iter2005.sql"
#psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "\copy raw.iter_2005 from $EXTRACTED_FOLDER'/ITER_NALTXT05.txt' with csv header;"
#
# 2000
#yes | unzip $ZIP_FOLDER/iter_naltxt00.zip -d $EXTRACTED_FOLDER
#csvsql --tabs -e latin1 --db postgresql://@$DB_HOST:$DB_PORT/$DB_NAME --insert EXTRACTED_FOLDER/ITER_NALTXT00.txt --db-schema raw --table iter_2000 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

###################### DENUE ##########################
unzip $ZIP_FOLDER/denue_08_shp.zip -d $EXTRACTED_FOLDER
shp2pgsql  -d -D -I $EXTRACTED_FOLDER"/denue_08_shp/conjunto_de_datos/denue_inegi_08_.shp" raw.denue | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

####################### Aeropuertos ####################
yes |  unzip $ZIP_FOLDER/aeropuerto.zip -d $EXTRACTED_FOLDER
shp2pgsql  -d -D -I $EXTRACTED_FOLDER"/Aeropuerto.shp"  raw.aeropuertos | psql -d $DB_NAME -h $DB_HOST -U  $DB_USER

################# Uso de Suelo #########################

################### Carreteras #########################
unzip $ZIP_FOLDER/carreviali08.zip -d $EXTRACTED_FOLDER

################## Vías Férreas #######################
unzip $ZIP_FOLDER/viaFerrea.zip -d $EXTRACTED_FOLDER
