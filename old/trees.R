library(rpart)
library(rpart.plot)
library(party)
library(partykit)
library(caret)
library(rattle)
library(RColorBrewer)

data(segmentationData)
data<-segmentationData[,-c(1,2)]

form<-as.formula(Class ~ .)
tree.1<-rpart(form,data=data,control=rpart.control(minsplit=20,cp=0))
plot(tree.1)
text(tree.1)
prp(tree.1)
prp(tree.1,varlen=3)

tree.2<-rpart(form,data)
prp(tree.2)
fancyRpartPlot(tree.2)

rx.tree<-rxDTree(form,data)
