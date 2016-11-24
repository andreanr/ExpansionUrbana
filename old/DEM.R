gc(reset=T)
library(raster)
library(rgdal)
library(sp)
library(rgeos)
library(maptools)
library(gpclib)
library(PBSmapping)
#Raster


#__________________________________________________________________
# Pendiente 
#__________________________________________________________________

library(tiff)
library(raster)

#Leer raster pendiente
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Elevacion Digital/Slope2")
slope<-raster("DEM_test14.tif")
#revisar proyección
proj4string(slope)

#Leo grids
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/3. Grid Loc")
grid10<-readOGR(dsn=".",layer="grid500_censo2010")
grid00<-readOGR(dsn=".",layer="grid500_censo2000")

#Le grid 500 (cuadrado)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/1. Grids")
grid<-readOGR(dsn=".",layer="grid500")
#Revisar proyección
proj4string(grid)


#trasformo el shape Grid a la proyección de la pendiente
gridtr<-spTransform(grid,CRS(proj4string(slope)))

#ya que estan en la misma proyección, corto el raster de pendiente al área del grid
cortar<-crop(slope,gridtr)
#transformo el pedazo cortado de pendiente a la proyección de UTM
cortar2<-projectRaster(cortar, crs=CRS(proj4string(grid10)))


#Extrae la información de los pixeles del raster al grid de acuerdo a la funcion: media, mediana, máximo
slp_me<- extract(cortar2, grid10, fun=mean)
slp_md<-extract(cortar2,grid10,fun=median)
slp_max<-extract(cortar2,grid10,fun=max)
#Agrego a los grids 2000 y 2010 las variables de pendiente media, mediana y máxima
grid10$slp_mean<-slp_me[,1]
grid10$slp_med<-slp_md[,1]
grid10$slp_max<-slp_max[,1]
grid00$slp_mean<-slp_me[,1]
grid00$slp_med<-slp_md[,1]
grid00$slp_max<-slp_max[,1]

#Guardo los grids
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/4. Grid Slope")
writeOGR(grid10,".","grid500_10censoDEM","ESRI Shapefile") 
writeOGR(grid00,".","grid500_00censoDEM","ESRI Shapefile") 

#__________________________________________________________________________________________________
#Distancia a Carreteras y Calles principales
#__________________________________________________________________________________________________

library(geosphere)
rm(list=ls(all=T))
gc(reset=T)

#Leo shape de carreteras (Cambio shape de acuerdo a la zona de UTM)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Carreteras")
#Cambiar Número a la zona UTM de la zona metropolitana
car<-readOGR(dsn=".",layer="road_zona14")

#Leo shapes
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/4. Grid Slope")
gridc10<-readOGR(dsn=".",layer="grid500_10censoDEM")
gridc00<-readOGR(dsn=".",layer="grid500_00censoDEM")
#REsivar que las proyecciones coincidan
proj4string(car)
proj4string(gridc10)


#Agrego variables al grid de Distancia a Carreteras (primero en NA)
gridc10$DistCar<-rep(NA,length(gridc10))
gridc00$DistCar<-rep(NA,length(gridc00))

#Calculas la distancia a carreteras principales y le asigno las distancias a la nueva variable
#Distancia mínima del centroide del grid a la línea de la carretera más cercana
for(i in 1:length(gridc10)){
  gridc10$DistCar[i]<-gDistance(gridc10[i,],car)
}

#Si existiera shape 2000
# Leer shape
# carr00<-readOGR(dsn=".",layer="Carreteras2000")
# Revisar que las proyecciones sean las mismas, sino transformar
# for(i in 1:length(gridc00)){
# gridc00$DistCar[i]<-gDistance(gridc00[i,],car)
#}

# Le asigno a 2000 la misma distancia que a 2010, dado que no tengo otro shape de carreteras para 2000
gridc00$DistCar<-gridc10$DistCar

#Resumen y mapa
summary(gridc10[,49])
spplot(gridc10[,49])

#Gaurdo Shapes
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/5. Grid Car")
writeOGR(gridc10,".","grid500_10demcar","ESRI Shapefile") 
writeOGR(gridc00,".","grid500_00demcar","ESRI Shapefile") 


#___________________________________________________________________________________________
#Distancia a Centro Urbano
#__________________________________________________________________________________________

rm(list=ls(all=T))
gc(reset=T)

#Leo Buffer de 500 o 1000 metros al centro urbano
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53")
centro<-readOGR(dsn=".",layer="bufferCentro500")

