# Import packages
require(yaml) 
require(sp)
require(RPostgreSQL)
require(postGIStools)
library(randomForest)

Connect2PosgreSQL <- function(config){
  dbname = config$db$database
  host = config$db$host
  user = config$db$user
  pass = config$db$password
  
  ## Connect to db
  con = dbConnect(drv = dbDriver("PostgreSQL"), 
                  dbname = config$db$database, host = config$db$host, 
                  port = config$db$port, user = config$db$user, 
                  password = config$db$password)
  return(con)
}


ReadData <- function(config, year){
  ##Read config file
  config = yaml.load_file("../config.yaml")
  #Read experiment
  experiment = yaml.load_file("../experiment.yaml")
  
  # Get features
  features_df = plyr::ldply (experiment$Features, data.frame, stringsAsFactors=FALSE)
  colnames(features_df) <- c('feature_name','keep')
  #keep only the TRUE values
  features = features_df$feature_name[features_df$keep == TRUE]
  features = paste(features,  collapse = ', ')
  # Features and labels table name
  grid_size = experiment$grid_size
  features_table_name = sprintf('%s_%s', experiment$features_table_name,
                                          grid_size)
  labels_table_name = sprintf('%s_%s_%s', experiment$labels_table_name,
                                          experiment$intersect_percent,
                                          grid_size)
  
  features_query = sprintf("SELECT cell_id, %s, label::bool
                            FROM  features.%s 
                            JOIN features.%s
                            USING (cell_id, year)
                            JOIN %s.grid
                            USING (cell_id)
                            JOIN preprocess.buffer_%s
                            ON st_intersects(cell, buffer_geom)
                            WHERE year = '%s' ", features,
                                                 features_table_name,
                                                 labels_table_name,
                                                 grid_size,
                                                 year,
                                                 year
                           )
  conn = Connect2PosgreSQL(config)
  data = get_postgis_query(conn, features_query)
  dbDisconnect(conn)
  rownames(data) <- data$cell_id
  data$label = factor(data$label)
  data = data[ , !(names(data) %in% c('cell_id'))]
  return (data)
}

StoreModel <-function(model_type, year, features, comment,
                      parameters, grid_size, intersect_percent){
  query_insert = sprintf("INSERT INTO results.models(
                               model_type, 
                               model_parameters, 
                               features,
                               year_train,
                               grid_size,
                               intersect_percent,
                               model_comment)
                         VALUES('%s', '%s'::JSONB, array[%s], '%s', '%s', %s, '%s')",
                        model_type,
                        parameters, 
                        paste(sprintf("'%s'", features), sep="", collapse=","),
                        year,
                        grid_size,
                        intersect_percent,
                        comment)
  
  query_model_id = "Select max(model_id) as model_id from results.models"
  # Conncet and send
  con = Connect2PosgreSQL(config)
  dbSendQuery(con, query_insert)
  dbCommit(con)
  model_id = get_postgis_query(con, query_model_id)$model_id
  dbDisconnect(con)
  return (model_id)
}


StorePredictions <- function(year, scores, model_id){
  query_insert = sprintf("INSERT INTO results.predictions(
                               model_id, 
                               year_test, 
                               cell_id,
                               score,
                               label)
                         VALUES(%s, '%s', %s, %s, %s)",
                         model_id,
                         year, 
                         scores$cell_id,
                         scores$score,
                         scores$label)
  con = Connect2PosgreSQL(config)
  
  sendQuery <- function(query) dbSendQuery(con, query)
  lapply(query_insert, sendQuery)
  #dbSendQuery(con, query_insert)
  dbCommit(con)
  dbDisconnect(con)
  
}

RFParameters2String <- function(ntree,maxnodes, mtry, strata,
                                proximity, replace, nodesize ){
  parameters = sprintf('{"ntree": %s, "maxnode": %s, "mtry": %s, "strata": "%s", "proximity": "%s","replace": "%s", "nodesize": %s}',
                       ntree, maxnodes, mtry, strata,
                       proximity, replace, nodesize)
  return (parameters)
}

