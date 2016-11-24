library(sp)
library(rpart)
library(maptree)
library(xtable)
library(randomForest)
library(mlbench)
library(gbm)
library(adabag)
library(glmnet)
library(ROCR)
library(ggplot2)
library(plyr)
library(tabplot)
library(rgdal)
library(verification)
library(AUC)

#________________________________________________________
# Modelos
#_______________________________________________________


rm(list=ls(all=T))
gc(reset=T)

setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/56/9.1 Grid FINAL 2")
#Leer las bases espaciales finales
grid10<-readOGR(dsn=".",layer="grid500_10FINALv")
grid00<-readOGR(dsn=".",layer="grid500_00FINALv2")
names(grid00)

#Si quiero poner la distancia al AGEB a cero dentro de la mancha urbana
grid00$DistAgeb[grid00$ZU_30c==1]<-0
grid10$DistAgeb[grid10$ZU_30c==1]<-0

#Revisar variable uso de suelo agrupado NUM_AGRUP
summary(grid00$NUM_AGRUP)
summary(grid10$NUM_AGRUP)


#Convertir a Dataframe 
dat00<-as.data.frame(grid00)
dat10<-as.data.frame(grid10)
names(dat00)
names(dat10)


#Elegir las variables para el modelo (si tiene ANP's o no cambia)
var<-c(3,5,11:13,24:33,35)
dat00_1<-dat00[,var]
#dat05_1<-dat05[,var]
var<-c(3,5,11:13,24:33)
dat10_1<-dat10[,var]
names(dat10_1)
names(dat00_1)
#names(dat05_1)

#Cambiar nombre a la variable a predecir
names(dat00_1)[16]<-c("Pred")


# Cambiar formato a factor de NUM_AGRUP, PRed y ANPE (en caso de que haya)
dat00_1$NUM_AGRUP<-factor(dat00_1$NUM_AGRUP, ordered=T, levels=c(1:10))
dat00_1$Pred<-factor(dat00_1$Pred)
dat10_1$NUM_AGRUP<-factor(dat10_1$NUM_AGRUP, ordered=T, levels=c(1:10))
dat00_1$ANPM<-factor(dat00_1$ANPM)
dat10_1$ANPM<-factor(dat10_1$ANPM)
dat00_1$ANPE<-factor(dat00_1$ANPE)
dat10_1$ANPE<-factor(dat10_1$ANPE)

# Genero Muestra aleatoria
#de 2000 a 2010- con muestras:
# 70% del total de 2000 es la muestra de entrenamiento 70%
# 30% muestra de validacion 
set.seed(297583)
num.tr<-nrow(dat00_1)*.7
train<-sample(c(1:nrow(dat00_1)),size=num.tr,replace=F)
 dat05_1<-dat00_1[-train,]
dat00_1<-dat00_1[train,]
nrow(dat05_1)
nrow(dat00_1)
grid00_tr<-grid00[train,]
grid00_te<-grid00[-train,]


#Analisis Exploratorio
# Porcentaje de zona urbana a predecir en la muestra de entrenamiento
sum(as.numeric(dat00_1$Pred)-1)/nrow(dat00_1)*100
# Porcentaje de zona urbana a predecir en la muestra de validación
sum(as.numeric(dat05_1$Pred)-1)/nrow(dat05_1)*100
nrow(dat00_1)
nrow(dat05_1)
nrow(dat10_1)
summary(dat00_1$NUM_AGRUP)
summary(dat05_1$NUM_AGRUP)
summary(dat10_1$NUM_AGRUP)

#____________________________________________________________
#Modelo Logit 
#____________________________________________________________

glm.1<-glm(Pred~., data=dat00_1, family="binomial",na.action=na.exclude)
summary(glm.1)
yglm.1<-predict(glm.1,type="response",na.action=na.exclude)
grid00_tr$Logit<-yglm.1
#Corte
yglm.f<- fitted(glm.1)>0.2
grid00_tr$LogitR<-yglm.f

