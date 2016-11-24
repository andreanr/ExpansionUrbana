library(raster)
library(rgdal)
library(sp)
library(spatialprobit)
library(MASS)
library(spatstat)
library(SparseM)
library(RColorBrewer)
library(rpart)
library(maptree)
library(xtable)
library(randomForest)
library(mlbench)
library(gbm)
library(adabag)
library(glmnet)
library(ROCR)

#______________________________________________
# Corrección de Grids para correr los modelos
#____________________________________________

rm(list=ls(all=T))
gc(reset=T)

#Leo grids
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/35/9.1 Grid FINAL 2")
#Leer las bases espaciales finales
grid10<-readOGR(dsn=".",layer="grid500_10FINAL")
grid00<-readOGR(dsn=".",layer="grid500_00FINAL")

names(grid10)
names(grid00)


#Cambio el nombre de variables dle grid 2000 para que coincidan con las de 2010
names(grid00)<-c("ID","POBTOT","P_15YMAS","PSINDER","PDER_IMSS","P8A14AN","Z64",
                 "P15YM_SE","P15SEC_IN","GRAPROES", "PROM_HNV","PEA","PDESOCUP","TVIVHAB",
                 "VIVPAR_HAB","Z121","Z123","Z126","VPH_1CUART","VPH_1DOR","Z133",
                 "Z134","VPH_EXCSA","VPH_DRENAJ","Z137","VPH_NODREN","VPH_C_ELEC","VPH_AGUADV",
                 "Z141","Z143","Z144","Z145","VPH_C_SERV","Z147","VPH_SNBIEN",
                 "PROM_OCUP","PRO_OCUP_C","TOT_HOG","P15YM_AN","area","ZU_75","ZU_60",
                 "ZU_50","ZU_40","ZU_30","ZU_25","lat","lon","slp_mean",
                 "slp_med","slp_max","DistCar","Centro1","DENUEg","DENUEm","NUM_AGRUP","DistAgeb",
                 "locrur")
#,"ANPM","ANPE")
                 
names(grid00)

#Eligo unas variables
e00<-c(2,4,8,14,19,20,23,24,27,28,33,35,36,37,39,41:48,51:58)
e10<-c(2,15,9,18,27,26,32,33,28,30,35,36,23,24,8,38:45,48:55)
grid00_1<-grid00[,e00]
grid10_1<-grid10[,e10]


#Poner ceros en las variables del censo
grid00_1$PSINDER[is.na(grid00_1$PSINDER)]<-0
grid10_1$PSINDER[is.na(grid10_1$PSINDER)]<-0

grid00_1$P15YM_SE[is.na(grid00_1$P15YM_SE)]<-0
grid10_1$P15YM_SE[is.na(grid10_1$P15YM_SE)]<-0

grid00_1$VPH_1CUART[is.na(grid00_1$VPH_1CUART)]<-0
grid10_1$VPH_1CUART[is.na(grid10_1$VPH_1CUART)]<-0

grid00_1$VPH_1DOR[is.na(grid00_1$VPH_1DOR)]<-0
grid10_1$VPH_1DOR[is.na(grid10_1$VPH_1DOR)]<-0

grid00_1$VPH_EXCSA[is.na(grid00_1$VPH_EXCSA)]<-0
grid10_1$VPH_EXCSA[is.na(grid10_1$VPH_EXCSA)]<-0

grid00_1$VPH_DRENAJ[is.na(grid00_1$VPH_DRENAJ)]<-0
grid10_1$VPH_DRENAJ[is.na(grid10_1$VPH_DRENAJ)]<-0

grid00_1$VPH_C_ELEC[is.na(grid00_1$VPH_C_ELEC)]<-0
grid10_1$VPH_C_ELEC[is.na(grid10_1$VPH_C_ELEC)]<-0

grid00_1$VPH_AGUADV[is.na(grid00_1$VPH_AGUADV)]<-0
grid10_1$VPH_AGUADV[is.na(grid10_1$VPH_AGUADV)]<-0

grid00_1$VPH_C_SERV[is.na(grid00_1$VPH_C_SERV)]<-0
grid10_1$VPH_C_SERV[is.na(grid10_1$VPH_C_SERV)]<-0

grid00_1$VPH_SNBIEN[is.na(grid00_1$VPH_SNBIEN)]<-0
grid10_1$VPH_SNBIEN[is.na(grid10_1$VPH_SNBIEN)]<-0

grid00_1$PROM_OCUP[is.na(grid00_1$PROM_OCUP)]<-0
grid10_1$PROM_OCUP[is.na(grid10_1$PROM_OCUP)]<-0

grid00_1$PRO_OCUP_C[is.na(grid00_1$PRO_OCUP_C)]<-0
grid10_1$PRO_OCUP_C[is.na(grid10_1$PRO_OCUP_C)]<-0

grid00_1$P15YM_AN[is.na(grid00_1$P15YM_AN)]<-0
grid10_1$P15YM_AN[is.na(grid10_1$P15YM_AN)]<-0

grid00_1$NUM_AGRUP<-factor(grid00_1$NUM_AGRUP)
grid10_1$NUM_AGRUP<-factor(grid10_1$NUM_AGRUP)


#Convierto mi grid en tabla
dat00<-as.data.frame(grid00_1)
dat10<-as.data.frame(grid10_1)
names(dat00)
names(dat10)

#Eligo unas pocas variables
var<-c(1:5,11:13,15,24:28,29,20)
dat00_1<-dat00[,var]
var<-c(1:5,11:13,15,24:28,29,20)
dat10_1<-dat10[,var]
names(dat10_1)
names(dat00_1)


#Corregir la ZU_30 para que coincidan los dos años
pro<-as.data.frame(as.numeric(dat10_1$ZU_30)-as.numeric(dat00_1$ZU_30))
summary(pro)
#Correcion 
dat10_1$ZU_30[which(pro<0)]<-1
pro<-as.data.frame(as.numeric(dat10_1$ZU_30)-as.numeric(dat00_1$ZU_30))
summary(pro)

#Le asigna al grid la variable Zu_30c que es la correción de ZU_30
grid00_1$ZU_30c<-dat00_1$ZU_30
grid10_1$ZU_30c<-dat10_1$ZU_30

names(grid00_1)
names(grid10_1)

#LE asigno al grid de 2000, la variable de ZU_30c de 2010
grid00_1$Pred10<-grid10_1$ZU_30c

#Guardar grids
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/35/9.1 Grid FINAL 2")
writeOGR(grid00_1,".","grid500_00FINALv","ESRI Shapefile")
#writeOGR(grid05_1,".","grid500_05FINALv","ESRI Shapefile")
writeOGR(grid10_1,".","grid500_10FINALv","ESRI Shapefile")