RFmodels <- function(ntree, maxnodes, mtry, strata,
                     proximity, replace, nodesize){
  # Train Model
  rows = nrow(train)
  if (rows > 1000000) {
    rf1 <- randomForest(formula=label~.,data=train[1:((rows)/2), ], ntree=ntree,
                        mtry=mtry, maxnode=maxnode,
                       strata=strata, proximity=proximity, 
                        replace=replace, nodesize=nodesize)
    
    rf2 <- randomForest(formula=label~.,data=train[(((rows)/2) +1):rows, ], ntree=ntree, 
                        mtry=mtry, maxnode=maxnode,
                        strata=strata, proximity=proximity, 
                        replace=replace, nodesize=nodesize)
    rf <- combine(rf1,rf2)
  }
  else {
    rf <- randomForest(formula=label~.,data=train, 
                       ntree=ntree, 
                       mtry=mtry,
                       maxnodes=maxnodes,
                       strata=strata, 
                       proximity=proximity, 
                       replace=replace,
                       nodesize=nodesize
                       )
  } 
  # Store model
  parameters = RFParameters2String(ntree,maxnodes, mtry, strata,
                                   proximity, replace, nodesize)
  
  model_id = StoreModel('RandomForest', '2000', features, comment,
               parameters, grid_size, intersect_percent)
  
  # Test Model
  rf_test = data.frame(score = predict(rf, newdata=test, type='prob')[,2])
  rf_test$cell_id = rownames(rf_test)
  scores = merge(rf_test, test, by=0, all=TRUE)[ ,c('score','label', 'cell_id')]
  StorePredictions('2005', scores, model_id)
  
  # Validate model
  rf_val = data.frame(score = predict(rf, newdata=validation, type='prob')[,2])
  rf_val$cell_id = rownames(rf_val)
  scores = merge(rf_val, validation, by=0, all=TRUE)[ ,c('score','label')]
  StorePredictions('2010', scores, model_id)
}


RF <- function(config, experiment){
  # Function parameters
  ntree <- function(l) l[['RandomForest']][['ntree']]
  maxnodes <- function(l) l[['RandomForest']][['maxnodes']]
  mtry <- function(l) l[['RandomForest']][['mtry']]
  strata <- function(l) l[['RandomForest']][['strata']]
  proximity <- function(l) l[['RandomForest']][['proximity']]
  replace <- function(l) l[['RandomForest']][['replace']]
  nodesize <- function(l) l[['RandomForest']][['nodesize']]
  # grid
  rf_grid = expand.grid(ntrees= ntree(experiment),
                        maxnodes= maxnodes(experiment),
                        mtries = mtry(experiment),
                        stratas = strata(experiment),
                        proximities = proximity(experiment),
                        replaces = replace(experiment),
                        nodesizes = nodesize(experiment)) 
  # Run models 
  qq = mapply(RFmodels, rf_grid$ntrees, rf_grid$maxnodes, rf_grid$mtries,
              rf_grid$stratas, rf_grid$proximities, rf_grid$replaces, rf_grid$nodesizes)
  
}



#____________________________________________________________
#____________________________________________________________
##Read config file
config = yaml.load_file("../config.yaml")
#Read experiment
experiment = yaml.load_file("../experiment.yaml")

# Get features
features_df = plyr::ldply (experiment$Features, data.frame, stringsAsFactors=FALSE)
colnames(features_df) <- c('feature_name','keep')
#keep only the TRUE values
features = features_df$feature_name[features_df$keep == TRUE]
# more params
grid_size = experiment$grid_size
comment = experiment$comment
intersect_percent = experiment$intersect_percent

train = ReadData(config, '2000')
test = ReadData(config, '2005')
validation = ReadData(config, '2010')

# Get Models
models = experiment$model_type

if ("RandomForest" %in% models){RF(config, experiment)}








glm.1<-glm(Pred~., data=dat00_1, family="binomial",na.action=na.exclude)
summary(glm.1)
yglm.1<-predict(glm.1,type="response",na.action=na.exclude)
grid00_tr$Logit<-yglm.1
#Corte
yglm.f<- fitted(glm.1)>0.2
grid00_tr$LogitR<-yglm.f

#__________________________________
#Para muestra de validaci?n
yglm.1_prob<-predict(glm.1,newdata=dat05_1,type="response")
grid00_te$Logit<-yglm.1_prob
yglm.1_fit<-yglm.1_prob>0.2
grid00_te$LogitR<-yglm.1_fit

#____________________________________________________________________________________________
#Arbol de Clasificacion
#____________________________________________________________________________________________
set.seed(928)
summary(dat00_1$Pred)
control.completo<-rpart.control(cp=0, minsplit=10, minbucket=1, xval=10, maxdepth=30)
spam_tree_completo<-rpart(Pred~.,data = dat00_1, method="class",control = control.completo)
spam_tree_completo$cp
#Podar el ?rbol
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
# Proporci?n de correctos (el valor inferior del lado izquiero es el PCC)
prop.table(tab.tree1,2)

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
