#Agregar Uso de Suelo
rm(list=ls(all=T))
gc(reset=T)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/39/Uso de Suelo")
serie<-readOGR(dsn=".",layer="s3_agrup_prj")

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/39/7. Grid Denue")
grid<-readOGR(dsn=".",layer="grid500_00DEMcarCD")


proj4string(grid)
proj4string(serie)


#s_2<-spTransform(serie,CRS(proj4string(grid)))
#Cambiar el 20
names(serie)
s_3<-serie[,15]
names(s_3)

#Interseccion
int<-gIntersection(grid,s_3,byid=T)
plot(int)

summary(int)
nombres<-names(int)
head(nombres)

separar<-(strsplit(nombres," "))
separar<-as.data.frame(t(as.data.frame((separar))))
row.names(separar)<-c(1:nrow(separar))
names(separar)<-c("grid","Serie")

matriz<-as.data.frame(matrix(nrow=length(int),ncol=1))
names(matriz)<-names(s_3)
row.names(matriz)<-row.names(int)
spp <-SpatialPolygonsDataFrame(int,data=matriz)
spp$area<-(sapply(slot(spp,"polygons"),slot,"area"))
spp$prop<-rep(NA,length(spp))
spp$grid<-separar[,1]
spp$Serie<-separar[,2]
summary(spp)
plot(spp)
names(grid)

head(row.names(grid))
head(row.names(s_3))

plot(s_3[row.names(s_3)==spp$Serie[1],],add=T,col="red")
plot(grid[row.names(grid)==spp$grid[1],])

#Cambiar
areagrid<-500*500

for(i in 1:length(spp)){
  spp$prop[i]<-spp$area[i]/areagrid
}
summary(spp)

if((988-1)%in% spp$grid){
  sos<-c(1)
}else{
  sos<-c(0)
}

sos
cant<-which(spp$grid==(988-1))
cant
ese<-which(spp$prop[cant]==max(spp$prop[cant]))
spp$prop[cant]
cant[ese]
s_3$NUM_AGRUP[row.names(s_3)==spp$Serie[cant[ese]]]
which(row.names(s_3)==spp$Serie[cant[ese]])
summary(s_3$NUM_AGRUP)

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
names(grid)
summary(grid[,56])
#Cambiar
#spplot(grid[,55])


setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/39/8. Grid USV")
#Cambiar
writeOGR(grid,".","grid500_00DEMcarCDus","ESRI Shapefile") 
#writeOGR(grid05,".","grid1500_05demcarUS","ESRI Shapefile") 
  #writeOGR(grid00,".","grid1500_00demcarUS","ESRI Shapefile") 
  
  #------------------------------------------------------------------------
#Distancia a AGEB
#------------------------------------------------------------------------
rm(list=ls(all=T))
gc(reset=T)
library(geosphere)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/39")
ageb00<-readOGR(dsn=".",layer="AGEBS2000var_prj")
#ageb05<-readOGR(dsn=".",layer="AGEBS2005var")
ageb10<-readOGR(dsn=".",layer="AGEBS2010var_prj")
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/39/8. Grid USV")
gridc10<-readOGR(dsn=".",layer="grid500_10DEMcarCDus")
#gridc05<-readOGR(dsn=".",layer="grid500_05DEMcarCDus")
gridc00<-readOGR(dsn=".",layer="grid500_00DEMcarCDus")
proj4string(ageb00)
proj4string(gridc00)
gridc10$DistAgeb<-rep(NA,length(gridc10))
#gridc05$DistAgeb<-rep(NA,length(gridc05))
gridc00$DistAgeb<-rep(NA,length(gridc00))

for(i in 1:length(gridc10)){
  gridc10$DistAgeb[i]<-gDistance(gridc10[i,],ageb10)
}
#for(i in 1:length(gridc05)){
# gridc05$DistAgeb[i]<-gDistance(gridc05[i,],ageb05)
#}
for(i in 1:length(gridc00)){
  gridc00$DistAgeb[i]<-gDistance(gridc00[i,],ageb00)
}



setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/39/9. Grid FINAL")
writeOGR(gridc10,".","grid500_10FINAL","ESRI Shapefile") 
#writeOGR(gridc05,".","grid500_05FINAL","ESRI Shapefile") 
writeOGR(gridc00,".","grid500_00FINAL","ESRI Shapefile") 
names(gridc10)