# Leo grid
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/5. Grid Car")
gridc10<-readOGR(dsn=".",layer="grid500_10demcar")
gridc00<-readOGR(dsn=".",layer="grid500_00demcar")
#Revisar proyecciones
proj4string(centro)
proj4string(gridc10)

#Asignar nuevas variables
gridc10$Centro1<-rep(NA,length(gridc10))
gridc00$Centro1<-rep(NA,length(gridc00))

#Calculo la distancia mínima del centroide del grid al buffer del centro urbano y se lo asigno a la nueva variable
for(i in 1:length(gridc10)){
  gridc10$Centro1[i]<-gDistance(gridc10[i,],centro)
}
for(i in 1:length(gridc00)){
  gridc00$Centro1[i]<-gDistance(gridc00[i,],centro)
}


#Guardo shapes
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/6. Grid Centro")
writeOGR(gridc10,".","grid500_10DEMcarC","ESRI Shapefile") 
#writeOGR(gridc05,".","grid500_05DEMcarC","ESRI Shapefile") 
writeOGR(gridc00,".","grid500_00DEMcarC","ESRI Shapefile") 



#______________________________________________________________________
# 
# Esto no siempre se corre
#______________________________________________________________________
#  Arreglar DENUE de los últimos Estados
#______________________________________________________________________

#Leo CSV del DENUE
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/DENUE")
DEN<-read.csv("denue_Nacional_1_29.csv")
coordinates(DEN)<-c("Longitud","Latitud")
proj4string(DEN)<-CRS("+proj=longlat +datum=WGS84")
writeOGR(DEN,".","denue_29","ESRI Shapefile") 


#_______________________________________________________________________________
#Distancia a Unidades Económicas DENUE 
# Grandes- más de 251 personas
# Medianas- de 51 a 250 personas
#______________________________________________________________________________
rm(list=ls(all=T))
gc(reset=T)

#Leer los shapes de DENUE 251 y más personas y de 51 a 250 personas (ya proyectado a UTM)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/DENUE")
DENUEg<-readOGR(dsn=".",layer="DENUE_251_ZM")
DENUEm<-readOGR(dsn=".",layer="DENUE_51-250_ZM")

#Leer los grids 
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/6. Grid Centro")
gridc10<-readOGR(dsn=".",layer="grid500_10DEMcarC")
#gridc05<-readOGR(dsn=".",layer="grid500_05DEMcarC")
gridc00<-readOGR(dsn=".",layer="grid500_00DEMcarC")

#Revisar que las proyecciones coincidan
proj4string(DENUEg)
proj4string(gridc00)

# Creo las variables DENUEg (251 y más personas) y DENUEm (51 a 250 personas)
gridc10$DENUEg<-rep(NA,length(gridc10))
gridc00$DENUEg<-rep(NA,length(gridc00))
gridc10$DENUEm<-rep(NA,length(gridc10))
gridc00$DENUEm<-rep(NA,length(gridc00))


# Calcula la distancia
for(i in 1:length(gridc10)){
  gridc10$DENUEg[i]<-gDistance(gridc10[i,],DENUEg)
  gridc10$DENUEm[i]<-gDistance(gridc10[i,],DENUEm)
}
gridc00$DENUEg<-gridc10$DENUEg
gridc00$DENUEm<-gridc10$DENUEm

#Grafica mapa
#spplot(gridc10[,51])


# Guardar
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/7. Grid Denue")
writeOGR(gridc10,".","grid500_10DEMcarCD","ESRI Shapefile") 
writeOGR(gridc00,".","grid500_00DEMcarCD","ESRI Shapefile") 




#_____________________________________________________________________
#Agregar Uso de Suelo
#____________________________________________________________________
# SErie Uso de Suelo III con grid 2000
#__________________________________________________________________

rm(list=ls(all=T))
gc(reset=T)
#Leo shape agrupado y proyectado de la Serie 3 de USV del área de influencia de la zona metropolitana
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/Uso de Suelo")
serie<-readOGR(dsn=".",layer="s3_agrup_prj")

#Lee grid de 2000
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/7. Grid Denue")
grid<-readOGR(dsn=".",layer="grid500_00DEMcarCD")

#Revisar que coincidan proyecciones
proj4string(grid)
proj4string(serie)

names(serie)
#cambiar el número de columna a la columna de NUM_AGRUP
s_3<-serie[,15]
names(s_3)

#Interseccion entre la capa de uso de suelo y el grid
int<-gIntersection(grid,s_3,byid=T)

#Separar variable de resultados de la interseccion
separar<-(strsplit(nombres," "))
separar<-as.data.frame(t(as.data.frame((separar))))
row.names(separar)<-c(1:nrow(separar))
names(separar)<-c("grid","Serie")

