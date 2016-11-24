rm(list=ls(all=T))
gc(reset=T)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/ITER shape/56")
iter00<-readOGR(dsn=".",layer="ITER2000_cor_var")
iter10<-readOGR(dsn=".",layer="ITER2010_cor_var")

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/56/9. Grid FINAL")
grid10<-readOGR(dsn=".",layer="grid500_10FINAL")
grid00<-readOGR(dsn=".",layer="grid500_00FINAL")

proj4string(iter00)
proj4string(grid00)


grid10$locrur<-rep(NA,length(grid10))
grid00$locrur<-rep(NA,length(grid00))


for(i in 1:length(grid00)){
  grid00$locrur[i]<-gDistance(grid00[i,],iter00)
}
for(i in 1:length(grid10)){
  grid10$locrur[i]<-gDistance(grid10[i,],iter10)
}

names(grid10)
spplot(grid10[,55])


#Distancia ANP
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/56/Uso de Suelo")
ANPM<-readOGR(dsn=".",layer="ANP_M")
ANPE<-readOGR(dsn=".",layer="ANP_E")

grid10$ANPM<-rep(NA,length(grid10))
grid00$ANPM<-rep(NA,length(grid00))
grid10$ANPE<-rep(NA,length(grid10))
grid00$ANPE<-rep(NA,length(grid00))

for(i in 1:length(grid10)){
  grid10$ANPM[i]<-gDistance(grid10[i,],ANPM)
  grid10$ANPE[i]<-gDistance(grid10[i,],ANPE)
}

grid10$ANPM[grid10$ANPM==0]<-999
grid10$ANPM[grid10$ANPM!=999]<-0
grid10$ANPE[grid10$ANPE==0]<-999
grid10$ANPE[grid10$ANPE!=999]<-0

grid00$ANPM<-grid10$ANPM
grid00$ANPE<-grid10$ANPE

names(grid10)
spplot(grid10[,56])

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/56/9.1 Grid FINAL 2")
writeOGR(grid10,".","grid500_10FINAL","ESRI Shapefile") 
writeOGR(grid00,".","grid500_00FINAL","ESRI Shapefile") 


