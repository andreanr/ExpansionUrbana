library(RPostgreSQL)

# Establish connection to PoststgreSQL using RPostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="tesis",host="host",port=5432,user="user")

library(raster)
