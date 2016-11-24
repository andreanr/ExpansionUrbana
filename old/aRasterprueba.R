library("rgdal")
library(raster)
setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo")
s5<-readOGR(".",layer="s5_Chih_2")
summary(s5)
setwd("~/Documents/CAPA_UNION_SV 2/CAPA_UNION")
s5toda<-readOGR(".",layer="usv250s5_union")
summary(s5toda)
qq<-as.data.frame(unique(s5toda$CVE_UNION))
ee<-as.data.frame(unique(s5toda$DESCRIPCIO))
qqee<-cbind(qq,ee)
#write.csv(qqee,"TiposdeSuelo_s5.csv")

setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo/Nuevo")
t3<-readOGR(".",layer="t3")
q1<-as.data.frame(unique(t3$T3_TIPO_LE))
q2<-as.data.frame(unique(t3$T3_COM_LEY))
write.csv(q2,"TiposdeSuelo_s3.csv")



setwd("~/Google Drive Andrea/tesis/CambioUsodeSuelo/ZM/ZMCHIH")
shp<-readOGR(".",layer="ZM_Chih")
ZMs5<-crop(s5,shp)
summary(ZMs5)
proj4string(ZMs5)

bb<-bbox(ZMs5)
bb
ext<-extent(-107,-103,27,32)
xy<-abs(apply(as.matrix(bbox(ext)),1,diff))
n<-100
r<-raster(ext,ncol=xy[1]*n,nrow=xy[2]*n)
rr<-rasterize(ZMs5,r)
plot(rr,xlim=c(-107,-103),ylim=c(27,32))
summary(rr)


library(maptools)

Reg<-SpatialPolygons2PolySet(ZMs5)
plotPolys(Reg,projection="LL")
summary(Reg)
theProjection <- proj4string(ZMs5)

boundingVals <- ZMs5@bbox
deltaLong <- as.integer((boundingVals[1,2] -
                           boundingVals[1,1]) + 1.5)
deltaLat <- as.integer((boundingVals[2,2] - 
                          boundingVals[2,1]) + 1.5)
gridRes <- 0.01
gridSizeX <- deltaLong / gridRes
gridSizeY <- deltaLat / gridRes
GridTopoOneDeg <- GridTopology(boundingVals[,1],
                               c(gridRes,gridRes),
                               c(gridSizeX,gridSizeY))
SampGridOneDeg <- SpatialGrid(GridTopoOneDeg,
                              proj4string = CRS(theProjection))
SampPointsOneDeg <- as(as(SampGridOneDeg,"SpatialPixels"),
                       "SpatialPoints")
OneDegPointsZM <-overlay(ZMs5,SampPointsOneDeg)

plot(OneDegPointsZM)
plot(SampPointsOneDeg)
flags = !is.na(OneDegPointsZM[,"OBJECTID"]) 
OneDPtsZM<-OneDegPointsZM[flags,]
summary(OneDPtsZM)
PtsZM_SP<-cbind(OneDPtsZM,SampPointsOneDeg[flags,]@coords)
coordinates(PtsZM_SP)<-cbind(PtsZM_SP[,4],PtsZM_SP[,5])
spplot(PtsZM_SP)
class(PtsZM_SP)

