library(rgdal)
library(sp)
library(rgeos)
library(maptools)
library(gpclib)
library(PBSmapping)
#
setwd("~/Documents/tesis/CambioUsodeSuelo/ZM/ZMCHIH")
sp10<-readOGR(".",layer="ZMC_AGEBS")
sp05<-readOGR(".",layer="Agebs2005_ZMChih")
sp00<-readOGR(".",layer="Agebs2000_ZMChih")
proj4string(sp05)
proj4string(sp10)
projGeos<-CRS(proj4string(sp10))
proj4string(sp00)
sp05_2<-spTransform(sp05,projGeos)
sp00_2<-spTransform(sp00,projGeos)
plot(sp00)
plot(sp10,col="red")
plot(sp05_2,col="blue",add=T)
plot(sp00_2,col="green",add=T)
writeOGR(sp05_2,".","Agebs2005_ZMChih_2","ESRI Shapefile")
writeOGR(sp00_2,".","Agebs2000_ZMChih_2","ESRI Shapefile")
#Leer Chihuahua
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo/ZM")
ChihZM<-readOGR(dsn=".",layer="ZM_Chih")
plot(ChihZM)
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo")
Chih_AH_s3<-readOGR(".",layer="Chih_s3_AH")
Chih_AH_s4<-readOGR(".",layer="Chih_s4_AH")
Chih_AH_s5<-readOGR(".",layer="Chih_s5_AH")

CH_ZM_AH_s3<-gIntersection(Chih_AH_s3,ChihZM)
CH_ZM_AH_s4<-gIntersection(Chih_AH_s4,ChihZM)
CH_ZM_AH_s5<-gIntersection(Chih_AH_s5,ChihZM)

plot(ChihZM)
plot(CH_ZM_AH_s5,col="darkcyan")
plot(CH_ZM_AH_s4,add=T,col="yellow")
plot(CH_ZM_AH_s3,add=T,col="magenta")



#Leon
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo/ZM")
LeonZM<-readOGR(dsn=".",layer="ZM_Leon")
plot(LeonZM)
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo")
Gto_AH_s3<-readOGR(".",layer="Gto_s3_AH")
Gto_AH_s4<-readOGR(".",layer="Gto_s4_AH")
Gto_AH_s5<-readOGR(".",layer="Gto_s5_AH")

plot(LeonZM)
plot(Gto_AH_s5,add=T,col="darkcyan")
plot(Gto_AH_s4,add=T,col="yellow")
plot(Gto_AH_s3,add=T,col="magenta")


setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo/Guana")
AGEB_GTO<-readOGR(dsn=".",layer="GTO_ageb_urb")
plot(AGEB_GTO,add=T)
AGEB_Leon<-gIntersection(AGEB_GTO,LeonZM,drop_not_poly=T)
names(AGEB_GTO)

setwd("/Users/andreanavarrete/Documents/mapa_digital_5.0.A/marco geoestadistico nacional 2010")
q<-readOGR(".",layer="loc_urb")
plot(q)
names(q)
q2<-q[,1:7]
writeOGR(q2,".","LocalidadesUrb","ESRI Shapefile")
Edos<-readOGR(".",layer="EstadosRep")
names(Edos)
plot(Edos)
Loc<-readOGR(".",layer="LocalidadesUrb")
LeonMun<-Loc[Loc$NOM_MUN=="Le\303\263n",]
plot(LeonMun,add=T)
plot(Leon_AH_s3)
LocGto<-Loc[Loc$NOM_ENT=="Guanajuato",]
setwd("/Users/andreanavarrete/Documents/scince2010/shps/gto")
gtoAGEBS<-readOGR(".",layer="gto_ageb_urb")
names(gtoAGEBS)
plot(gtoAGEBS)

#Proyecciones
proj4string(LeonZM)
proj4string(LeonMun)
proj4string(Leon_AH_s3)
proj4string(Edos)
library(rgdal)
projGeos<-CRS(proj4string(Edos))
LeonZM2<-spTransform(LeonZM,projGeos)

Gto_s3<-spTransform(Gto_AH_s3,projGeos)
Gto_s4<-spTransform(Gto_AH_s4,projGeos)
Gto_s5<-spTransform(Gto_AH_s5,projGeos)
plot(LeonZM2)
plot(Gto_s3,add=T,col="darkcyan")
plot(Gto_s5,add=T,col="yellow")
summary(Gto_s4)



LeonAH_s3<-gIntersection(Gto_s3,LeonZM2,byid=T)
LeonAH_s4<-gIntersection(Gto_s4,LeonZM2,byid=T)
LeonAH_s5<-gIntersection(Gto_s5,LeonZM2,byid=T)
LeonAGEBS<-gIntersection(gtoAGEBS,LeonZM2,byid=T)


plot(LeonZM2)
plot(LeonMun,add=T)
plot(LeonAH_s5,add=T,col="darkcyan")
plot(LeonAH_s4,add=T,col="yellow")
plot(LeonAH_s3,add=T,col="magenta")
plot(LeonAGEBS,add=T)


#Ver en Google
library(plotGoogleMaps)
m<-plotGoogleMaps(s5_2,zcol="DESCRIPCIO")
m2<-plotGoogleMaps(gtoAGEBS,add=T)

#Series de Uso de Suelo
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo")
s3<-readOGR(".",layer="Guanajuato_s3")
s4<-readOGR(".",layer="Guanajuato_s4")
s5<-readOGR(".",layer="Guanajuato_s5")

s3_2<-spTransform(s3,projGeos)
s4_2<-spTransform(s4,projGeos)
s5_2<-spTransform(s5,projGeos)

writeOGR(s3_2,".","s3_Gto_2","ESRI Shapefile")
writeOGR(s4_2,".","s4_Gto_2","ESRI Shapefile")
writeOGR(s5_2,".","s5_Gto_2","ESRI Shapefile")

#Chihuahua
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo")
s3c<-readOGR(".",layer="Chihuahua_s3")
s4c<-readOGR(".",layer="Chihuahua_s4")
s5c<-readOGR(".",layer="Chihuahua_s5")

s3_2c<-spTransform(s3c,projGeos)
s4_2c<-spTransform(s4c,projGeos)
s5_2c<-spTransform(s5c,projGeos)
proj4string(s5_2c)

writeOGR(s3_2c,".","s3_Chih_2","ESRI Shapefile")
writeOGR(s4_2c,".","s4_Chih_2","ESRI Shapefile")
writeOGR(s5_2c,".","s5_Chih_2","ESRI Shapefile")

#ZonaMetpropolitanas
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo/ZM")
ZML<-readOGR(".",layer="ZM_Leon")
ZML2<-spTransform(ZML,projGeos)
ZMC<-readOGR(".",layer="ZM_Chih")
ZMC2<-spTransform(ZMC,projGeos)
writeOGR(ZML2,".","/ZMLEON/ZM_Leon","ESRI Shapefile")
writeOGR(ZMC2,".","/ZMCHIH/ZM_Chih","ESRI Shapefile")
#-------------------------------------------------------------

names(s5_2)

Leon_s3<-gIntersection(s3_2,LeonZM2,byid=T)
Leon_s4<-gIntersection(s4_2,LeonZM2,byid=T)
Leon_s5<-gIntersection(s5_2,LeonZM2,byid=T)
summary(Leon_s5)
