gc(reset=T)


#_______________________________________________________________________________________________
#En este script se une la información del CENSO 2000 y 2010 con los polígonos de cada ciudad
#_______________________________________________________________________________________________



#Cambiar dirtectorio de acuerdo a la ciudad
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Censos/Censo 2010 urbano/48")


#Si una ciudad pertenece a más estados utilizar esto:
# censo1<-read.table("Censo2010_1.txt", sep="\t",header=T,na.strings = c("*","N/D"),colClasses=c(rep("factor",8)))
# censo2<-read.table("Censo2010_2.txt", sep="\t",header=T,na.strings = c("*","N/D"),colClasses=c(rep("factor",8)))
# censo3<-read.table("Censo2010_3.txt", sep="\t",header=T,na.strings = c("*","N/D"),colClasses=c(rep("factor",8)))
# censo<-rbind(censo1,censo2)

#Si la ciudad pertenece a un solo estado:
censo<-read.table("Censo2010.txt", sep="\t",header=T,na.strings = c("*","N/D"),colClasses=c(rep("factor",8)))

#Crear clave por AGEB
censo$CVEGEO<-paste(censo$ENTIDAD,censo$MUN,censo$LOC,censo$AGEB,sep="")
#Checar si sí se hizo bien
head(censo$CVEGEO)

#Elimina las observaciones por Manzana
dejar<-grep("000",censo$MZA)
censo2<-censo[dejar,]
q<-grep("0000",censo2$AGEB)
length(q)
censo2<-censo2[-q,]



censoAGEB<-censo2
names(censoAGEB)
#Escojo las variables
var<-c(201,10,25,57,58,61,107,110,113,116,122,131,134,143,146,148,165:170,
       173:174,176,177,179,182:190)-1
censoAGEB_2<-censoAGEB[,var]
names(censoAGEB_2)
head(censoAGEB$CVEGEO)
summary(censoAGEB_2)

write.csv(censoAGEB_2,"Censo_AGEBSt.csv")
write.table(censoAGEB_2, "Censo_AGEBSt.txt", sep="\t")


#__________________________________________________________________________
#merge shape y dataframe
#__________________________________________________________________________
library("rgdal")
library("sp")

#Leo el archivo del Censo creado arriba
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Censos/Censo 2010 urbano/48")
df<-read.table("Censo_AGEBSt.txt",header=T,sep="\t",na.string="NA")

#Leo el shape de los polígonos de la ciudad
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/48")
sp<-readOGR(".",layer="AGEBS2010_48")
plot(sp)
names(sp)
#Elimino las dempas columnas, dejando sólo la columna con la clave
sp2<-sp[,2]
summary(sp2)


#merge (checar que el shape y el dataframe del censo tengan el mismo nombre y formato de clave)

#Nombre de la variable clave
by<-c("CVEGEO")
#Merge
sp2@data<-data.frame(sp2@data,df[match(sp2@data[,by],df[,by]),])
summary(sp2)


#Si aparecen NA checar cuales son
faltantes<-sp[is.na(sp$CVEGEO.1),]


#Se Transforma de coordenadas de acuerdo a la UTM de cada ciudad #4487 es para la zona 14
sp3<-spTransform(sp2,CRS("+init=epsg:4487"))
proj4string(sp3)<-CRS("+init=epsg:4487")
plot(sp3)
proj4string(sp3)
#write 
summary(sp3)
writeOGR(sp3,".","AGEBS2010var_prj","ESRI Shapefile")
spplot(sp2[,3])


#____________________________________________________________________________
#2000
#____________________________________________________________________________


setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Censos/Censo 2000 urbano/48")
censo<-read.table("Censo2000.csv",header=T,na.strings=c("*","N.D."),sep=",")
names(censo)
summary(censo)
var<-c(3,4,25,54:55,64,67,73,80,86,103,104,106,122:124,126,129,131,133,136:144,146:150,165:168)-2
-2
censo00var<-censo[,var]
names(censo00var)
summary(censo00var)

write.table(censo00var, "censo00var.txt", sep="\t")
#merge
library(rgdal)
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/48")
sp<-readOGR(".",layer="AGEBS2000_48")
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Censos/Censo 2000 urbano/48")
summary(sp)
names(sp)


#Si la clave viene "011234444102-3" cambia el formato para quitarle el guión y coincidan
#sp$CLAVE<-sp$CVEGEO
clav<-sp$CLVAGB
clav<-as.character(clav)
head(clav)
separar<-(strsplit(clav,"-"))
separar<-as.data.frame(t(as.data.frame((separar))))
pegar<-as.factor(paste(separar[,1],separar[,2], sep=""))
sp$CLAVE<-pegar
summary(sp)
names(sp)
#sp2<-sp[,4]

#sp2 solo incluye la variable de clave
sp2<-sp[,163]

df<-censo00var
names(df)
names(sp2)
summary(df)


#La variable de unión es CLAVE tiene que venir en el sp2 y en el df (dataframe)
summary(df$CLAVE)
by<-c("CLAVE")
sp2@data<-data.frame(sp2@data,df[match(sp2@data[,by],df[,by]),])
summary(sp2)
names(sp2)

#Si faltan
q<-sp2$CLAVE[is.na(sp2$CLAVE.1)]
q2<-as.data.frame(q)
write.csv(q2,"Faltan.csv")


#plot
spplot(sp2[,3])

#Crear variable de analfabetismo 15 años y más
summary(sp2$Z64)
summary(sp2$Z22)
sp2$Analf<-sp2$Z22-sp2$Z64
summary(sp2$Analf)

#Se Transforma de coordenadas de acuerdo a la UTM de cada ciudad #4487 es para la zona 14
sp3<-spTransform(sp2,CRS("+init=epsg:4487"))
proj4string(sp3)<-CRS("+init=epsg:4487")


setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/AGEBS/31")
writeOGR(sp3,".","AGEBS2000var_prj","ESRI Shapefile")