#GEnero la Tabla muestra de entrenamiento
tab1.1<-table(yglm.f,dat00_1$Pred)
tab1.1
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab1.1,2)

#ROC train
roc_l_tr<-roc(yglm.1, dat00_1$Pred)
auc(roc_l_tr) #Guardar ROC-train
plot(roc_l_tr)

#__________________________________
#Para muestra de validación
yglm.1_prob<-predict(glm.1,newdata=dat05_1,type="response")
grid00_te$Logit<-yglm.1_prob
yglm.1_fit<-yglm.1_prob>0.2
grid00_te$LogitR<-yglm.1_fit
# Tabla 
tab1.2<-table(yglm.1_fit,dat05_1$Pred)
tab1.2
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab1.2,2)

#ROC test
roc_l_te<-roc(yglm.1_prob, dat05_1$Pred)
auc(roc_l_te) #Guardar Roc-Test
plot(roc_l_te,add=T,col="red")

#Predict 2015
yglm.2_prob<-predict(glm.1,newdata=dat10_1,type="response")
grid10$Logit<-yglm.2_prob
yglm.2_fit<-yglm.2_prob>0.2
summary(yglm.2_fit)
grid10$LogitR<-yglm.2_fit

#____________________________________________________________________________________________
#Arbol de Clasificacion
#____________________________________________________________________________________________
set.seed(928)
summary(dat00_1$Pred)
control.completo<-rpart.control(cp=0, minsplit=10, minbucket=1, xval=10, maxdepth=30)
spam_tree_completo<-rpart(Pred~.,data = dat00_1, method="class",control = control.completo)
spam_tree_completo$cp
#Podar el árbol
minerr<-min(spam_tree_completo$cp[,4])
mincp<-spam_tree_completo$cp[which(spam_tree_completo$cp[,4]==minerr),1]
mincp[length(mincp)]
spam_tree_podado <- prune(spam_tree_completo,cp= mincp[length(mincp)])
print(spam_tree_podado)
printcp(spam_tree_podado)
plotcp(spam_tree_podado)

#Entrenamiento (Train)
grid00_tr$Tree<-predict(spam_tree_podado,type='class')
tab.tree1<-table(predict(spam_tree_podado,type='class'),dat00_1$Pred)
tab.tree1
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab.tree1,2)

#ROC Train
roc_t_tr<-roc(predict(spam_tree_podado,type='prob')[,2], dat00_1$Pred)
auc(roc_t_tr) #Guardar ROC-Train
plot(roc_t_tr)

#______________________________________
#Validar con la muestra de prueba (test)
pred10<-predict(spam_tree_podado,newdata=dat05_1,type='class')
grid00_te$Tree<-pred10
#Tabla de porcentaje de aciertos y errores
tab.tree2<-table(pred10,dat05_1$Pred)
tab.tree2
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab.tree2,2)

#ROC- Test
roc_t_te<-roc(predict(spam_tree_podado,newdata=dat05_1,type='prob')[,2], dat05_1$Pred)
auc(roc_t_te) #Guardar ROC-Test
plot(roc_t_te,add=T,col="red")

#Predecir para 2020
pred15<-predict(spam_tree_podado,newdata=dat10_1,type='class')
grid10$Tree<-pred15


#____________________________________________________________________________________
# Bosque Aleatorio
#____________________________________________________________________________________
set.seed(121289)
#cambiando m y num de arbols
bosque_urb2<-randomForest(Pred~.,data=dat00_1,ntree=2000,mtry=2,na.action=na.roughfix)
bosque_urb4<-randomForest(Pred~.,data=dat00_1,ntree=2000,mtry=4,na.action=na.roughfix)
bosque_urb6<-randomForest(Pred~.,data=dat00_1,ntree=2000,mtry=6,na.action=na.roughfix)
bosque_urb8<-randomForest(Pred~.,data=dat00_1,ntree=2000,mtry=8,na.action=na.roughfix)
bosque_urb10<-randomForest(Pred~.,data=dat00_1,ntree=2000,mtry=10,na.action=na.roughfix)

