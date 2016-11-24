library(sp)
library(rgdal)


#_____________________________________________________________________________________
#proyectar la información del ITER y crear un shape correspondiente a la Zona Metropolitana
#______________________________________________________________________________________

#__________________________________________________________
#Para 2000
#_______________________________________________________

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Censos/ITER 2000/48")

#Si la ciudad pertenece a más de un Estado:
iter00_1<-read.table("ITER_00_1.csv",header=T,sep=",",na.string=c("*","<NA>","N/D"))
iter00_2<-read.table("ITER_00_2.csv",header=T,sep=",",na.string=c("*","<NA>","N/D"))
iter00_3<-read.table("ITER_00_3.csv",header=T,sep=",",na.string=c("*","<NA>","N/D"))
iter00_4<-read.table("ITER_00_4.csv",header=T,sep=",",na.string=c("*","<NA>","N/D"))
iter00<-rbind(iter00_1,iter00_2)

#Si la ciudad pertenece a solo un Estado:
iter00<-read.table("ITER_00.csv",header=T,sep=",",na.string=c("*","<NA>","N/D"))
names(iter00)

# VAriables de latitud y Longitud y las asignas para proyectarlo
coordinates(iter00)<-c("LONGITUD","LATITUD")
summary(coordinates(iter00))
proj4string(iter00)<-CRS("+proj=longlat +datum=WGS84")
plot(iter00, pch=16)
names(iter00)
iter00$CVE<-iter00$CLAVE
class(iter00)

#______________________________________________________
# Para 2010
#_____________________________________________________
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Censos/ITER 2010/31")

#Si la ciudad pertenece a más de un Estado:
iter10_1<-read.table("ITER_10_1.csv",header=T,sep=",",na.string="*")
iter10_2<-read.table("ITER_10_2.csv",header=T,sep=",",na.string="*")
iter10_3<-read.table("ITER_10_3.csv",header=T,sep=",",na.string="*")
iter10_4<-read.table("ITER_10_4.csv",header=T,sep=",",na.string="*")
iter10<-rbind(iter10_1,iter10_2)

#Si la ciudad pertenece a solo un Estado:
iter10<-read.table("ITER_10.csv",header=T,sep=",",na.string="*")


names(iter10)
summary(iter10)




# VAriables de latitud y Longitud y las asignas para proyectarlo
coordinates(iter10)<-c("LONGITUD","LATITUD")
summary(coordinates(iter10))
iter10$CVE<-iter10$CLAVEproj4string(iter10)<-CRS("+proj=longlat +datum=WGS84")


plot(iter10, pch=16,col="darkblue")
plot(iter00,pch=16,col="red",add=T)

#Leer AGEB para transformar el shape de localidades a la misma proyección que el AGEB
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/31")
sp10<-readOGR(".",layer="AGEBS2010var_prj")
projGeos<-CRS(proj4string(sp10))
iter00_2<-spTransform(iter00,projGeos)
iter10_2<-spTransform(iter10,projGeos)


#Corta el shape de localidades al área del grid
library(maptools)
library(raster)
library(rgeos)

#Leer grid
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/31/1. Grids")
grid05<-readOGR(".",layer="grid500")
proj4string(grid05)
proj4string(iter00_2)


#Corta al área del grid ylo gráfica
iterZM00<-crop(iter00_2,extent(bbox(grid05)[1,1],bbox(grid05)[1,2],bbox(grid05)[2,1],
                                                bbox(grid05)[2,2]))
plot(iterZM00,col="blue")

iterZM10<-crop(iter10_2,extent(bbox(grid05)[1,1],bbox(grid05)[1,2],bbox(grid05)[2,1],
                               bbox(grid05)[2,2]))
plot(iterZM10,col="red",add=T)

#Guarda
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/ITER shape/31")
writeOGR(iterZM00,".","ZM_ITER2000","ESRI Shapefile")
#writeOGR(iter05_2,".","ZM_ITER2005","ESRI Shapefile")
writeOGR(iterZM10,".","ZM_ITER2010","ESRI Shapefile")