#Crear matriz y un spatialdataframe de los resultados de la interseccion
matriz<-as.data.frame(matrix(nrow=length(int),ncol=1))
names(matriz)<-names(s_3)
row.names(matriz)<-row.names(int)
spp <-SpatialPolygonsDataFrame(int,data=matriz)
spp$area<-(sapply(slot(spp,"polygons"),slot,"area"))
spp$prop<-rep(NA,length(spp))
spp$grid<-separar[,1]
spp$Serie<-separar[,2]


#Cambiar de acuerdo al tamaño del grid
areagrid<-500*500

# Le asigna la proporción de la intersección correspondiente al grid
for(i in 1:length(spp)){
    spp$prop[i]<-spp$area[i]/areagrid
}
summary(spp)

#Le asigno a cada cuadricula del grid el NUM_AGRUP (uso de suelo agrupado) que tenga la proporción de área mayor dentro del grid
gridserie<-rep(1,length(grid))
for(i in 1:length(grid)){
  if((i-1)%in% spp$grid){
    cant<-which(spp$grid==(i-1))
    ese<-which(spp$prop[cant]==max(spp$prop[cant]))
    gridserie[i]<-s_3$NUM_AGRUP[row.names(s_3)==spp$Serie[cant[ese]]]
  }else{
    gridserie[i]<-0
  }
}
grid$NUM_AGRUP<-gridserie

#Revisar y resumen
names(grid)
summary(grid[,56])


#Guardo
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/8. Grid USV")
#Cambiar
writeOGR(grid,".","grid500_00DEMcarCDus","ESRI Shapefile") 


#_________________________________________________
# Serie Uso de Suelo V con grid de 2010
#_______________________________________________
rm(list=ls(all=T))
gc(reset=T)
#Leo shape agrupado y proyectado de la Serie 3 de USV del área de influencia de la zona metropolitana
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/Uso de Suelo")
serie<-readOGR(dsn=".",layer="s5_agrup_prj")

#Lee grid de 2000
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/7. Grid Denue")
grid<-readOGR(dsn=".",layer="grid500_10DEMcarCD")

#Revisar que coincidan proyecciones
proj4string(grid)
proj4string(serie)

names(serie)
#cambiar el número de columna a la columna de NUM_AGRUP
s_3<-serie[,4]
names(s_3)

#Interseccion entre la capa de uso de suelo y el grid
int<-gIntersection(grid,s_3,byid=T)

#Separar variable de resultados de la interseccion
separar<-(strsplit(nombres," "))
separar<-as.data.frame(t(as.data.frame((separar))))
row.names(separar)<-c(1:nrow(separar))
names(separar)<-c("grid","Serie")

#Crear matriz y un spatialdataframe de los resultados de la interseccion
matriz<-as.data.frame(matrix(nrow=length(int),ncol=1))
names(matriz)<-names(s_3)
row.names(matriz)<-row.names(int)
spp <-SpatialPolygonsDataFrame(int,data=matriz)
spp$area<-(sapply(slot(spp,"polygons"),slot,"area"))
spp$prop<-rep(NA,length(spp))
spp$grid<-separar[,1]
spp$Serie<-separar[,2]


#Cambiar de acuerdo al tamaño del grid
areagrid<-500*500

# Le asigna la proporción de la intersección correspondiente al grid
for(i in 1:length(spp)){
  spp$prop[i]<-spp$area[i]/areagrid
}
summary(spp)

#Le asigno a cada cuadricula del grid el NUM_AGRUP (uso de suelo agrupado) que tenga la proporción de área mayor dentro del grid
gridserie<-rep(1,length(grid))
for(i in 1:length(grid)){
  if((i-1)%in% spp$grid){
    cant<-which(spp$grid==(i-1))
    ese<-which(spp$prop[cant]==max(spp$prop[cant]))
    gridserie[i]<-s_3$NUM_AGRUP[row.names(s_3)==spp$Serie[cant[ese]]]
  }else{
    gridserie[i]<-0
  }
}
grid$NUM_AGRUP<-gridserie


#Guardo
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/8. Grid USV")
#Cambiar
writeOGR(grid,".","grid500_10DEMcarCDus","ESRI Shapefile") 

#_____________________________________________________________________________________
#Distancia a AGEB
#         Calcula la distancia mínima del centroide del grid a los Ageb urbanos
#____________________________________________________________________________________
rm(list=ls(all=T))
gc(reset=T)

