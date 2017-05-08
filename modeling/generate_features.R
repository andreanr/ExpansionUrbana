# Import packages
require(yaml) 
require(sp)
require(RPostgreSQL)
require(postGIStools)

Connect2PosgreSQL <- function(config){
  dbname = config$db$database
  host = config$db$host
  user = config$db$user
  pass = config$db$password
  
  ## Connect to db
  con = dbConnect(drv = dbDriver("PostgreSQL"), 
                  dbname = config$db$database, host = config$db$host, 
                  port = config$db$port, user = config$db$user, 
                  password = config$db$password)
  return(con)
}

GenerateFeature <- function(config, experiment){
  # connect to db
  con = Connect2PosgreSQL(config)
  
  # From experiment
  features_df = plyr::ldply (experiment$Features, data.frame, stringsAsFactors=FALSE)
  colnames(features_df) <- c('feature_name','keep')
  #keep only the TRUE values
  features <- features_df$feature_name[features_df$keep == TRUE]
  features_table_name <- experiment$features_table_name
  grid_size <- experiment$grid_size
  
  #Drop table if exists
  query_drop = sprintf("DROP TABLE IF EXISTS features.%s_%s",
                       features_table_name,
                       grid_size)
  
  # Create select statement
  select_statement <- paste(sprintf("COALESCE(%1$s,0) AS %1$s", features), 
                            collapse = ', ')
  query = sprintf("CREATE TABLE  features.%s_%s AS (
                  SELECT cell_id, year, %s
                  FROM grids_250.aeropuertos
                  JOIN grids_250.carreteras
                  USING (cell_id)
                  JOIN grids_250.censos
                  USING (cell_id)
                  JOIN grids_250.centro_urbano
                  USING (cell_id)
                  JOIN grids_250.denue
                  USING (cell_id)
                  JOIN grids_250.localidades_rurales_distance
                  USING (cell_id, year)
                  JOIN grids_250.slope
                  USING (cell_id)
                  JOIN grids_250.vias_ferreas
                  USING (cell_id)
                  JOIN grids_250.zonas_urbanas_distancia
                  USING (cell_id, year)
                ) ", features_table_name, 
                     grid_size,
                     select_statement)
  
  query_index = sprintf("CREATE INDEX ON features.%s_%s (year)",
                        features_table_name,
                        grid_size)
  
  dbSendQuery(con, query_drop)
  dbSendQuery(con, query)
  dbSendQuery(con, query_index)
  dbDisconnect(con)
}


GenerateLabels <- function(config,
                           labels_table_name,
                           grid_size,
                           intersect_percent){

  #Drop table if exists
  query_drop = sprintf("DROP TABLE IF EXISTS features.%s_%s_%s",
                       labels_table_name,
                       intersect_percent,
                       grid_size)
  
  query = sprintf("CREATE TABLE features.%s_%3$s_%s AS (
                  WITH intersect_2000 AS (
	                    SELECT cell_id,
                             '2000'::TEXT AS year,
                             sum(st_area(ST_Intersection(geom, cell)) / st_area(cell)) as porcentage_ageb_share
                      FROM grids_250.grid
                      LEFT JOIN preprocess.ageb_zm_2005
                      ON st_intersects(cell, geom)
                      GROUP BY cell_id
                  ),labels_2000 AS (
                      SELECT cell_id,
                             year,
                            CASE WHEN  porcentage_ageb_share >= %3$s /100.0 THEN 1 ELSE 0 END AS label
                      FROM intersect_2000
                  ), intersect_2005 AS (
                      SELECT cell_id,
                             '2005'::TEXT AS year,
                              sum(st_area(ST_Intersection(geom, cell)) / st_area(cell)) as porcentage_ageb_share
                      FROM grids_250.grid
                      LEFT JOIN preprocess.ageb_zm_2010
                      ON st_intersects(cell, geom)
                      GROUP BY cell_id
                  ), labels_2005 AS (
                      SELECT cell_id,
                              year,
                              CASE WHEN  porcentage_ageb_share >= %3$s /100.0 THEN 1 ELSE 0 END AS label
                      FROM intersect_2005
                  ) SELECT * FROM labels_2000
                      UNION
                    SELECT * FROM labels_2005 )",
                  labels_table_name,
                  grid_size,
                  intersect_percent)
  
  query_index = sprintf("CREATE INDEX ON features.%s_%s_%s (year)",
                        labels_table_name,
                        intersect_percent,
                         grid_size)
  
  # connect to db
  con = Connect2PosgreSQL(config)
  dbSendQuery(con, query_drop)
  dbSendQuery(con, query)
  dbSendQuery(con, query_index)
  dbDisconnect(con)
}


#--------------------------------------------------
##Read config file
config = yaml.load_file("../config.yaml")

#Read experiment
experiment = yaml.load_file("../experiment.yaml")
# From experiment
labels_table_name <- experiment$labels_table_name
grid_size <- experiment$grid_size
intersect_percent <- experiment$intersect_percents

# Generate features table
GenerateFeature(config, experiment)

# Generate labels table
for (i in 1:length(intersect_percent)){
  GenerateLabels(config,
                 labels_table_name,
                 grid_size,
                 intersect_percent[i])
}




