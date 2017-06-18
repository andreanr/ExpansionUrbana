# Import packages
require(yaml) 
require(sp)
require(RPostgreSQL)
require(postGIStools)
library(rgeos)
library(RColorBrewer)
library(Hmisc)

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

GetPoligonFromPostgis <- function (conn,
                                   from_object, 
                                   geom_column="geom",
                                   id_column='gid'){
  # Function to get a poligon from postgis table
  #
  # Args:
  #   conn: Postgres connection
  #   schema: Schema where the table is stored
  #   table: Table with the Geometry
  #   geom_column: Geometry column name
  #   id_column: id column name
  #
  # Returns:
  #   SpatialPolygonDataframe
  
  query <- "SELECT ST_AsText(%s) AS wkt_geometry , * FROM %s"
  query <- sprintf(query, geom_column, from_object)
  
  df.query <- dbGetQuery(conn, query)
  df.query$geom_column <- NULL
  
  row.names(df.query) = df.query$cell_id
  
  # Create spatial polygons
  rWKT <- function (var1 , var2 ) { return (readWKT ( var1 , var2) @polygons) }
  spl <- mapply( rWKT , df.query$wkt_geometry ,  df.query$cell_id )
  sp.temp <- SpatialPolygons( spl )
  
  # Create SpatialPolygonsDataFrame, drop WKT field from attributes
  sp.df <- SpatialPolygonsDataFrame(sp.temp, df.query[-1])
  
  return (sp.df)
}

## Análisis Exploratorio por feature
config = yaml.load_file("../config.yaml")

conn = Connect2PosgreSQL(config)
sp_2000 = GetPoligonFromPostgis(conn=conn, 
                      from_object = "features.features_hex_grid_250 
                              JOIN hex_grids_250.grid USING (cell_id)
                              JOIN preprocess.buffer_2010
                              ON st_intersects(cell, buffer_geom)
                              WHERE year='2010'",
                      geom_column="cell")

query_feature_columns = ("select column_name 
                      from information_schema.columns
                         where table_schema = 'features'
                       and table_name = 'features_hex_grid_1000'
                         and column_name not in ('cell_id', 'year')")
columns = get_postgis_query(conn, query_feature_columns)$column_name

dbDisconnect(conn)

colfunc <- colorRampPalette(c("#F0F2F0", "#2C3E50"))
for(i in 1:length(columns)){
  mypath <- file.path('../docs/img',paste(columns[i], '_hex_250', '_2000',".png", sep = ""))
  
  tmp = spplot(sp_2000, columns[i],
         main = paste(capitalize(strsplit(columns[i],'_')[[1]]), collapse = ' '),
         col.regions = colfunc(20),
         cuts = 9,
         col = "transparent")
  png(file=mypath)
  print(tmp)
  dev.off()
}






