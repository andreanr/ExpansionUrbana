library(rgdal)
library(sp)
library(rgeos)
library(maptools)
library(gpclib)
library(PBSmapping)


#__________________________________________________________________________________
# Unir la información de los AGEBS al grid creado
# Unir la información de las localidades rurales al grid creado
#__________________________________________________________________________________
gc(reset=T)
#.---------------------2010---------------------------
#Leo el shape del AGEB
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/53")
Ageb<-readOGR(dsn=".",layer="AGEBS2010var_prj")

#Leo el grid
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/1. Grids")
grid<-readOGR(dsn=".",layer="grid500_10")
#Checar que los dos tengan la misma proyección
proj4string(grid)
proj4string(Ageb)


#Creo una variable del Area en m2 para cada AGEB
AreaAG<-(gArea(Ageb,byid=T))
summary(AreaAG)
Ageb$area<-(sapply(slot(Ageb,"polygons"),slot,"area"))
all.equal(unname(AreaAG),Ageb$area)
summary(Ageb$area)
length(Ageb)
hist(Ageb$area)

#Interseccion del grid con los poligonos del AGEB
polygone1 <- gBuffer(grid, byid=TRUE, width=0)
polygone2 <- gBuffer(Ageb, byid=TRUE, width=0)
prueba <- gIntersection(polygone1, polygone2, byid=TRUE)
summary(prueba)

# Variable del intersect separar los campos del AGEB y del grid
nombres<-names(prueba)
separar<-(strsplit(nombres," "))
separar<-as.data.frame(t(as.data.frame((separar))))
row.names(separar)<-c(1:nrow(separar))
names(separar)<-c("grid","AGEB")


matriz<-as.data.frame(matrix(nrow=length(prueba),ncol=43))
#le asigno a las columnas de mi matriz el nombre de mis variables del censo 
names(matriz)<-names(Ageb)[1:43]
#nombre de mis renglones son el nombre de mis observaciones de los resultados de la intersección
row.names(matriz)<-row.names(prueba)
#Convierto mi resultado de intersección en shape con las variables del censo
spp <-SpatialPolygonsDataFrame(prueba,data=matriz)
# A cada observación de la intersección le calculo el área y lo agrego como variable
spp$area<-(sapply(slot(spp,"polygons"),slot,"area"))
# Creo una columna que es prop que es la proporción del AGEB
spp$prop<-rep(NA,length(spp))
# Le agregó la variable grid y AGEB para referenciar a qué grid y a qué AGEB corresponde esa intersección
spp$grid<-separar[,1]
spp$AGEBS<-separar[,2]
summary(spp)

names(spp)
names(Ageb)

#Construir las proporciones de Ageb en cada grid

