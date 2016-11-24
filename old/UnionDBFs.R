library(foreign)

setwd("C:/Users/Andrea Navarrete/Desktop/Info_SCINCE_2000/14.Leon")

directory<-"C:/Users/Andrea Navarrete/Desktop/Info_SCINCE_2000/14.Leon"
files<-dir(directory)

doc<-read.dbf(files[1],as.is=T)
summary(doc)



for(i in 2:length(files)){
  d<-read.dbf(files[i])
  doc<-rbind(doc,d)
}
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Censos/Censo 2000 urbano/15")
write.csv(doc,"Censo2000.csv",na="*")


