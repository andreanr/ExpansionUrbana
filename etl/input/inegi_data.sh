#!/usr/bin/env bash
LOCAL_DATA_FOLDER = "$DATA_FOLDER/etl/inegi"
SCHEMA = 'raw'

#Read variables from config file
DB_HOST=$(cat $ROOT_FOLDER'/config.yaml' | shyaml get-value db.host)
DB_USER=$(cat $ROOT_FOLDER'/config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat $ROOT_FOLDER'/config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat $ROOT_FOLDER'/config.yaml' | shyaml get-value db.port)



########################################################
####################### AGEBS ##########################
########################################################
gzip 
# shp2pgsql -s 4326 -d -D -I "$LOCAL_DATA_FOLDER/zonas_metropolitanas.shp" raw.zonas_metropolitanas | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

########################################################
###################### CENSO ###########################
########################################################


#########################################################
############# rasters de elevacion digital ##############
#########################################################
raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 "$LOCAL_DATA_FOLDER/702825548681_b/h1310mde.bil" $SCHEMA.elevacion_digital_1 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

raster2pgsql -d -I -C -M -F -t 100x100 -s 32613 -t 100x100 "$LOCAL_DATA_FOLDER/702825548698_b/h1311mde.bil" $SCHEMA.elevacion_digital_2 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

########################################################
####################### ITER ########################### 
########################################################
# 2010
csvsql --tabs -e latin1 --db postgresql://@$DB_HOST:$DB_PORT/$DB_NAME --insert iter_08TXT.txt --db-schema $SCHEMA --table iter_2005 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER
# 2005
csvsql --tabs -e latin1 --db postgresql://@$DB_HOST:$DB_PORT/$DB_NAME --insert iter_08TXT.txt --db-schema $SCHEMA --table iter_2005 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER
# 2000
csvsql --tabs -e latin1 --db postgresql://@$DB_HOST:$DB_PORT/$DB_NAME --insert "LOCAL_DATA_FOLDER/ITER_08TXT00.txt" --db-schema $SCHEMA --table iter_2000 | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

########################################################
####################### DENUE ##########################
########################################################
shp2pgsql -w ‘latin1’ -s 4326 -d -D -I "$LOCAL_DATA_FOLDER/DENUE_INEGI_08_.shp" $SCHEMA.denue | psql -d $DB_NAME -h $DB_HOST -U $DB_USER

########################################################
####################### Aeropuertos ####################
########################################################
shp2pgsql -s 4326 -d -D -I "aeropuertos.shp"  $SCHEMA.aeropuertos | psql -d $DB_NAME -h $DB_HOST -U  $DB_USER


########################################################
################# Uso de Suelo #########################
########################################################


########################################################
################### Carreteras #########################
########################################################
