
# Install packages
#install.packages("yaml") # Be sure you have yaml package installed 
#install.packages("rgdal")
#install.packages("sp")
#install.packages("postGIStools")

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

JoinCensusAndGrid <- function(config, columns_to_use, table_name){
  # Connect to db
  con <- Connect2PosgreSQL(config)
  ## split the list into totals and averages
  ### All avg columns have to have the word 'promedio' to distinguish them
  cols_totals = columns_to_use[-grep("promedio", columns_to_use)]
  cols_avg = columns_to_use[grep("promedio", columns_to_use)]

  ## convert to string for query
  cols_totals_str = paste(cols_totals, collapse = ', ')
  cols_avg_str = paste(cols_avg, collapse = ', ')
  # use percentages
  cols_totals_fraction = paste(sprintf("(porcentage_ageb_share * %s::float) as %s", cols_totals, cols_totals), 
                             collapse = ', ')
  ## for aggregates
  agg_totals_str = paste(sprintf("sum(%s)::int as %s", cols_totals, cols_totals), collapse= ', ')
  agg_avg_str = paste(sprintf("avg(%s::float) as %s", cols_avg, cols_avg), collapse= ', ')

  # Query delete if exist
  query_delete = sprintf("drop table if exists grids.%s", table_name)
  ## Query that creates the intersection 
  query_intersection = sprintf("select
                            cell_id,
                            cell,
                            st_area(ST_Intersection(geom, cell)) / st_area(geom) as porcentage_ageb_share,
                            %s, %s 
                      from preprocess.grid_250
                      left join preprocess.%s
                      on st_intersects(cell, geom)", 
                                 cols_totals_str,
                                 cols_avg_str,
                                 table_name)
  
  #Query that assigns the values for each part of intersection
  query_fractions = sprintf("select
                                cell_id,
                                cell, 
                                %s, %s
                             from t_intersection", 
                              cols_totals_fraction,
                              cols_avg_str)
  
  #Query that groups by cell to sum/avg each column
  query_create = sprintf("Create table grids.%s as (
                             with t_intersection as (%s),
                                   t_fractions as (%s)
                              select 
                                  cell_id, 
                                  cell,
                                  %s, %s
                              from t_fractions
                              group by 1,2)", 
                                  table_name,
                                  query_intersection,
                                  query_fractions,
                                  agg_totals_str,
                                  agg_avg_str)
  # call query
  dbSendQuery(con, query_delete)
  dbSendQuery(con, query_create)
}



#---------------------------------------------------------------

## Read config file
config = yaml.load_file("../../config.yaml")

## Find the intersection of the census
query_share_columns = ("select column_name 
                      from information_schema.columns
                      where table_schema = 'preprocess'
                      and table_name = 'ageb_zm_2010'
                      and column_name not in ('clave_ageb','geom','gid')
                      intersect
                      select column_name 
                      from information_schema.columns
                        where table_schema = 'preprocess'
                      and table_name = 'ageb_zm_2005'
                      order by column_name")
con = Connect2PosgreSQL(config)
share_columns = get_postgis_query(con, query_share_columns)$column_name

# Join census and grid
JoinCensusAndGrid(config,share_columns,'ageb_zm_2010')
JoinCensusAndGrid(config,share_columns,'ageb_zm_2005')

