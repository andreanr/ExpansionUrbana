library(rgdal)
library(sp)
library(devtools)
library(rgeos)
library(maptools)
install_git("git://github.com/gsk3/taRifx.geo.git")
library(taRifx.geo)

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/52")

A00<-readOGR(dsn=".",layer="AGEBS2000_52")
A05<-readOGR(dsn=".",layer="AGEBS2005_59")
A10<-readOGR(dsn=".",layer="AGEBS2010_52")

names(A10)
head(A05$CLAVE)
clav<-A00$CLVAGB
clav<-as.character(clav)
head(clav)
separar<-(strsplit(clav,"-"))
separar<-as.data.frame(t(as.data.frame((separar))))
pegar<-as.factor(paste(separar[,1],separar[,2], sep=""))
A00$CLAVE<-pegar
head(A00$CLAVE)



int<-intersect(A05$CLAVE,A00$CLAVE)
int2<-intersect(A10$CVEGEO,A00$CLAVE)
length(A00$CLAVE)
length(A05$CLAVE)

length(int)
length(int2)
dif<-setdiff(A00$CLAVE,int)
dif2<-setdiff(A00$CLAVE,int2)
names(A00)
extra<-A00[A00$CLAVE%in%dif,163]
extra2<-A00[A00$CLAVE%in%dif2,4]

names(extra)
names(extra2)

names(A05)
names(A10)
nuevo00<-A05[A05$CLAVE%in%int,1]
nuevo00_2<-A10[A10$CVEGEO%in%int2,2]

names(nuevo00_2)<-c("CLAVE")

plot(A10,col="green")
plot(A05,col="blue")
plot(nuevo00,col="red",add=T)
plot(extra,col="red",add=T)
plot(nuevo00_2,col="pink",add=T)
plot(extra2,col="pink",add=T)

union00<-rbind(nuevo00,extra,fix.duplicated.IDs=T)
plot(union00,col="red",add=T)
union00_2<-rbind(nuevo00_2,extra2,fix.duplicated.IDs=T)
plot(union00_2,col="pink",add=T)

writeOGR(union00_2,".","AGEBS2000_52c","ESRI Shapefile")
