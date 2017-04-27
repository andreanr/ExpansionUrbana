
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

JoinCensusAndGrid <- function(config, columns_to_use, year){
  # Table name
  table_name = sprintf("ageb_zm_%s", year)
  
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
  
  ## Query that creates the intersection 
  query_intersection = sprintf("select
                            cell_id,
                            st_area(ST_Intersection(geom, cell)) / st_area(geom) as porcentage_ageb_share,
                            %s, %s 
                      from grids_250.grid
                      left join preprocess.%s
                      on st_intersects(cell, geom)", 
                                 cols_totals_str,
                                 cols_avg_str,
                                 table_name)
  
  #Query that assigns the values for each part of intersection
  query_fractions = sprintf("select
                                cell_id,
                                %s, %s
                             from t_intersection", 
                              cols_totals_fraction,
                              cols_avg_str)
  
  #Query that groups by cell to sum/avg each column
    query_create = sprintf( "with t_intersection as (%s),
                                   t_fractions as (%s)
                              select 
                                  cell_id,
                                  %s::TEXT as year,
                                  %s, %s
                              from t_fractions
                              group by 1", 
                                  query_intersection,
                                  query_fractions,
                                  year,
                                  agg_totals_str,
                                  agg_avg_str)
  # return query
  return(query_create)
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
                      intersect
                      select column_name 
                      from information_schema.columns
                       where table_schema = 'preprocess'
                       and table_name = 'ageb_zm_2000'
                      order by column_name")

con = Connect2PosgreSQL(config)
share_columns = get_postgis_query(con, query_share_columns)$column_name
dbDisconnect(con)

# Join census and grid
query_delete = c("drop table if exists grids_250.censos_urbanos")
create_query = sprintf("CREATE TABLE grids_250.censos_urbanos AS 
                 (%s)
                 UNION 
                 (%s)
                 UNION  
                 (%s)",
                       JoinCensusAndGrid(config,share_columns,2000),
                       JoinCensusAndGrid(config,share_columns,2005),
                       JoinCensusAndGrid(config,share_columns,2010))

con = Connect2PosgreSQL(config)
dbSendQuery(con, query_delete)
dbSendQuery(con, create_query)
dbDisconnect(con)




