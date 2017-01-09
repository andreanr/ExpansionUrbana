#!/usr/bin/env bash

#Read variables from config file
DB_HOST=$(cat '../config.yaml' | shyaml get-value db.host)
DB_USER=$(cat '../config.yaml' | shyaml get-value db.user)
DB_NAME=$(cat '../config.yaml' | shyaml get-value db.database)
DB_PORT=$(cat '../config.yaml' | shyaml get-value db.port)

RAW_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.raw)
EXTRACTED_DATA_FOLDER=$(cat '../config.yaml' | shyaml get-value etl.extracted)



###################### CENSO ###########################
# 2000
yes | unzip $RAW_DATA_FOLDER'/censo_urbano_2000.zip' -d $EXTRACTED_DATA_FOLDER
awk 'FNR==1 && NR!=1{next;}{print}' $EXTRACTED_DATA_FOLDER/censo_urbano_2000/*csv > $EXTRACTED_DATA_FOLDER/tmp.csv
cat $EXTRACTED_DATA_FOLDER/tmp.csv | dos2unix | sed 's/^M//g' > $EXTRACTED_DATA_FOLDER/censo_urbano_2000.csv
cat $EXTRACTED_DATA_FOLDER'/censo_urbano_2000.csv' | dos2unix |tr [:upper:] [:lower:] | csvsql -e latin1 -i "postgresql" --no-constraints --tables raw.censo_urbano_2000 | tr -d "\"" > $EXTRACTED_DATA_FOLDER'/censo2000.sql'
rm $EXTRACTED_DATA_FOLDER/tmp.csv
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.censo_urbano_2000;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_DATA_FOLDER'/censo2000.sql'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Copy raw.censo_urbano_2000 from '$EXTRACTED_DATA_FOLDER/censo_urbano_2000.csv' WITH DELIMITER as ','  NULL AS '*' csv header  ;"

# 2005
yes | unzip $RAW_DATA_FOLDER'/censo_urbano_2005.zip' -d $EXTRACTED_DATA_FOLDER
awk 'FNR==1 && NR!=1{next;}{print}' $EXTRACTED_DATA_FOLDER/censo_urbano_2005/*csv > $EXTRACTED_DATA_FOLDER/tmp.csv
cat $EXTRACTED_DATA_FOLDER/tmp.csv | dos2unix | sed 's/^M//g' > $EXTRACTED_DATA_FOLDER/censo_urbano_2005.csv
cat $EXTRACTED_DATA_FOLDER'/censo_urbano_2005.csv' | dos2unix |tr [:upper:] [:lower:] | csvsql -e latin1 -i "postgresql" --no-constraints --tables raw.censo_urbano_2005 | tr -d "\"" > $EXTRACTED_DATA_FOLDER'/censo2005.sql'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.censo_urbano_2005;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_DATA_FOLDER'/censo2005.sql'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Copy raw.censo_urbano_2005 from '$EXTRACTED_DATA_FOLDER/censo_urbano_2005.csv' WITH DELIMITER as ','  NULL AS '*' csv header ;"

# 2010
yes | unzip $RAW_DATA_FOLDER'/RESAGEBURB_08csv10.zip' -d $EXTRACTED_DATA_FOLDER
cat $EXTRACTED_DATA_FOLDER'/resultados_ageb_urbana_08_cpv2010/conjunto_de_datos/resultados_ageb_urbana_08_cpv2010.csv' | dos2unix |tr [:upper:] [:lower:] | csvsql -e latin1 -i "postgresql" --no-constraints --tables raw.censo_urbano_2010 | tr -d "\"" > $EXTRACTED_DATA_FOLDER'/censo2010.sql'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.censo_urbano_2010;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_DATA_FOLDER'/censo2010.sql'
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Copy raw.censo_urbano_2010 from '$EXTRACTED_DATA_FOLDER/resultados_ageb_urbana_08_cpv2010/conjunto_de_datos/resultados_ageb_urbana_08_cpv2010.csv' WITH DELIMITER as ','  NULL AS '*' csv header  ;"
#
####################### ITER ###########################
## 2010
yes | unzip $RAW_DATA_FOLDER/iter_08xls10.zip -d $EXTRACTED_DATA_FOLDER
in2csv $EXTRACTED_DATA_FOLDER'/ITER_08XLS10.xls' > $EXTRACTED_DATA_FOLDER'/ITER_08XLS10.csv'
sed "s/*//g" $EXTRACTED_DATA_FOLDER/ITER_08XLS10.csv > $EXTRACTED_DATA_FOLDER/ITER_08XLS10_clean.csv
rm $EXTRACTED_DATA_FOLDER/ITER_08XLS10.csv
cat $EXTRACTED_DATA_FOLDER"/ITER_08XLS10_clean.csv" | dos2unix |tr [:upper:] [:lower:] | csvsql -e latin1 -i "postgresql" --no-constraints --tables raw.iter_2010 | tr -d "\"" > $EXTRACTED_DATA_FOLDER"/iter2010.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.iter_2010;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_DATA_FOLDER"/iter2010.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Copy raw.iter_2010 from '$EXTRACTED_DATA_FOLDER/ITER_08XLS10_clean.csv' DELIMITER ',' CSV header;"
#
### 2005
yes | unzip $RAW_DATA_FOLDER/iter_08xls05.zip -d $EXTRACTED_DATA_FOLDER
in2csv $EXTRACTED_DATA_FOLDER'/ITER_08XLS05.xls' > $EXTRACTED_DATA_FOLDER'/ITER_08XLS05.csv'
sed "s/*//g" $EXTRACTED_DATA_FOLDER'/ITER_08XLS05.csv' > $EXTRACTED_DATA_FOLDER'/ITER_08XLS05_clean.csv'
rm $EXTRACTED_DATA_FOLDER'/ITER_08XLS05.csv'
cat $EXTRACTED_DATA_FOLDER"/ITER_08XLS05_clean.csv" | dos2unix | csvsql -e latin1 -i "postgresql" --no-constraints --tables raw.iter_2005 | tr -d "\"" > $EXTRACTED_DATA_FOLDER"/iter2005.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.iter_2005;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_DATA_FOLDER"/iter2005.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Copy raw.iter_2005 from '$EXTRACTED_DATA_FOLDER/ITER_08XLS05_clean.csv' DELIMITER ',' CSV header;"
#
# 2000
yes | unzip $RAW_DATA_FOLDER/iter_08xls00.zip -d $EXTRACTED_DATA_FOLDER
in2csv $EXTRACTED_DATA_FOLDER'/ITER_08XLS00.xls' > $EXTRACTED_DATA_FOLDER'/ITER_08XLS00.csv'
sed "s/*//g" $EXTRACTED_DATA_FOLDER'/ITER_08XLS00.csv' > $EXTRACTED_DATA_FOLDER'/ITER_08XLS00_clean.csv'
rm $EXTRACTED_DATA_FOLDER'/ITER_08XLS00.csv'
cat $EXTRACTED_DATA_FOLDER"/ITER_08XLS00_clean.csv" | dos2unix | csvsql -e latin1 -i "postgresql" --no-constraints --tables raw.iter_2000 | tr -d "\"" > $EXTRACTED_DATA_FOLDER"/iter2000.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Drop table if exists raw.iter_2000;"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $EXTRACTED_DATA_FOLDER"/iter2000.sql"
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "Copy raw.iter_2000 from '$EXTRACTED_DATA_FOLDER/ITER_08XLS00_clean.csv' DELIMITER ',' CSV header;"
