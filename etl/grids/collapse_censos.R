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

ColumnNames <- function(config, table_name){
  con = Connect2PosgreSQL(config)
  query = sprintf( "SELECT column_name
                   FROM information_schema.columns
                   WHERE table_schema = 'grids_250'
                   AND table_name = '%s'
                   AND column_name not in
                   ('clave_ageb','geom','gid', 'year', 'cell_id')", 
                   table_name)
  column_names = get_postgis_query(con, query)$column_name
  dbDisconnect(con)
  return(column_names)
}

CollapseCensos <- function(config){
  ## Read columns for censo urbano
  censo_urbano_cols = ColumnNames(config, 'censos_urbanos')
  # READ columns for censo rural
  censo_rural_cols = ColumnNames(config, 'censos_rurales')
  # JOIN
  censos_vars = unique(c(censo_urbano_cols, censo_rural_cols))
  
  selects = c()
  for (i in 1:length(censos_vars)){
    if (censos_vars[i] %in% censo_urbano_cols) {
      if (censos_vars[i] %in% censo_rural_cols){
        selects = c(selects, sprintf( "COALESCE(c.%1$s,0) +
                                      COALESCE(r.%1$s,0) AS %1$s", 
                                      censos_vars[i]))
      } else{
        selects = c(selects, sprintf( "COALESCE(c.%1$s,0)::int AS %1$s", 
                                      censos_vars[i]))
      }
    } else{
      if (censos_vars[i] %in% censo_rural_cols){
        selects = c(selects, sprintf( "COALESCE(r.%1$s,0)::int AS %1$s", 
                                      censos_vars[i]))
      }
    } #  end else
  } # end loop
  selects = paste(selects, collapse = ', ')
  
  query_drop = c("DROP TABLE IF EXISTS grids_250.censos")
  query = sprintf("CREATE TABLE grids_250.censos AS (
                  SELECT cell_id, year, %s
                  FROM grids_250.censos_urbanos as c 
                  JOIN grids_250.censos_rurales as r 
                  USING (cell_id, year))", selects)
  
  con = Connect2PosgreSQL(config)
  dbSendQuery(con, query_drop)
  dbSendQuery(con, query)
  dbDisconnect(con)
  
}
#--------------------------------------------------
##Read config file
config = yaml.load_file("../../config.yaml")

# Create collapse census
CollapseCensos(config)