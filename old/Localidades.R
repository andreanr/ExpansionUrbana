library(rgdal)
library(sp)
library(rgeos)
library(maptools)
library(gpclib)
library(PBSmapping)

# ___________________________________________________________________________________
# Corregir localidades rurales para asignar las coordenadas de 2010 a una misma localidad
#____________________________________________________________________________________


#Leer los shapes de localidades
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/ITER shape/31")
loc00<-readOGR(dsn=".",layer="ZM_ITER2000")
#loc05<-readOGR(dsn=".",layer="ZM_ITER2005")
loc10<-readOGR(dsn=".",layer="ZM_ITER2010")

#Crear variable de CLAVE: CVE
loc00$CVE<-as.character(loc00$CLAVE)
head(loc00$CVE)
loc10$CVE<-as.character(loc10$CLAVE)
head(loc10$CVE)
names(loc00)
names(loc10)
claves<-rbind(loc00[,193],loc10[,198])

#Crear dataframe de distancias de una misma localidad la distancia entre 2010 y 2000
dist<-as.data.frame(unique(claves$CVE))
dist$p0010<-rep(NA,nrow(dist))
dist$a2000<-rep(NA,nrow(dist))
dist$a2010<-rep(NA,nrow(dist))
names(dist)[1]<-c("CVE")
names(dist)

#Crea el dataframe de distancias
for(i in 1:nrow(dist)){
  a00<-which(loc00$CVE==dist$CVE[i])
  a10<-which(loc10$CVE==dist$CVE[i])
  dist$a2000[i]<-as.numeric(length(a00)>0)
  dist$a2010[i]<-as.numeric(length(a10)>0)
  if(length(a00)>0 & length(a10)>0){
    dist$p0010[i]<-dist(rbind(coordinates(loc00[a00,]),coordinates(loc10[a10,])))
  }
}
summary(dist)

q<-c(dist$p0010)
q2<-q[q>0 &!is.na(q)]
summary(q2)


solo00<-dist$CVE[which(dist$a2000==1  & dist$a2010==0)]
length(solo00)
solo10<-dist$CVE[which(dist$a2000==0 & dist$a2010==1)]
length(solo10)



#Acomodo coordenadas a las localidades de 2000 y se le asignan las de 2010 (X,Y)
loc00$X<-rep(NA,nrow(loc00))
loc00$Y<-rep(NA,nrow(loc00))
for(i in 1:nrow(dist)){
  a00<-which(loc00$CVE==dist$CVE[i])
  a10<-which(loc10$CVE==dist$CVE[i])
if(dist$a2000[i]==1){
  if(dist$a2010[i]==1){
    loc00$X[a00]<-coordinates(loc10[a10,])[,1]
    loc00$Y[a00]<-coordinates(loc10[a10,])[,2]
  }
    else{
      loc00$X[a00]<-coordinates(loc00[a00,])[,1]
      loc00$Y[a00]<-coordinates(loc00[a00,])[,2]
    }
}
loc00_1<-as(loc00,"data.frame")
names(loc00_1)
loc10_1<-as(loc10,"data.frame")


#Variables a utilizar en el modelo
names(loc00_1)
var00<-c(8,15,23,22,24,26,27,37,38,39,40,48,49,52,60,69,71,86,87,94,95,97,98,102,104,105,103,106,107,108,109,110,116,89,90,125,128,131,194:197)-1
loc00_2<-loc00_1[,var00]
names(loc00_2)

names(loc10_1)
var10<-c(8,23,55,56,59,105,108,111,114,120,129,132,141,144,146,157,163:168,171,172,174,175,177,180:188,199:201)-1
loc10_2<-loc10_1[,var10]
names(loc10_2)

#Le asigno las nuevas coordenadas a las localidades de 2000
coordinates(loc00_2)<-~X+Y
coordinates(loc10_2)<-coordinates(loc10)
proj4string(loc00_2)<-proj4string(loc10)
proj4string(loc10_2)<-proj4string(loc10)
loc00_3<-spTransform(loc00_2,CRS(proj4string(loc10)))
loc10_3<-spTransform(loc10_2,CRS(proj4string(loc10)))


plot(loc00_3,col="magenta")
plot(loc10_3,col="blue",add=T)

#Guardo los shapes
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/ITER shape/31")
writeOGR(loc00_3,".","ITER2000_cor_var","ESRI Shapefile") 
#writeOGR(loc05_4,".","ITER2005_cor_var","ESRI Shapefile") 
writeOGR(loc10_3,".","ITER2010_cor_var","ESRI Shapefile") 

