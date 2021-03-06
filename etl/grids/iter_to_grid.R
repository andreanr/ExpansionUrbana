

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


### FOR ITER
## clean iter geometries:
UpdateGeometry <- function(config, table_old, table_new){
  con = Connect2PosgreSQL(config)
  query_update_geom  = sprintf( "UPDATE preprocess.%s as t_old
                                SET geom = t_new.geom
                                FROM preprocess.%s as t_new
                                WHERE t_old.cve_loc = t_new.cve_loc", 
                                table_old,
                                table_new )
  dbSendQuery(con, query_update_geom)
}


# Join ITER with grid
JoinITERAndGrid <- function(config, columns_to_use, year){
  # Table name
  table_name = sprintf("iter_%s", year)
  
  ## split the list into totals and averages
  ### All avg columns have to have the word 'promedio' to distinguish them
  cols_totals = columns_to_use[-grep("promedio", columns_to_use)]
  cols_avg = columns_to_use[grep("promedio", columns_to_use)]
  
  ## convert to string for query
  cols_totals_str = paste(cols_totals, collapse = ', ')
  cols_avg_str = paste(cols_avg, collapse = ', ')

  ## for aggregates
  agg_totals_str = paste(sprintf("sum(%s::int) as %s", cols_totals, cols_totals), collapse= ', ')
  agg_avg_str = paste(sprintf("avg(%s::float) as %s", cols_avg, cols_avg), collapse= ', ')
  
  # Query delete if exist
  #query_delete = sprintf("drop table if exists hex_grid_250.%s", table_name)
  ## Query that creates the intersection 
  query_intersection = sprintf("select
                               cell_id,
                               %s, %s 
                               from hex_grid_250.grid
                               left join preprocess.%s
                               on st_contains(cell, geom)", 
                               cols_totals_str,
                               cols_avg_str,
                               table_name)
  
  #Query that groups by cell to sum/avg each column
  query_create = sprintf("with t_intersection as (%s)
                            select 
                                 cell_id, 
                                  %s::TEXT as year,
                                  %s, %s
                         from t_intersection
                         group by 1", 
                         query_intersection,
                         year,
                         agg_totals_str,
                         agg_avg_str)

  return(query_create)
}



#-------------
config = yaml.load_file("../../config.yaml")
con = Connect2PosgreSQL(config)
# update geometries with more updated iters
UpdateGeometry(config, 'iter_2005', 'iter_2010')
UpdateGeometry(config, 'iter_2000', 'iter_2010')
UpdateGeometry(config, 'iter_2000', 'iter_2005')

## Find the intersection of the census
query_share_columns = ("select column_name 
                       from information_schema.columns
                       where table_schema = 'preprocess'
                       and table_name = 'iter_2010'
                       and column_name not in ('cve_loc', 'longitud_decimal', 'latitud_decimal', 
                                              'cve_ent', 'entidad', 'mun', 'municipio', 'loc',
                                              'localidad', 'longitud', 'latitud', 'altitud', 'geom', 'tam_loc')
                       intersect
                       select column_name 
                       from information_schema.columns
                       where table_schema = 'preprocess'
                       and table_name = 'iter_2005'
                       intersect
                       select column_name 
                       from information_schema.columns
                       where table_schema = 'preprocess'
                       and table_name = 'iter_2000'
                       order by column_name")
con = Connect2PosgreSQL(config)
share_columns = get_postgis_query(con, query_share_columns)$column_name
dbDisconnect(con)

# Join census and grid
query_delete = c("drop table if exists hex_grid_250.censos_rurales")
create_query = sprintf("CREATE TABLE hex_grid_250.censos_rurales AS 
                       (%s)
                       UNION 
                       (%s)
                       UNION  
                       (%s)",
                       JoinITERAndGrid(config,share_columns,2000),
                       JoinITERAndGrid(config,share_columns,2005),
                       JoinITERAndGrid(config,share_columns,2010))

con = Connect2PosgreSQL(config)
dbSendQuery(con, query_delete)
dbSendQuery(con, create_query)
dbDisconnect(con)