#Tablas de correctos con la muestra de validacion-> escoger la que mejor resultado de
table(predict(bosque_urb10, newdata=dat05_1),dat05_1$Pred)
table(predict(bosque_urb8, newdata=dat05_1),dat05_1$Pred)
table(predict(bosque_urb6, newdata=dat05_1),dat05_1$Pred)
table(predict(bosque_urb4, newdata=dat05_1),dat05_1$Pred)
table(predict(bosque_urb2, newdata=dat05_1),dat05_1$Pred)

#El mejor bosque (escogo el mtry que se haya desempeñado mejor arriba de acuerdo a las tablas de validación)
set.seed(2015)
bosque_UrbB<-randomForest(Pred~.,data=dat00_1,ntree=2000,mtry=10,na.action=na.roughfix)
min(bosque_UrbB$err.rate[,1])
print(bosque_UrbB)
varImpPlot(bosque_UrbB)
bosque_UrbB$type
importance(bosque_UrbB)

#Entrenamiento (Train)
grid00_tr$Forest<-bosque_UrbB$predict
tab.f<-table(predict(bosque_UrbB),dat00_1$Pred)
tab.f
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab.f,2)

#ROC Train
roc_b_tr<-roc(predict(bosque_UrbB,type='prob')[,2], dat00_1$Pred)
auc(roc_b_tr) #Guardar Roc-Train
plot(roc_b_tr)

#______________________
#Validación- test
tab.f2<-table(predict(bosque_UrbB, newdata=dat05_1),dat05_1$Pred)
tab.f2
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab.f2,2)
grid00_te$Forest<-predict(bosque_UrbB,newdata=dat05_1)


#ROC- test
roc_b_te<-roc(predict(bosque_UrbB,newdata=dat05_1,type='prob')[,2], dat05_1$Pred)
auc(roc_b_te) #Guardar ROC-test
plot(roc_b_te,add=T,col="red")

#Predecir para 2020
grid10$Forest<-predict(bosque_UrbB,newdata=dat10_1)


#-------------------------------------------------------------------------------------
#Redes Neuronales
#-------------------------------------------------------------------------------------
library(MASS)
library(nnet)
library(plyr)

set.seed(1212909)
summary(dat00_1$Pred)
# Cambiando parámetros aproximadamente de size (entre 2 y 4) y decay (entre 0.001 y 1)
red.1<-nnet(Pred~.,data=dat00_1,size=4,decay=1,maxit=1000,MaxNWts=10000,trace=F)
qplot(predict(red.1,dat00_1))

#Entrenamiento- train
tab.red<-table(predict(red.1, dat00_1,type="class"),dat00_1$Pred)
tab.red
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab.red,2)
grid00_tr$RedNeuronal<-predict(red.1,dat00_1,type="class")


#ROC-train
roc_r_tr<-roc(predict(red.1,dat00_1,type="raw"), dat00_1$Pred)
auc(roc_r_tr) #Guardar Roc-Train
plot(roc_r_tr)

#______________________________________
#Muestra de Validación- test
tab.red2<-table(predict(red.1,dat05_1,type="class"),dat05_1$Pred)
tab.red2
# Proporción de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab.red2,2)
grid00_te$RedNeuronal<-predict(red.1,dat05_1,type="class")

#ROC- test
roc_r_te<-roc(predict(red.1,dat05_1), dat05_1$Pred)
auc(roc_r_te) #Guardar ROC-test
plot(roc_r_te,add=T,col="red")

#PRedecir para 2020
grid10$RedNeuronal<-predict(red.1,dat10_1,type="class")


#Guardo mis grids
setwd("C:/Users/Andrea Navarrete/Desktop/tesis_/Zonas Metropolitanas/56/10. Modelos")
writeOGR(grid00_tr,".","grid1000_00FINAL_RES_tr","ESRI Shapefile")
writeOGR(grid00_te,".","grid1000_00FINAL_RES_te","ESRI Shapefile")
writeOGR(grid10,".","grid1000_10FINAL_RES","ESRI Shapefile")

summary(grid10$LogitR)


