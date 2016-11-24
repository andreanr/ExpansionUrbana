library(rgdal)
library(sp)
library(rgeos)

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/13/Proyeccion2020")
ten1<-readOGR(dsn=".",layer="tendencia1")
AreaAG<-(gArea(ten1,byid=T))/1000000
AreaAG