#LEo los shapes de AGEb 2000 y 2010
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/01")
ageb00<-readOGR(dsn=".",layer="AGEBS2000var_prj")
ageb10<-readOGR(dsn=".",layer="AGEBS2010var_prj"
                
#Leo los grids 2000 y 2010
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/8. Grid USV")
gridc10<-readOGR(dsn=".",layer="grid500_10DEMcarCDus")
gridc00<-readOGR(dsn=".",layer="grid500_00DEMcarCDus")

#Reviso que coincidan proyecciones
proj4string(ageb00)
proj4string(gridc00)

# Declaro la variable DistAgeb en los grids
gridc10$DistAgeb<-rep(NA,length(gridc10))
gridc00$DistAgeb<-rep(NA,length(gridc00))

# Calculo la distancia del centroide del grid al ageb urbano más cercano para 2000 y para 2010
# Para 2010:
for(i in 1:length(gridc10)){
  gridc10$DistAgeb[i]<-gDistance(gridc10[i,],ageb10)
}
# Para 2000:
for(i in 1:length(gridc00)){
  gridc00$DistAgeb[i]<-gDistance(gridc00[i,],ageb00)
}


# Guardo mis grids
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/01/9. Grid FINAL")
writeOGR(gridc10,".","grid500_10FINAL","ESRI Shapefile") 
writeOGR(gridc00,".","grid500_00FINAL","ESRI Shapefile") 
names(gridc10)



#_____________________________________________________________________________________
# Distancia a Localidades Rurales
# __________________________________________________________________________________

rm(list=ls(all=T))
gc(reset=T)

#LEo mis shapes de localidades rurales
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/ITER shape/56")
iter00<-readOGR(dsn=".",layer="ITER2000_cor_var")
iter10<-readOGR(dsn=".",layer="ITER2010_cor_var")

#Leo mis shapes
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/56/9. Grid FINAL")
grid10<-readOGR(dsn=".",layer="grid500_10FINAL")
grid00<-readOGR(dsn=".",layer="grid500_00FINAL")

# Reviso que coincidan coordenadas
proj4string(iter00)
proj4string(grid00)

# Declaro mi variable locrur de distancia a localidades rurales
grid10$locrur<-rep(NA,length(grid10))
grid00$locrur<-rep(NA,length(grid00))

#Calculo la distancia del centroide del grid a la localidad rural más cercana
for(i in 1:length(grid00)){
  grid00$locrur[i]<-gDistance(grid00[i,],iter00)
}
for(i in 1:length(grid10)){
  grid10$locrur[i]<-gDistance(grid10[i,],iter10)
}

#Guardo mis shapes
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/56/9.1 Grid FINAL 2")
writeOGR(grid10,".","grid500_10FINAL","ESRI Shapefile") 
writeOGR(grid00,".","grid500_00FINAL","ESRI Shapefile")


#_______________________________________________________________________
# Distancia ANP
#_______________________________________________________________________
# Distancia a ANP's Estatales y Municipales

#Leer shape de ANP's
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Uso de Suelo") #cambiar
ANPM<-readOGR(dsn=".",layer="ANP_M") #Cambiar a shape ANP Municipal
ANPE<-readOGR(dsn=".",layer="ANP_E") #Cambiar a shape ANP Estatal

#Leer los Grids

# Se debe hacer una Intersección del grid con los dos shapes
# Si la intersección de los dos es vacía-> no seguir el proceso .... hacer con un if(!is.na(interseccion1) && !is.na(interseccion2)) (no es NA ninguna de las dos)
# Si solo intersecta una (Estatal o Municipal) hacer el sguiente proceso pero solo para ANPM o ANPE... un if para ver si intersecta una
# Si intersecta ambas seguir el proceso

#Declaro variables de ANP
grid10$ANPM<-rep(NA,length(grid10))
grid00$ANPM<-rep(NA,length(grid00))
grid10$ANPE<-rep(NA,length(grid10))
grid00$ANPE<-rep(NA,length(grid00))

#Calculo la Distancia a los ANP's
for(i in 1:length(grid10)){
  grid10$ANPM[i]<-gDistance(grid10[i,],ANPM)
  grid10$ANPE[i]<-gDistance(grid10[i,],ANPE)
}

# Si mi cuadricula cae dentro de una ANP-> su distancia será cero por lo que le asigno entonces el valor de 999
#   Si no cae dentro del ANP le asigno cero
grid10$ANPM[grid10$ANPM==0]<-999
grid10$ANPM[grid10$ANPM!=999]<-0
grid10$ANPE[grid10$ANPE==0]<-999
grid10$ANPE[grid10$ANPE!=999]<-0
grid00$ANPM<-grid10$ANPM
grid00$ANPE<-grid10$ANPE


#Guardo shape