for(i in 0:length(spp)){
  #Primero se calcula prop (proporción): área de la intersección/ área del AGEB
  spp$prop[i]<-spp$area[i]/Ageb$area[row.names(Ageb)==spp$AGEBS[i]]
  spp$CVEGEO[i]<-as.factor(Ageb$CVEGEO[row.names(Ageb)==spp$AGEBS[i]])
  spp$POBTOT[i]<-(Ageb$POBTOT[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$P_15YMAS[i]<-(Ageb$P_15YMAS[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$PROM_HNV[i]<-(Ageb$PROM_HNV[row.names(Ageb)==spp$AGEBS[i]]) #Promedio
  spp$PNACENT[i]<-(Ageb$PNACENT[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$PNACOE[i]<-(Ageb$PNACOE[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$P8A14AN[i]<-(Ageb$P8A14AN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$P15YM_AN[i]<-(Ageb$P15YM_AN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$P15YM_SE[i]<-(Ageb$P15YM_SE[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$P15PRI_IN[i]<-(Ageb$P15PRI_IN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$P15SEC_IN[i]<-(Ageb$P15SEC_IN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$GRAPROES[i]<-Ageb$GRAPROES[row.names(Ageb)==spp$AGEBS[i]] #Grado Escolaridad
  spp$PEA[i]<-(Ageb$PEA[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$PDESOCUP[i]<-(Ageb$PDESOCUP[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$PSINDER[i]<-(Ageb$PSINDER[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$PDER_IMSS[i]<-(Ageb$PDER_IMSS[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VIVTOT[i]<-(Ageb$VIVTOT[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$TVIVHAB[i]<-(Ageb$TVIVHAB[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$TVIVPAR[i]<-(Ageb$TVIVPAR[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VIVPAR_HAB[i]<-(Ageb$VIVPAR_HAB[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$TVIVPARHAB[i]<-(Ageb$TVIVPARHAB[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VIVPAR_DES[i]<-(Ageb$VIVPAR_DES[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$PROM_OCUP[i]<-Ageb$PROM_OCUP[row.names(Ageb)==spp$AGEBS[i]] #PRomedio
  spp$PRO_OCUP_C[i]<-Ageb$PRO_OCUP_C[row.names(Ageb)==spp$AGEBS[i]] #PRomedio
  spp$VPH_PISOTI[i]<-(Ageb$VPH_PISOTI[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_1DOR[i]<-(Ageb$VPH_1DOR[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_1CUART[i]<-(Ageb$VPH_1CUART[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_C_ELEC[i]<-(Ageb$VPH_C_ELEC[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_S_ELEC[i]<-(Ageb$VPH_S_ELEC[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_AGUADV[i]<-(Ageb$VPH_AGUADV[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_AGUAFV[i]<-(Ageb$VPH_AGUAFV[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_EXCSA[i]<-(Ageb$VPH_EXCSA[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_DRENAJ[i]<-(Ageb$VPH_DRENAJ[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_NODREN[i]<-(Ageb$VPH_NODREN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_C_SERV[i]<-(Ageb$VPH_C_SERV[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$VPH_SNBIEN[i]<-(Ageb$VPH_SNBIEN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
}

names(Ageb)
names(spp)


#Creo mis variables en el grid las del censo y las de ZU_i
grid$POBTOT<-rep(0,length(grid))
grid$P_15YMAS<-rep(0,length(grid))
grid$PROM_HNV<-rep(NA,length(grid))
grid$PNACENT<-rep(0,length(grid))
grid$PNACOE<-rep(NA,length(grid))
grid$PNACOE<-rep(NA,length(grid))
grid$P8A14AN<-rep(NA,length(grid))
grid$P15YM_AN<-rep(NA,length(grid))
grid$P15YM_SE<-rep(NA,length(grid))
grid$P15PRI_IN<-rep(NA,length(grid))
grid$P15SEC_IN<-rep(NA,length(grid))
grid$GRAPROES<-rep(NA,length(grid))
grid$PEA<-rep(NA,length(grid))
grid$PDESOCUP<-rep(NA,length(grid))
grid$PSINDER<-rep(NA,length(grid))
grid$PDER_IMSS<-rep(NA,length(grid))
grid$VIVTOT<-rep(0,length(grid))
grid$TVIVHAB<-rep(0,length(grid))
grid$TVIVPAR<-rep(0,length(grid))
grid$VIVPAR_HAB<-rep(0,length(grid))
grid$TVIVPARHAB<-rep(0,length(grid))
grid$VIVPAR_DES<-rep(0,length(grid))
grid$PROM_OCUP<-rep(NA,length(grid))
grid$PRO_OCUP_C<-rep(NA,length(grid))
grid$VPH_PISOTI<-rep(NA,length(grid))
grid$VPH_1DOR<-rep(NA,length(grid))
grid$VPH_1CUART<-rep(NA,length(grid))
grid$VPH_C_ELEC<-rep(NA,length(grid))
grid$VPH_S_ELEC<-rep(NA,length(grid))
grid$VPH_AGUADV<-rep(NA,length(grid))
grid$VPH_AGUAFV<-rep(NA,length(grid))
grid$VPH_EXCSA<-rep(NA,length(grid))
grid$VPH_DRENAJ<-rep(NA,length(grid))
grid$VPH_NODREN<-rep(NA,length(grid))
grid$VPH_C_SERV<-rep(NA,length(grid))
grid$VPH_SNBIEN<-rep(NA,length(grid))
grid$area<-rep(0,length(grid))

#Creo las variables ZU_i: si el i% o más de la mancha urbana de los AGEB cae dentro del grid ZU_i=1
grid$ZU_75<-rep(0,length(grid))
grid$ZU_60<-rep(0,length(grid))
grid$ZU_50<-rep(0,length(grid))
grid$ZU_40<-rep(0,length(grid))
grid$ZU_30<-rep(0,length(grid))
grid$ZU_25<-rep(0,length(grid))

#Esto asigna la información de la intersección al grid  
list<-unique(spp$grid)
for(i in list){
  len<-which(spp$grid==i)
  sumaPOBT<-c()
  meanPROM<-c()
  sumaPNT<-c()
  sumaPNOT<-c()
  suma14an<-c()
  suma15an<-c()
  suma15se<-c()
  sumaPri<-c()
  sumaSec<-c()
  meanGrE<-c()
  sumaPEA<-c()
  sumaDes<-c()
  sumaPSINDER<-c()
  sumaIMSS<-c()
  sumaVIVT<-c()
  sumaVTH<-c()
  sumaVTP<-c()
  sumaVPH<-c()
  sumaTVPH<-c()
  sumaVPD<-c()
  meanOCUP<-c()
  meanOCUPC<-c()
  sumaPT<-c()
  suma1DO<-c()
  suma1CTO<-c()
  sumaCElec<-c()
  sumaSElec<-c()
  sumaAGUADV<-c()
  sumaAGUAFV<-c()
  sumaEXCSA<-c()
  sumaDREN<-c()
  sumaNoDren<-c()
  sumaSERV<-c()
  sumaSNB<-c()
  sumaAREA<-c()
  for(j in 1:length(len)){
    sumaPOBT<-c(sumaPOBT,round(spp$POBTOT[len[j]]))
    meanPROM<-c(meanPROM,spp$PROM_HNV[len[j]])
    sumaPNT<-c(sumaPNT,round(spp$PNACENT[len[j]]))
    sumaPNOT<-c(sumaPNOT,round(spp$PNACOE[len[j]]))
    suma14an<-c(suma14an,round(spp$P8A14AN[len[j]]))
    suma15an<-c(suma15an,round(spp$P15YM_AN[len[j]]))
    suma15se<-c(suma15se,round(spp$P15YM_SE[len[j]]))
    sumaPri<-c(sumaPri,round(spp$P15PRI_IN[len[j]]))
    sumaSec<-c(sumaSec,round(spp$P15SEC_IN[len[j]]))
    meanGrE<-c(meanGrE,spp$GRAPROES[len[j]])
    sumaPEA<-c(sumaPEA,round(spp$PEA[len[j]]))
    sumaDes<-c(sumaDes,round(spp$PDESOCUP[len[j]]))
    sumaPSINDER<-c(sumaPSINDER,round(spp$PSINDER[len[j]]))
    sumaIMSS<-c(sumaIMSS,round(spp$PDER_IMSS[len[j]]))
    sumaVIVT<-c(sumaVIVT,round(spp$VIVTOT[len[j]]))
    sumaVTH<-c(sumaVTH,round(spp$TVIVHAB[len[j]]))
    sumaVTP<-c(sumaVTP,round(spp$TVIVPAR[len[j]]))
    sumaVPH<-c(sumaVPH,round(spp$VIVPAR_HAB[len[j]]))
    sumaTVPH<-c(sumaTVPH,round(spp$TVIVPARHAB[len[j]]))
    sumaVPD<-c(sumaVPD,round(spp$VIVPAR_DES[len[j]]))
    meanOCUP<-c(meanOCUP,spp$PROM_OCUP[len[j]])
    meanOCUPC<-c(meanOCUPC,spp$PRO_OCUP_C[len[j]])
    sumaPT<-c(sumaPT,round(spp$VPH_PISOTI[len[j]]))
    suma1DO<-c(suma1DO,round(spp$VPH_1DOR[len[j]]))
    suma1CTO<-c(suma1CTO,round(spp$VPH_1CUART[len[j]]))
    sumaCElec<-c(sumaCElec,round(spp$VPH_C_ELEC[len[j]]))
    sumaSElec<-c(sumaSElec,round(spp$VPH_S_ELEC[len[j]]))
    sumaAGUADV<-c(sumaAGUADV,round(spp$VPH_AGUADV[len[j]]))
    sumaAGUAFV<-c(sumaAGUAFV,round(spp$VPH_AGUAFV[len[j]]))
    sumaEXCSA<-c(sumaEXCSA,round(spp$VPH_EXCSA[len[j]]))
    sumaDREN<-c(sumaDREN,round(spp$VPH_DRENAJ[len[j]]))
    sumaNoDren<-c(sumaNoDren,round(spp$VPH_NODREN[len[j]]))
    sumaSERV<-c(sumaSERV,round(spp$VPH_C_SERV[len[j]]))
    sumaSNB<-c(sumaSNB,round(spp$VPH_SNBIEN[len[j]]))
    sumaAREA<-c(sumaAREA,spp$area[len[j]])
  }
  grid$POBTOT[row.names(grid)==i]<-sum(sumaPOBT,na.rm=T)
  grid$PROM_HNV[row.names(grid)==i]<-mean(meanPROM,na.rm=T)
  grid$PNACENT[row.names(grid)==i]<-sum(sumaPNT,na.rm=T)
  grid$PNACOE[row.names(grid)==i]<-sum(sumaPNOT,na.rm=T)
  grid$P8A14AN[row.names(grid)==i]<-sum(suma14an,na.rm=T)
  grid$P15YM_AN[row.names(grid)==i]<-sum(suma15an,na.rm=T)
  grid$P15YM_SE[row.names(grid)==i]<-sum(suma15se,na.rm=T)
  grid$P15PRI_IN[row.names(grid)==i]<-sum(sumaPri,na.rm=T)
  grid$P15SEC_IN[row.names(grid)==i]<-sum(sumaSec,na.rm=T)
  grid$GRAPROES[row.names(grid)==i]<-mean(meanGrE,na.rm=T)
  grid$PEA[row.names(grid)==i]<-sum(sumaPEA,na.rm=T)
  grid$PDESOCUP[row.names(grid)==i]<-sum(sumaDes,na.rm=T)
  grid$PSINDER[row.names(grid)==i]<-sum(sumaPSINDER,na.rm=T)
  grid$PDER_IMSS[row.names(grid)==i]<-sum(sumaIMSS,na.rm=T)
  grid$VIVTOT[row.names(grid)==i]<-sum(sumaVIVT,na.rm=T)
  grid$TVIVHAB[row.names(grid)==i]<-sum(sumaVTH,na.rm=T)
  grid$TVIVPAR[row.names(grid)==i]<-sum(sumaVTP,na.rm=T)
  grid$VIVPAR_HAB[row.names(grid)==i]<-sum(sumaVPH,na.rm=T)
  grid$TVIVPARHAB[row.names(grid)==i]<-sum(sumaTVPH,na.rm=T)
  grid$VIVPAR_DES[row.names(grid)==i]<-sum(sumaVPD,na.rm=T)
  grid$PROM_OCUP[row.names(grid)==i]<-mean(meanOCUP,na.rm=T)
  grid$PRO_OCUP_C[row.names(grid)==i]<-mean(meanOCUPC,na.rm=T)
  grid$VPH_PISOTI[row.names(grid)==i]<-sum(sumaPT,na.rm=T)
  grid$VPH_1DOR[row.names(grid)==i]<-sum(suma1DO,na.rm=T)
  grid$VPH_1CUART[row.names(grid)==i]<-sum(suma1CTO,na.rm=T)
  grid$VPH_C_ELEC[row.names(grid)==i]<-sum(sumaCElec,na.rm=T)
  grid$VPH_S_ELEC[row.names(grid)==i]<-sum(sumaSElec,na.rm=T)
  grid$VPH_AGUADV[row.names(grid)==i]<-sum(sumaAGUADV,na.rm=T)
  grid$VPH_AGUAFV[row.names(grid)==i]<-sum(sumaAGUAFV,na.rm=T)
  grid$VPH_EXCSA[row.names(grid)==i]<-sum(sumaEXCSA,na.rm=T)
  grid$VPH_DRENAJ[row.names(grid)==i]<-sum(sumaDREN,na.rm=T)
  grid$VPH_NODREN[row.names(grid)==i]<-sum(sumaNoDren,na.rm=T)
  grid$VPH_C_SERV[row.names(grid)==i]<-sum(sumaSERV,na.rm=T)
  grid$VPH_SNBIEN[row.names(grid)==i]<-sum(sumaSNB,na.rm=T)
  grid$area[row.names(grid)==i]<-sum(sumaAREA,na.rm=T)
}

# Crear las variables ZU_i
max<-max(grid$area)
max
for(i in 1:length(grid)){
  if(grid$area[i]>=max*.75){
    grid$ZU_75[i]<-1
  }
  if(grid$area[i]>=max*.60){
    grid$ZU_60[i]<-1
  } 
  if(grid$area[i]>=max*.50){
    grid$ZU_50[i]<-1
  } 
  if(grid$area[i]>=max*.40){
    grid$ZU_40[i]<-1
  } 
  if(grid$area[i]>=max*.30){
    grid$ZU_30[i]<-1
  } 
  if(grid$area[i]>=max*.25){
    grid$ZU_25[i]<-1
  } 
}
#Checar el número de cuadritos del grid que caen dentro de las variables  ZU_i
sum(grid$ZU_75)
sum(grid$ZU_60)
sum(grid$ZU_50)
sum(grid$ZU_40)
sum(grid$ZU_30)
sum(grid$ZU_25)

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/2. Grid Ageb")
writeOGR(grid,".","grid500_AGEBS10","ESRI Shapefile")

#Checa las personas perdidas
sum(Ageb$POBTOT)
sum(grid$POBTOT,na.rm=T)
sum(Ageb$POBTOT,na.rm=T)-sum(grid$POBTOT,na.rm=T)


# #------------------------------------------------------------------------------------
# #-----------2005-------------------------------------------
# setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/ZM Chihuahua")
# Ageb<-readOGR(dsn=".",layer="AGEBS2005var")
# Ageb<-spTransform(Ageb,CRS("+init=epsg:4484"))
# setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/ZM Chihuahua/1. Grids")
# grid<-readOGR(dsn=".",layer="grid500")
# grid<-spTransform(grid,CRS("+init=epsg:4488"))
# row.names(grid)
# row.names(Ageb)
# names(grid)
# names(Ageb)
# #Area en m2
# AreaAG<-(gArea(Ageb,byid=T))
# summary(AreaAG)
# Ageb$area<-(sapply(slot(Ageb,"polygons"),slot,"area"))
# all.equal(unname(AreaAG),Ageb$area)
# summary(Ageb$area)
# length(Ageb)
# hist(Ageb$area)
# summary(gArea(grid,byid=T))
# #Intersecci??n
# prueba<-gIntersection(grid,Ageb,byid=T)
# nombres<-names(prueba)
# head(nombres)
# separar<-(strsplit(nombres," "))
# separar<-as.data.frame(t(as.data.frame((separar))))
# row.names(separar)<-c(1:nrow(separar))
# names(separar)<-c("grid","AGEB")
# names(Ageb)
# matriz<-as.data.frame(matrix(nrow=length(prueba),ncol=32))
# names(matriz)<-names(Ageb)[1:32]
# row.names(matriz)<-row.names(prueba)
# plot(prueba)
# spp <-SpatialPolygonsDataFrame(prueba,data=matriz)
# spp$area<-(sapply(slot(spp,"polygons"),slot,"area"))
# spp$prop<-rep(NA,length(spp))
# spp$grid<-separar[,1]
# spp$AGEBS<-separar[,2]
# summary(spp)
# 
# names(spp)
# summary(spp)
# names(Ageb)
# k<-4
# plot(Ageb[row.names(Ageb)==(k),],col="red")
# plot(spp[spp$AGEBS==k,],col="blue")
# 
# plot(spp[k,],col="blue",add=T)
# plot(Ageb[row.names(Ageb)==spp$AGEBS[k],],col="red")
# 
# Ageb$CVEGEO[row.names(Ageb)==spp$AGEBS[1]]
# plot(Ageb[row.names(Ageb)==0,])
# plot(spp[spp$AGEBS==0,])
# names(Ageb)
# names(spp)
# #Construir las proporciones de Ageb en cada grid
# for(i in 0:length(spp)){
#   #spp$CLVAGB[i]<-(Ageb$CLVAGB[row.names(Ageb)==spp$CLVAGB[i]])
#   spp$prop[i]<-spp$area[i]/Ageb$area[row.names(Ageb)==spp$AGEBS[i]]
#   spp$P_TOTAL[i]<-(Ageb$P_TOTAL[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$P_15YMAS[i]<-(Ageb$P_15YMAS[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$PROM_HNV[i]<-(Ageb$PROM_HNV[row.names(Ageb)==spp$AGEBS[i]])
#   spp$P_SINDER[i]<-(Ageb$P_SINDER[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$P_IMSS[i]<-(Ageb$P_IMSS[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$P_8A14AN[i]<-(Ageb$P_8A14AN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$P_15MAAN[i]<-(Ageb$P_15MAAN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$P15YMASE[i]<-(Ageb$P15YMASE[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$P15YM_EBIN[i]<-(Ageb$P15YM_EBIN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i] 
#   spp$GRAPROES[i]<-(Ageb$GRAPROES[row.names(Ageb)==spp$AGEBS[i]])
#   spp$TOT_HOG[i]<-(Ageb$TOT_HOG[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$T_VIVHAB[i]<-(Ageb$T_VIVHAB[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VIVPARHA[i]<-(Ageb$VIVPARHA[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$O_VIVPAR[i]<-(Ageb$O_VIVPAR[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$PRO_VIPA[i]<-(Ageb$PRO_VIPA[row.names(Ageb)==spp$AGEBS[i]])
#   spp$PRO_C_VP[i]<-(Ageb$PRO_C_VP[row.names(Ageb)==spp$AGEBS[i]])
#   spp$VPH_CON_PT[i]<-(Ageb$VPH_CON_PT[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_1DOR[i]<-(Ageb$VPH_1DOR[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_1CUA[i]<-(Ageb$VPH_1CUA[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_EXCSA[i]<-(Ageb$VPH_EXCSA[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_AGDV[i]<-(Ageb$VPH_AGDV[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_NOAG[i]<-(Ageb$VPH_NOAG[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_DREN[i]<-(Ageb$VPH_DREN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_NODREN[i]<-(Ageb$VPH_NODREN[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_ENEL[i]<-(Ageb$VPH_ENEL[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_DREE[i]<-(Ageb$VPH_DREE[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
#   spp$VPH_SBIE[i]<-(Ageb$VPH_SBIE[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
# }
# 
# summary(spp)
# names(Ageb)
# names(spp)
# summary(spp)
# summary(Ageb)
# plot(spp)
# 
# 
# #15 variables
# grid$P_TOTAL<-rep(0,length(grid))
# grid$P_15YMAS<-rep(0,length(grid))
# grid$PROM_HNV<-rep(NA,length(grid))
# grid$P_SINDER<-rep(NA,length(grid))
# grid$P_IMSS<-rep(NA,length(grid))
# grid$P_8A14AN<-rep(NA,length(grid))
# grid$P_15MAAN<-rep(NA,length(grid))
# grid$P15YMASE<-rep(NA,length(grid))
# grid$P15YM_EBIN<-rep(NA,length(grid))
# grid$GRAPROES<-rep(NA,length(grid))
# grid$TOT_HOG<-rep(0,length(grid))
# grid$T_VIVHAB<-rep(0,length(grid))
# grid$VIVPARHA<-rep(0,length(grid))
# grid$O_VIVPAR<-rep(0,length(grid))
# grid$PRO_VIPA<-rep(NA,length(grid))
# grid$PRO_C_VP<-rep(NA,length(grid))
# grid$VPH_CON_PT<-rep(NA,length(grid))
# grid$VPH_1DOR<-rep(NA,length(grid))
# grid$VPH_1CUA<-rep(NA,length(grid))
# grid$VPH_EXCSA<-rep(NA,length(grid))
# grid$VPH_AGDV<-rep(NA,length(grid))
# grid$VPH_NOAG<-rep(NA,length(grid))
# grid$VPH_DREN<-rep(NA,length(grid))
# grid$VPH_NODREN<-rep(NA,length(grid))
# grid$VPH_ENEL<-rep(NA,length(grid))
# grid$VPH_DREE<-rep(NA,length(grid))
# grid$VPH_SBIE<-rep(NA,length(grid))
# grid$area<-rep(0,length(grid))
# grid$ZU_75<-rep(0,length(grid))
# grid$ZU_60<-rep(0,length(grid))
# grid$ZU_50<-rep(0,length(grid))
# grid$ZU_40<-rep(0,length(grid))
# grid$ZU_30<-rep(0,length(grid))
# grid$ZU_25<-rep(0,length(grid))
# 
# 
# summary(grid)
# list<-unique(spp$grid)
# for(i in list){
#   len<-which(spp$grid==i)
#   sumaPOBT<-c()
#   sumaP15<-c()
#   meanPROM<-c()
#   sumaPSINDER<-c()
#   sumaIMSS<-c()
#   suma14an<-c()
#   suma15an<-c()
#   suma15se<-c()
#   sumaEBIN<-c()
#   meanGrE<-c()
#   sumaTHOG<-c()
#   sumaTVIV<-c()
#   sumaVIVPAR<-c()
#   sumaOVP<-c()
#   meanVIPA<-c()
#   meanCVP<-c()
#   sumaPT<-c()
#   suma1DOR<-c()
#   suma1CUA<-c()
#   sumaEXC<-c()
#   sumaAGDV<-c()
#   sumaNOAG<-c()
#   sumaDREN<-c()
#   sumaNoDren<-c()
#   sumaENEL<-c()
#   sumaDREE<-c()
#   sumaSNB<-c()
#   sumaAREA<-c()
#   for(j in 1:length(len)){
#     sumaPOBT<-c(sumaPOBT,round(spp$P_TOTAL[len[j]]))
#     sumaP15<-c(sumaP15,round(spp$P_15YMAS[len[j]]))
#     meanPROM<-c(meanPROM,spp$PROM_HNV[len[j]])
#     sumaPSINDER<-c(sumaPSINDER,round(spp$P_SINDER[len[j]]))
#     sumaIMSS<-c(sumaIMSS,round(spp$P_IMSS[len[j]]))
#     suma14an<-c(suma14an,round(spp$P_8A14AN[len[j]]))   
#     suma15an<-c(suma15an,round(spp$P_15MAAN[len[j]]))
#     suma15se<-c(suma15se,round(spp$P15YMASE[len[j]]))
#     sumaEBIN<-c(sumaEBIN,round(spp$P15YM_EBIN[len[j]]))
#     meanGrE<-c(meanGrE,spp$GRAPROES[len[j]])
#     sumaTHOG<-c(sumaTHOG,round(spp$TOT_HOG[len[j]]))
#     sumaTVIV<-c(sumaTVIV,round(spp$T_VIVHAB[len[j]]))
#     sumaVIVPAR<-c(sumaVIVPAR,round(spp$VIVPARHA[len[j]]))
#     sumaOVP<-c(sumaOVP,round(spp$O_VIVPAR[len[j]]))
#     meanVIPA<-c(meanVIPA,spp$PRO_VIPA[len[j]])
#     meanCVP<-c(meanCVP,spp$PRO_C_VP[len[j]])
#     sumaPT<-c(sumaPT,round(spp$VPH_CON_PT[len[j]]))
#     suma1DOR<-c(suma1DOR,round(spp$VPH_1DOR[len[j]]))
#     suma1CUA<-c(suma1CUA,round(spp$VPH_1CUA[len[j]]))
#     sumaEXC<-c(sumaEXC,round(spp$VPH_EXCSA[len[j]]))
#     sumaAGDV<-c(sumaAGDV,round(spp$VPH_AGDV[len[j]]))
#     sumaNOAG<-c(sumaNOAG,round(spp$VPH_NOAG[len[j]]))
#     sumaDREN<-c(sumaDREN,round(spp$VPH_DREN[len[j]]))
#     sumaNoDren<-c(sumaNoDren,round(spp$VPH_NODREN[len[j]]))
#     sumaENEL<-c(sumaENEL,round(spp$VPH_ENEL[len[j]]))
#     sumaDREE<-c(sumaDREE,round(spp$VPH_DREE[len[j]]))
#     sumaSNB<-c(sumaSNB,round(spp$VPH_SBIE[len[j]]))
#     sumaAREA<-c(sumaAREA,spp$area[len[j]])
#   }
#   grid$P_TOTAL[row.names(grid)==i]<-sum(sumaPOBT,na.rm=T)
#   grid$P_15YMAS[row.names(grid)==i]<-sum(sumaP15,na.rm=T)
#   grid$PROM_HNV[row.names(grid)==i]<-mean(meanPROM,na.rm=T)
#   grid$P_SINDER[row.names(grid)==i]<-sum(sumaPSINDER,na.rm=T)
#   grid$P_IMSS[row.names(grid)==i]<-sum(sumaIMSS,na.rm=T)
#   grid$P_8A14AN[row.names(grid)==i]<-sum(suma14an,na.rm=T)
#   grid$P_15MAAN[row.names(grid)==i]<-sum(suma15an,na.rm=T)
#   grid$P15YMASE[row.names(grid)==i]<-sum(suma15se,na.rm=T)
#   grid$P15YM_EBIN[row.names(grid)==i]<-sum(sumaEBIN,na.rm=T)  
#   grid$GRAPROES[row.names(grid)==i]<-mean(meanGrE,na.rm=T)
#   grid$TOT_HOG[row.names(grid)==i]<-sum(sumaTHOG,na.rm=T)
#   grid$T_VIVHAB[row.names(grid)==i]<-sum(sumaTVIV,na.rm=T)
#   grid$VIVPARHA[row.names(grid)==i]<-sum(sumaVIVPAR,na.rm=T)
#   grid$O_VIVPAR[row.names(grid)==i]<-sum(sumaOVP,na.rm=T)
#   grid$PRO_VIPA[row.names(grid)==i]<-mean(meanVIPA,na.rm=T)
#   grid$PRO_C_VP[row.names(grid)==i]<-mean(meanCVP,na.rm=T)
#   grid$VPH_CON_PT[row.names(grid)==i]<-sum(sumaPT,na.rm=T)
#   grid$VPH_1DOR[row.names(grid)==i]<-sum(suma1DOR,na.rm=T)
#   grid$VPH_1CUA[row.names(grid)==i]<-sum(suma1CUA,na.rm=T)
#   grid$VPH_EXCSA[row.names(grid)==i]<-sum(sumaEXC,na.rm=T)
#   grid$VPH_AGDV[row.names(grid)==i]<-sum(sumaAGDV,na.rm=T)
#   grid$VPH_NOAG[row.names(grid)==i]<-sum(sumaNOAG,na.rm=T)
#   grid$VPH_DREN[row.names(grid)==i]<-sum(sumaDREN,na.rm=T)
#   grid$VPH_NODREN[row.names(grid)==i]<-sum(sumaNoDren,na.rm=T)
#   grid$VPH_ENEL[row.names(grid)==i]<-sum(sumaENEL,na.rm=T)
#   grid$VPH_ENEL[row.names(grid)==i]<-sum(sumaENEL,na.rm=T)
#   grid$VPH_DREE[row.names(grid)==i]<-sum(sumaDREE,na.rm=T)
#   grid$VPH_SBIE[row.names(grid)==i]<-sum(sumaSNB,na.rm=T)
#   grid$area[row.names(grid)==i]<-sum(sumaAREA,na.rm=T)
# }
# 
# sum(Ageb$P_TOTAL,na.rm=T)
# sum(grid$P_TOTAL,na.rm=T)
# 
# summary(grid)
# summary(grid$area[grid$area>0])
# max<-max(grid$area)
# summary(grid$area)
# 
# for(i in 1:length(grid)){
#   if(grid$area[i]>=max*.75){
#     grid$ZU_75[i]<-1
#   }
#   if(grid$area[i]>=max*.60){
#     grid$ZU_60[i]<-1
#   } 
#   if(grid$area[i]>=max*.50){
#     grid$ZU_50[i]<-1
#   } 
#   if(grid$area[i]>=max*.40){
#     grid$ZU_40[i]<-1
#   } 
#   if(grid$area[i]>=max*.30){
#     grid$ZU_30[i]<-1
#   } 
#   if(grid$area[i]>=max*.25){
#     grid$ZU_25[i]<-1
#   } 
# }
# sum(grid$ZU_75)
# sum(grid$ZU_60)
# sum(grid$ZU_50)
# sum(grid$ZU_40)
# sum(grid$ZU_30)
# sum(grid$ZU_25)
# 
# summary(grid)
# summary(grid$P_TOTAL[grid$P_TOTAL>0])
# sum(grid$P_TOTAL>0)
# 
# setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/ZM Chihuahua/2. Grid Ageb")
# writeOGR(grid,".","grid500_AGEBS2005","ESRI Shapefile")
# 




#__________________________________________________________________________________
# Unir al grid Censo urbano 2000
#_________________________________________________________________________________

rm(list=ls(all=T))
gc(reset=TRUE)

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/53")
Ageb<-readOGR(dsn=".",layer="AGEBS2000var_prj")
#Cambiar EPSG dependiendo de la zona de UTM

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/1. Grids")
grid<-readOGR(dsn=".",layer="grid500_10")
#Cambiar EPSG dependiendo de la zona de UTM

#Revisar que la proyección sea la misma
proj4string(grid)
proj4string(Ageb)

names(grid)
names(Ageb)
#CAlculo el Area en m2 de cada AGEB y agrego una variable de Area
AreaAG<-(gArea(Ageb,byid=T))
summary(AreaAG)
Ageb$area<-(sapply(slot(Ageb,"polygons"),slot,"area"))
all.equal(unname(AreaAG),Ageb$area)
summary(Ageb$area)
length(Ageb)
hist(Ageb$area)
summary(gArea(grid,byid=T))


#Intersección del AGEB con el grid
polygone1 <- gBuffer(grid, byid=TRUE, width=0)
polygone2 <- gBuffer(Ageb, byid=TRUE, width=0)
prueba <- gIntersection(polygone1, polygone2, byid=TRUE)

#Separo en columnas el grid y el AGEb al que corresponde cada cacho de la intersección
nombres<-names(prueba)
head(nombres)
separar<-(strsplit(nombres," "))
separar<-as.data.frame(t(as.data.frame((separar))))
row.names(separar)<-c(1:nrow(separar))
names(separar)<-c("grid","AGEB")
names(Ageb)

#Creo matriz y Spatial Dataframe a la intersección, asignando las variables del censo como columnas
matriz<-as.data.frame(matrix(nrow=length(prueba),ncol=44))
names(matriz)<-names(Ageb)[1:44]
row.names(matriz)<-row.names(prueba)
spp <-SpatialPolygonsDataFrame(prueba,data=matriz)
spp$area<-(sapply(slot(spp,"polygons"),slot,"area"))
#Creo una variable de porporción (área interseccion/área AGEB)
spp$prop<-rep(NA,length(spp))
spp$grid<-separar[,1]
spp$AGEBS<-separar[,2]
summary(spp)


#Construir las proporciones de Ageb en cada grid
for(i in 0:length(spp)){
  spp$prop[i]<-spp$area[i]/Ageb$area[row.names(Ageb)==spp$AGEBS[i]]
  spp$Z1[i]<-(Ageb$Z1[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z22[i]<-(Ageb$Z22[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z51[i]<-(Ageb$Z51[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z52[i]<-(Ageb$Z52[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z61[i]<-(Ageb$Z61[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z64[i]<-(Ageb$Z64[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z70[i]<-(Ageb$Z70[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z77[i]<-(Ageb$Z77[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z83[i]<-(Ageb$Z83[row.names(Ageb)==spp$AGEBS[i]])
  spp$Z100[i]<-(Ageb$Z100[row.names(Ageb)==spp$AGEBS[i]])
  spp$Z101[i]<-(Ageb$Z101[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z103[i]<-(Ageb$Z103[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z119[i]<-(Ageb$Z119[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z120[i]<-(Ageb$Z120[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z121[i]<-(Ageb$Z121[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z123[i]<-(Ageb$Z123[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z126[i]<-(Ageb$Z126[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z128[i]<-(Ageb$Z128[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z130[i]<-(Ageb$Z130[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z133[i]<-(Ageb$Z133[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z134[i]<-(Ageb$Z134[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z135[i]<-(Ageb$Z135[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z136[i]<-(Ageb$Z136[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z137[i]<-(Ageb$Z137[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z138[i]<-(Ageb$Z138[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z139[i]<-(Ageb$Z139[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z140[i]<-(Ageb$Z140[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z141[i]<-(Ageb$Z141[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z143[i]<-(Ageb$Z143[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z144[i]<-(Ageb$Z144[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z145[i]<-(Ageb$Z145[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z146[i]<-(Ageb$Z146[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z147[i]<-(Ageb$Z147[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z162[i]<-(Ageb$Z162[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z163[i]<-(Ageb$Z163[row.names(Ageb)==spp$AGEBS[i]])
  spp$Z164[i]<-(Ageb$Z164[row.names(Ageb)==spp$AGEBS[i]])
  spp$Z165[i]<-(Ageb$Z165[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Z165[i]<-(Ageb$Z165[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
  spp$Analf[i]<-(Ageb$Analf[row.names(Ageb)==spp$AGEBS[i]])*spp$prop[i]
}

summary(spp)
names(Ageb)
names(spp)
summary(spp)
summary(Ageb)
plot(spp)


#Creo las variables en el grid y sumo los cachos de intersección que caen dentro de un mismo grid
grid$Z1<-rep(0,length(grid))
grid$Z22<-rep(0,length(grid))
grid$Z51<-rep(NA,length(grid))
grid$Z52<-rep(NA,length(grid))
grid$Z61<-rep(NA,length(grid))
grid$Z64<-rep(NA,length(grid))
grid$Z70<-rep(NA,length(grid))
grid$Z77<-rep(NA,length(grid))
grid$Z83<-rep(NA,length(grid))
grid$Z100<-rep(NA,length(grid))
grid$Z101<-rep(NA,length(grid))
grid$Z103<-rep(NA,length(grid))
grid$Z119<-rep(0,length(grid))
grid$Z120<-rep(0,length(grid))
grid$Z121<-rep(NA,length(grid))
grid$Z123<-rep(NA,length(grid))
grid$Z126<-rep(NA,length(grid))
grid$Z128<-rep(NA,length(grid))
grid$Z130<-rep(NA,length(grid))
grid$Z133<-rep(NA,length(grid))
grid$Z134<-rep(NA,length(grid))
grid$Z135<-rep(NA,length(grid))
grid$Z136<-rep(NA,length(grid))
grid$Z137<-rep(NA,length(grid))
grid$Z138<-rep(NA,length(grid))
grid$Z139<-rep(NA,length(grid))
grid$Z140<-rep(NA,length(grid))
grid$Z141<-rep(NA,length(grid))
grid$Z143<-rep(NA,length(grid))
grid$Z144<-rep(NA,length(grid))
grid$Z145<-rep(NA,length(grid))
grid$Z146<-rep(NA,length(grid))
grid$Z147<-rep(NA,length(grid))
grid$Z162<-rep(NA,length(grid))
grid$Z163<-rep(NA,length(grid))
grid$Z164<-rep(NA,length(grid))
grid$Z165<-rep(NA,length(grid))
grid$Analf<-rep(NA,length(grid))
grid$area<-rep(0,length(grid))
grid$ZU_75<-rep(0,length(grid))
grid$ZU_60<-rep(0,length(grid))
grid$ZU_50<-rep(0,length(grid))
grid$ZU_40<-rep(0,length(grid))
grid$ZU_30<-rep(0,length(grid))
grid$ZU_25<-rep(0,length(grid))

summary(grid)
list<-unique(spp$grid)
for(i in list){
  len<-which(spp$grid==i)
  sumaZ1<-c()
  sumaZ22<-c()
  sumaZ51<-c()
  sumaZ52<-c()
  sumaZ61<-c()
  sumaZ64<-c()
  sumaZ70<-c()
  sumaZ77<-c()
  meanZ83<-c()
  meanZ100<-c()
  sumaZ101<-c()
  sumaZ103<-c()
  sumaZ119<-c()
  sumaZ120<-c()
  sumaZ121<-c()
  sumaZ123<-c()
  sumaZ126<-c()
  sumaZ128<-c()
  sumaZ130<-c()
  sumaZ133<-c()
  sumaZ134<-c()
  sumaZ135<-c()
  sumaZ136<-c()
  sumaZ137<-c()
  sumaZ138<-c()
  sumaZ139<-c()
  sumaZ140<-c()
  sumaZ141<-c()
  sumaZ143<-c()
  sumaZ144<-c()
  sumaZ145<-c()
  sumaZ146<-c()
  sumaZ147<-c()
  sumaZ162<-c()
  meanZ163<-c()
  meanZ164<-c()
  sumaZ165<-c()
  sumaAnalf<-c()
  sumaAREA<-c()

  for(j in 1:length(len)){
    sumaZ1<-c(sumaZ1,round(spp$Z1[len[j]]))
    sumaZ22<-c(sumaZ22,round(spp$Z22[len[j]]))
    sumaZ51<-c(sumaZ51,round(spp$Z51[len[j]]))
    sumaZ52<-c(sumaZ52,round(spp$Z52[len[j]]))
    sumaZ61<-c(sumaZ61,round(spp$Z61[len[j]]))
    sumaZ64<-c(sumaZ64,round(spp$Z64[len[j]]))
    sumaZ70<-c(sumaZ70,round(spp$Z70[len[j]]))
    meanZ83<-c(meanZ83,spp$Z83[len[j]])
    meanZ100<<-c(meanZ100,spp$Z100[len[j]])
    sumaZ101<-c(sumaZ101,round(spp$Z101[len[j]]))
    sumaZ103<-c(sumaZ103,round(spp$Z103[len[j]]))
    sumaZ119<-c(sumaZ119,round(spp$Z119[len[j]]))
    sumaZ120<-c(sumaZ120,round(spp$Z120[len[j]]))
    sumaZ121<-c(sumaZ121,round(spp$Z121[len[j]]))
    sumaZ123<-c(sumaZ123,round(spp$Z123[len[j]]))
    sumaZ126<-c(sumaZ126,round(spp$Z126[len[j]]))
    sumaZ128<-c(sumaZ128,round(spp$Z128[len[j]]))
    sumaZ130<-c(sumaZ130,round(spp$Z130[len[j]]))
    sumaZ133<-c(sumaZ133,round(spp$Z133[len[j]]))
    sumaZ134<-c(sumaZ134,round(spp$Z134[len[j]]))
    sumaZ135<-c(sumaZ135,round(spp$Z135[len[j]]))
    sumaZ136<-c(sumaZ136,round(spp$Z136[len[j]]))
    sumaZ137<-c(sumaZ137,round(spp$Z137[len[j]]))
    sumaZ138<-c(sumaZ138,round(spp$Z138[len[j]]))
    sumaZ139<-c(sumaZ139,round(spp$Z139[len[j]]))
    sumaZ140<-c(sumaZ140,round(spp$Z140[len[j]]))
    sumaZ141<-c(sumaZ141,round(spp$Z141[len[j]]))
    sumaZ143<-c(sumaZ143,round(spp$Z143[len[j]]))
    sumaZ144<-c(sumaZ144,round(spp$Z144[len[j]]))
    sumaZ145<-c(sumaZ145,round(spp$Z145[len[j]]))
    sumaZ146<-c(sumaZ146,round(spp$Z146[len[j]]))
    sumaZ147<-c(sumaZ147,round(spp$Z147[len[j]]))  
    sumaZ162<-c(sumaZ162,round(spp$Z162[len[j]]))
    meanZ163<<-c(meanZ163,spp$Z163[len[j]])
    meanZ164<<-c(meanZ164,spp$Z164[len[j]])
    sumaZ165<-c(sumaZ165,round(spp$Z165[len[j]]))
    sumaAnalf<-c(sumaAnalf,round(spp$Analf[len[j]]))
    sumaAREA<-c(sumaAREA,spp$area[len[j]])
  }
  grid$Z1[row.names(grid)==i]<-sum(sumaZ1,na.rm=T)
  grid$Z22[row.names(grid)==i]<-sum(sumaZ1,na.rm=T)
  grid$Z51[row.names(grid)==i]<-sum(sumaZ51,na.rm=T)
  grid$Z52[row.names(grid)==i]<-sum(sumaZ52,na.rm=T)
  grid$Z61[row.names(grid)==i]<-sum(sumaZ61,na.rm=T)
  grid$Z64[row.names(grid)==i]<-sum(sumaZ64,na.rm=T)
  grid$Z70[row.names(grid)==i]<-sum(sumaZ70,na.rm=T)
  grid$Z77[row.names(grid)==i]<-sum(sumaZ77,na.rm=T)
  grid$Z83[row.names(grid)==i]<-mean(meanZ83,na.rm=T)
  grid$Z100[row.names(grid)==i]<-mean(meanZ100,na.rm=T)
  grid$Z101[row.names(grid)==i]<-sum(sumaZ101,na.rm=T)
  grid$Z103[row.names(grid)==i]<-sum(sumaZ103,na.rm=T)
  grid$Z119[row.names(grid)==i]<-sum(sumaZ119,na.rm=T)
  grid$Z120[row.names(grid)==i]<-sum(sumaZ120,na.rm=T)
  grid$Z121[row.names(grid)==i]<-sum(sumaZ121,na.rm=T)
  grid$Z123[row.names(grid)==i]<-sum(sumaZ123,na.rm=T)
  grid$Z126[row.names(grid)==i]<-sum(sumaZ126,na.rm=T)
  grid$Z128[row.names(grid)==i]<-sum(sumaZ128,na.rm=T)
  grid$Z130[row.names(grid)==i]<-sum(sumaZ130,na.rm=T)
  grid$Z133[row.names(grid)==i]<-sum(sumaZ133,na.rm=T)
  grid$Z134[row.names(grid)==i]<-sum(sumaZ134,na.rm=T)
  grid$Z135[row.names(grid)==i]<-sum(sumaZ135,na.rm=T)
  grid$Z136[row.names(grid)==i]<-sum(sumaZ136,na.rm=T)
  grid$Z137[row.names(grid)==i]<-sum(sumaZ137,na.rm=T)
  grid$Z138[row.names(grid)==i]<-sum(sumaZ138,na.rm=T)
  grid$Z139[row.names(grid)==i]<-sum(sumaZ139,na.rm=T)
  grid$Z140[row.names(grid)==i]<-sum(sumaZ140,na.rm=T)
  grid$Z141[row.names(grid)==i]<-sum(sumaZ141,na.rm=T)
  grid$Z143[row.names(grid)==i]<-sum(sumaZ143,na.rm=T)
  grid$Z144[row.names(grid)==i]<-sum(sumaZ144,na.rm=T)
  grid$Z145[row.names(grid)==i]<-sum(sumaZ145,na.rm=T)
  grid$Z146[row.names(grid)==i]<-sum(sumaZ146,na.rm=T)
  grid$Z147[row.names(grid)==i]<-sum(sumaZ147,na.rm=T)
  grid$Z162[row.names(grid)==i]<-sum(sumaZ162,na.rm=T)
  grid$Z163[row.names(grid)==i]<-mean(meanZ163,na.rm=T)
  grid$Z164[row.names(grid)==i]<-mean(meanZ164,na.rm=T)
  grid$Z165[row.names(grid)==i]<-sum(sumaZ165,na.rm=T)
  grid$Analf[row.names(grid)==i]<-sum(sumaAnalf,na.rm=T)
  grid$area[row.names(grid)==i]<-sum(sumaAREA,na.rm=T)
}

summary(grid)
summary(grid$area[grid$area>0])

#Creo la variable de ZU_i: donde si el i% o más del área del grid intersecta al área urbana de los AGEB, ZU_i=1
max<-max(grid$area)
for(i in 1:length(grid)){
  if(grid$area[i]>=max*.75){
    grid$ZU_75[i]<-1
  }
  if(grid$area[i]>=max*.60){
    grid$ZU_60[i]<-1
  } 
  if(grid$area[i]>=max*.50){
    grid$ZU_50[i]<-1
  } 
  if(grid$area[i]>=max*.40){
    grid$ZU_40[i]<-1
  } 
  if(grid$area[i]>=max*.30){
    grid$ZU_30[i]<-1
  } 
  if(grid$area[i]>=max*.25){
    grid$ZU_25[i]<-1
  } 
}
sum(grid$ZU_75)
sum(grid$ZU_60)
sum(grid$ZU_50)
sum(grid$ZU_40)
sum(grid$ZU_30)
sum(grid$ZU_25)

#Checar personas perdidas
sum(grid$Z1,na.rm=T)-sum(Ageb$Z1,na.rm=T)

proj4string(grid)

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/2. Grid Ageb")
writeOGR(grid,".","grid500_AGEBS2000","ESRI Shapefile")

gc(reset=TRUE)
#-------------



#______________________________________________________________________________
#Unir la información de las localidades rurales al grid
#_________________________________________________________________________________

##____________________________________________________
#2010
#____________________________________________________

library(rgdal)
library(maptools)
#Leo el grid 
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/2. Grid Ageb")
grid<-readOGR(dsn=".",layer="grid500_AGEBS10")

proj4string(grid)
pob1<-sum(grid$POBTOT,na.rm=T)
pob1
grid2<-grid[,1]
names(grid2)

#Leo shape ITER
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/ITER shape/53")
loc<-readOGR(dsn=".",layer="ITER2010_cor_var")
proj4string(loc)


#Elimina las localidades urbanas
ur<-which(loc$POBTOT>2500)
summary(loc$POBTOT)
locrur<-loc[-ur,]
row.names(locrur)<-c(1:length(locrur))
row.names(locrur)


#interseccion shape de localidades rurales con el grid
Int<-gIntersection(locrur,grid,byid=T)
class(Int)

#Creo variables de a qué grid y a qué localidad rural pertenece cada pedazo de la intersección
nombres<-row.names(Int)
head(nombres)
separar<-(strsplit(nombres," "))
separar<-as.data.frame(t(as.data.frame((separar))))
row.names(separar)<-c(1:nrow(separar))
names(separar)<-c("Loc","grid")
names(grid)
grid<-grid[,-(2:5)]
names(grid)


#Le asigna al grid la información de las localidades rurales
list<-unique(separar$grid)
for(i in list){
  len<-which(separar$grid==i)
  sumaPOBT<-c()
  sumaPOB15<-c()
  meanPROM<-c()
  sumaPNT<-c()
  sumaPNOT<-c()
  suma14an<-c()
  suma15an<-c()
  suma15se<-c()
  sumaPri<-c()
  sumaSec<-c()
  meanGrE<-c()
  sumaPEA<-c()
  sumaDes<-c()
  sumaPSINDER<-c()
  sumaIMSS<-c()
  sumaVIVT<-c()
  sumaVTH<-c()
  sumaVTP<-c()
  sumaVPH<-c()
  sumaTVPH<-c()
  sumaVPD<-c()
  meanOCUP<-c()
  meanOCUPC<-c()
  sumaPT<-c()
  suma1DO<-c()
  suma1CTO<-c()
  sumaCElec<-c()
  sumaSElec<-c()
  sumaAGUADV<-c()
  sumaAGUAFV<-c()
  sumaEXCSA<-c()
  sumaDREN<-c()
  sumaNoDren<-c()
  sumaSERV<-c()
  sumaSNB<-c()
  for(j in 1:length(len)){
    sumaPOBT<-c(sumaPOBT,(locrur$POBTOT[separar$Loc[len[j]]]))
    sumaPOB15<-c(sumaPOB15,(locrur$P_15YMAS[separar$Loc[len[j]]]))
    meanPROM<-c(meanPROM,locrur$PROM_HNV[separar$Loc[len[j]]])
    sumaPNT<-c(sumaPNT,(locrur$PNACENT[separar$Loc[len[j]]]))
    sumaPNOT<-c(sumaPNOT,(locrur$PNACOE[separar$Loc[len[j]]]))
    suma14an<-c(suma14an,(locrur$P8A14AN[separar$Loc[len[j]]]))
    suma15an<-c(suma15an,(locrur$P15YM_AN[separar$Loc[len[j]]]))   
    suma15se<-c(suma15se,(locrur$P15YM_SE[separar$Loc[len[j]]]))
    sumaPri<-c(sumaPri,(locrur$P15PRI_IN[separar$Loc[len[j]]]))
    sumaSec<-c(sumaSec,(locrur$P15SEC_IN[separar$Loc[len[j]]])) 
    meanGrE<-c(meanGrE,locrur$GRAPROES[separar$Loc[len[j]]])
    sumaPEA<-c(sumaPEA,(locrur$PEA[separar$Loc[len[j]]]))
    sumaDes<-c(sumaDes,(locrur$PDESOCUP[separar$Loc[len[j]]]))
    sumaPSINDER<-c(sumaPSINDER,(locrur$PSINDER[separar$Loc[len[j]]]))
    sumaIMSS<-c(sumaIMSS,(locrur$PDER_IMSS[separar$Loc[len[j]]]))
    sumaVIVT<-c(sumaVIVT,(locrur$VIVTOT[separar$Loc[len[j]]]))
    sumaVTH<-c(sumaVTH,(locrur$TVIVHAB[separar$Loc[len[j]]]))
    sumaVTP<-c(sumaVTP,(locrur$TVIVPAR[separar$Loc[len[j]]]))
    sumaVPH<-c(sumaVPH,(locrur$VIVPAR_HAB[separar$Loc[len[j]]]))
    sumaTVPH<-c(sumaTVPH,(locrur$TVIVPARHAB[separar$Loc[len[j]]]))
    sumaVPD<-c(sumaVPD,(locrur$VIVPAR_DES[separar$Loc[len[j]]]))
    meanOCUP<-c(meanOCUP,locrur$PROM_OCUP[separar$Loc[len[j]]])
    meanOCUPC<-c(meanOCUPC,locrur$PRO_OCUP_C[separar$Loc[len[j]]])
    sumaPT<-c(sumaPT,(locrur$VPH_PISOTI[separar$Loc[len[j]]]))
    suma1DO<-c(suma1DO,(locrur$VPH_1DOR[separar$Loc[len[j]]]))
    suma1CTO<-c(suma1CTO,(locrur$VPH_1CUART[separar$Loc[len[j]]]))
    sumaCElec<-c(sumaCElec,(locrur$VPH_C_ELEC[separar$Loc[len[j]]]))
    sumaSElec<-c(sumaSElec,(locrur$VPH_S_ELEC[separar$Loc[len[j]]]))
    sumaAGUADV<-c(sumaAGUADV,(locrur$VPH_AGUADV[separar$Loc[len[j]]]))
    sumaAGUAFV<-c(sumaAGUAFV,(locrur$VPH_AGUAFV[separar$Loc[len[j]]]))
    sumaEXCSA<-c(sumaEXCSA,(locrur$VPH_EXCSA[separar$Loc[len[j]]]))
    sumaDREN<-c(sumaDREN,(locrur$VPH_DRENAJ[separar$Loc[len[j]]]))
    sumaNoDren<-c(sumaNoDren,(locrur$VPH_NODREN[separar$Loc[len[j]]]))
    sumaSERV<-c(sumaSERV,(locrur$VPH_C_SERV[separar$Loc[len[j]]]))
    sumaSNB<-c(sumaSNB,(locrur$VPH_SNBIEN[separar$Loc[len[j]]]))
  }
  grid$POBTOT[row.names(grid)==i]<-sum(grid$POBTOT[row.names(grid)==i],sumaPOBT,na.rm=T)
  grid$P_15YMAS[row.names(grid)==i]<-sum(grid$P_15YMAS[row.names(grid)==i],sumaPOB15,na.rm=T)
  grid$PROM_HNV[row.names(grid)==i]<-mean(c(grid$PROM_HNV[row.names(grid)==i],meanPROM),na.rm=T)
  grid$PNACENT[row.names(grid)==i]<-sum(grid$PNACENT[row.names(grid)==i],sumaPNT,na.rm=T)
  grid$PNACOE[row.names(grid)==i]<-sum(grid$PNACOE[row.names(grid)==i],sumaPNOT,na.rm=T)
  grid$P8A14AN[row.names(grid)==i]<-sum(grid$P8A14AN[row.names(grid)==i],suma14an,na.rm=T)
  grid$P15YM_AN[row.names(grid)==i]<-sum(grid$P15YM_AN[row.names(grid)==i],suma15an,na.rm=T)
  grid$P15YM_SE[row.names(grid)==i]<-sum(grid$P15YM_SE[row.names(grid)==i],suma15se,na.rm=T)
  grid$P15PRI_IN[row.names(grid)==i]<-sum(grid$P15PRI_IN[row.names(grid)==i],sumaPri,na.rm=T)
  grid$P15SEC_IN[row.names(grid)==i]<-sum(grid$P15SEC_IN[row.names(grid)==i],sumaSec,na.rm=T)
  grid$GRAPROES[row.names(grid)==i]<-mean(c(grid$GRAPROES[row.names(grid)==i],meanGrE),na.rm=T)
  grid$PEA[row.names(grid)==i]<-sum(grid$PEA[row.names(grid)==i],sumaPEA,na.rm=T)
  grid$PDESOCUP[row.names(grid)==i]<-sum(grid$PDESOCUP[row.names(grid)==i],sumaDes,na.rm=T)
  grid$PSINDER[row.names(grid)==i]<-sum(grid$PSINDER[row.names(grid)==i],sumaPSINDER,na.rm=T)
  grid$PDER_IMSS[row.names(grid)==i]<-sum(grid$PDER_IMSS[row.names(grid)==i],sumaIMSS,na.rm=T)
  grid$VIVTOT[row.names(grid)==i]<-sum(grid$VIVTOT[row.names(grid)==i],sumaVIVT,na.rm=T)
  grid$TVIVHAB[row.names(grid)==i]<-sum(grid$TVIVHAB[row.names(grid)==i],sumaVTH,na.rm=T)
  grid$TVIVPAR[row.names(grid)==i]<-sum(grid$TVIVPAR[row.names(grid)==i],sumaVTP,na.rm=T)
  grid$VIVPAR_HAB[row.names(grid)==i]<-sum(grid$VIVPAR_HAB[row.names(grid)==i],sumaVPH,na.rm=T)
  grid$TVIVPARHAB[row.names(grid)==i]<-sum(grid$TVIVPARHAB[row.names(grid)==i],sumaTVPH,na.rm=T)
  grid$VIVPAR_DES[row.names(grid)==i]<-sum(grid$VIVPAR_DES[row.names(grid)==i],sumaVPD,na.rm=T)
  grid$PROM_OCUP[row.names(grid)==i]<-mean(c(grid$PROM_OCUP[row.names(grid)==i],meanOCUP),na.rm=T)
  grid$PRO_OCUP_C[row.names(grid)==i]<-mean(c(grid$PRO_OCUP_C[row.names(grid)==i],meanOCUPC),na.rm=T)
  grid$VPH_PISOTI[row.names(grid)==i]<-sum(grid$VPH_PISOTI[row.names(grid)==i],sumaPT,na.rm=T)
  grid$VPH_1DOR[row.names(grid)==i]<-sum(grid$VPH_1DOR[row.names(grid)==i],suma1DO,na.rm=T)
  grid$VPH_1CUART[row.names(grid)==i]<-sum(grid$VPH_1CUART[row.names(grid)==i],suma1CTO,na.rm=T)
  grid$VPH_C_ELEC[row.names(grid)==i]<-sum(grid$VPH_C_ELEC[row.names(grid)==i],sumaCElec,na.rm=T)
  grid$VPH_S_ELEC[row.names(grid)==i]<-sum(grid$VPH_S_ELEC[row.names(grid)==i],sumaSElec,na.rm=T)
  grid$VPH_AGUADV[row.names(grid)==i]<-sum(grid$VPH_AGUADV[row.names(grid)==i],sumaAGUADV,na.rm=T)
  grid$VPH_AGUAFV[row.names(grid)==i]<-sum(grid$VPH_AGUAFV[row.names(grid)==i],sumaAGUAFV,na.rm=T)
  grid$VPH_EXCSA[row.names(grid)==i]<-sum(grid$VPH_EXCSA[row.names(grid)==i],sumaEXCSA,na.rm=T)
  grid$VPH_DRENAJ[row.names(grid)==i]<-sum(grid$VPH_DRENAJ[row.names(grid)==i],sumaDREN,na.rm=T)
  grid$VPH_NODREN[row.names(grid)==i]<-sum(grid$VPH_NODREN[row.names(grid)==i],sumaNoDren,na.rm=T)
  grid$VPH_C_SERV[row.names(grid)==i]<-sum(grid$VPH_C_SERV[row.names(grid)==i],sumaSERV,na.rm=T)
  grid$VPH_SNBIEN[row.names(grid)==i]<-sum(grid$VPH_SNBIEN[row.names(grid)==i],sumaSNB,na.rm=T)
}



# Genero las variables lat, lon que son las coordenadas del centro del grid
trueCentroids <- gCentroid(grid,byid=TRUE)
grid$lat<-coordinates(trueCentroids)[,2]
grid$lon <-coordinates(trueCentroids)[,1]
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/3. Grid Loc")
writeOGR(grid,".","grid500_censo2010","ESRI Shapefile")



#-----------------------------------------------------------------------------
# Para 2000
#---------------------------------------------------------------------------
gc(reset=TRUE)
library(rgdal)
library(maptools)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/2. Grid Ageb")
grid<-readOGR(dsn=".",layer="grid500_AGEBS2000")
names(grid)
pob1<-sum(grid$Z1,na.rm=T)
pob1
grid2<-grid[,1]
names(grid2)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/ITER shape/53")
loc<-readOGR(dsn=".",layer="ITER2000_cor_var")
names(loc)
ur<-which(loc$POBTOT_>2500)
ur
locrur<-loc[-ur,]
summary(locrur)
names(grid)
names(locrur)
row.names(locrur)<-c(1:nrow(locrur))
row.names(locrur)

Int<-gIntersection(locrur,grid,byid=T)
nombres<-row.names(Int)
separar<-(strsplit(nombres," "))
separar<-as.data.frame(t(as.data.frame((separar))))
row.names(separar)<-c(1:nrow(separar))
names(separar)<-c("Loc","grid")
names(grid)
grid<-grid[,-(2:5)]
names(grid)
names(locrur)



list<-unique(separar$grid)
len<-which(separar$grid==list[1])
len
pt<-locrur$P_TOTAL[separar$Loc[len[1]]]
pt

plot(grid[row.names(grid)==list[1],])
plot(locrur[separar$Loc[len[1]],],add=T)

list<-unique(separar$grid)
for(i in list){
  len<-which(separar$grid==i)
  sumaZ1<-c()
  sumaZ22<-c()
  sumaZ51<-c()
  sumaZ52<-c()
  sumaZ61<-c()
  sumaZ64<-c()
  sumaZ70<-c()
  sumaZ77<-c()
  meanZ83<-c()
  sumaZ101<-c()
  sumaZ119<-c()
  sumaZ120<-c()
  sumaZ128<-c()
  sumaZ130<-c()
  sumaZ134<-c()
  sumaZ135<-c()
  sumaZ136<-c()
  sumaZ139<-c()
  sumaZ140<-c()
  sumaZ143<-c()
  sumaZ144<-c()
  sumaZ145<-c()
  sumaZ146<-c()
  sumaZ147<-c()
  sumaZ162<-c()
  meanZ163<-c()
  meanZ164<-c()
  sumaZ165<-c()
  sumaAnalf<-c()
  for(j in 1:length(len)){
    sumaZ1<-c(sumaZ1,(locrur$POBTOT_[separar$Loc[len[j]]]))
    sumaZ22<-c(sumaZ22,locrur$POB15__[separar$Loc[len[j]]])
    sumaZ51<-c(sumaZ51,locrur$PSDERSS[separar$Loc[len[j]]])
    sumaZ52<-c(sumaZ52,locrur$PDERIMS[separar$Loc[len[j]]])
    sumaZ61<-c(sumaZ61,locrur$P6_14SL[separar$Loc[len[j]]])
    sumaZ64<-c(sumaZ64,locrur$P15_ALF[separar$Loc[len[j]]])
    sumaZ70<-c(sumaZ70,locrur$P15_SINST[separar$Loc[len[j]]])
    sumaZ77<-c(sumaZ77,locrur$P15_SSE[separar$Loc[len[j]]])
    meanZ83<-c(meanZ83,locrur$GRADOES[separar$Loc[len[j]]])
    sumaZ101<-c(sumaZ101,locrur$PECOACT[separar$Loc[len[j]]])
    sumaZ119<-c(sumaZ119,locrur$TOTVIVH[separar$Loc[len[j]]])
    sumaZ120<-c(sumaZ120,locrur$VIVPARH[separar$Loc[len[j]]])
    sumaZ128<-c(sumaZ128,locrur$V_1CUAR[separar$Loc[len[j]]])
    sumaZ130<-c(sumaZ130,locrur$VP_CCUA[separar$Loc[len[j]]])
    sumaZ134<-c(sumaZ134,locrur$VP_COCG[separar$Loc[len[j]]])
    sumaZ135<-c(sumaZ135,locrur$VP_SERS[separar$Loc[len[j]]])
    sumaZ136<-c(sumaZ136,locrur$VP_DREN[separar$Loc[len[j]]])
    sumaZ139<-c(sumaZ139,locrur$VP_ELEC[separar$Loc[len[j]]])
    sumaZ140<-c(sumaZ140,locrur$VP_AGUEN[separar$Loc[len[j]]])
    sumaZ143<-c(sumaZ143,locrur$VP_DREA[separar$Loc[len[j]]])
    sumaZ144<-c(sumaZ144,locrur$VP_DREE[separar$Loc[len[j]]])
    sumaZ145<-c(sumaZ145,locrur$VP_AGUEL[separar$Loc[len[j]]])
    sumaZ146<-c(sumaZ146,locrur$VP_AGDR[separar$Loc[len[j]]])
    sumaZ147<-c(sumaZ147,locrur$VP_NOAD[separar$Loc[len[j]]])
    sumaZ162<-c(sumaZ162,locrur$VP_SBIE[separar$Loc[len[j]]])
    meanZ163<-c(meanZ163,locrur$PRO_OVP[separar$Loc[len[j]]])
    meanZ164<-c(meanZ164,locrur$PRO_OCV[separar$Loc[len[j]]])
    sumaZ165<-c(sumaZ165,locrur$TOTHOG_[separar$Loc[len[j]]])
    sumaAnalf<-c(sumaAnalf,locrur$P15_ANA[separar$Loc[len[j]]])
  }
  grid$Z1[row.names(grid)==i]<-sum(grid$Z1[row.names(grid)==i],sumaZ1,na.rm=T)
  grid$Z22[row.names(grid)==i]<-sum(grid$Z22[row.names(grid)==i],sumaZ22,na.rm=T)
  grid$Z51[row.names(grid)==i]<-sum(grid$Z51[row.names(grid)==i],sumaZ51,na.rm=T)
  grid$Z52[row.names(grid)==i]<-sum(grid$Z52[row.names(grid)==i],sumaZ52,na.rm=T)
  grid$Z61[row.names(grid)==i]<-sum(grid$Z61[row.names(grid)==i],sumaZ61,na.rm=T)
  grid$Z64[row.names(grid)==i]<-sum(grid$Z64[row.names(grid)==i],sumaZ64,na.rm=T)
  grid$Z70[row.names(grid)==i]<-sum(grid$Z70[row.names(grid)==i],sumaZ70,na.rm=T) 
  grid$Z77[row.names(grid)==i]<-sum(grid$Z77[row.names(grid)==i],sumaZ77,na.rm=T) 
  grid$Z83[row.names(grid)==i]<-mean(c(grid$Z83[row.names(grid)==i],meanZ83),na.rm=T)
  grid$Z101[row.names(grid)==i]<-sum(grid$Z101[row.names(grid)==i],sumaZ101na.rm=T)
  grid$Z119[row.names(grid)==i]<-sum(grid$Z119[row.names(grid)==i],sumaZ119,na.rm=T)
  grid$Z120[row.names(grid)==i]<-sum(grid$Z120[row.names(grid)==i],sumaZ120,na.rm=T)
  grid$Z128[row.names(grid)==i]<-sum(grid$Z128[row.names(grid)==i],sumaZ128,na.rm=T)
  grid$Z130[row.names(grid)==i]<-sum(grid$Z130[row.names(grid)==i],sumaZ130,na.rm=T)
  grid$Z134[row.names(grid)==i]<-sum(grid$Z134[row.names(grid)==i],sumaZ134,na.rm=T)
  grid$Z135[row.names(grid)==i]<-sum(grid$Z135[row.names(grid)==i],sumaZ135,na.rm=T)
  grid$Z136[row.names(grid)==i]<-sum(grid$Z136[row.names(grid)==i],sumaZ136,na.rm=T)
  grid$Z139[row.names(grid)==i]<-sum(grid$Z139[row.names(grid)==i],sumaZ136,na.rm=T)
  grid$Z140[row.names(grid)==i]<-sum(grid$Z140[row.names(grid)==i],sumaZ140,na.rm=T)
  grid$Z143[row.names(grid)==i]<-sum(grid$Z143[row.names(grid)==i],sumaZ143,na.rm=T)
  grid$Z144[row.names(grid)==i]<-sum(grid$Z144[row.names(grid)==i],sumaZ144,na.rm=T)
  grid$Z145[row.names(grid)==i]<-sum(grid$Z145[row.names(grid)==i],sumaZ145,na.rm=T)
  grid$Z146[row.names(grid)==i]<-sum(grid$Z146[row.names(grid)==i],sumaZ146,na.rm=T)
  grid$Z147[row.names(grid)==i]<-sum(grid$Z147[row.names(grid)==i],sumaZ147,na.rm=T)
  grid$Z162[row.names(grid)==i]<-sum(grid$Z162[row.names(grid)==i],sumaZ162,na.rm=T)
  grid$Z163[row.names(grid)==i]<-mean(c(grid$Z163[row.names(grid)==i],meanZ163),na.rm=T)
  grid$Z164[row.names(grid)==i]<-mean(c(grid$Z164[row.names(grid)==i],meanZ164),na.rm=T)
  grid$Z165[row.names(grid)==i]<-sum(grid$Z165[row.names(grid)==i],sumaZ165,na.rm=T)
  grid$Analf[row.names(grid)==i]<-sum(grid$Analf[row.names(grid)==i],sumaAnalf,na.rm=T)
}



summary(grid)

sum(grid$Z1,na.rm=T)-pob1 
sum(locrur$POBTOT_,na.rm=T)


trueCentroids <- gCentroid(grid,byid=TRUE)
#plot(grid)
summary(trueCentroids)
grid$lat<-coordinates(trueCentroids)[,2]
grid$lon <-coordinates(trueCentroids)[,1]

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/53/3. Grid Loc")
writeOGR(grid,".","grid500_censo2000","ESRI Shapefile")
