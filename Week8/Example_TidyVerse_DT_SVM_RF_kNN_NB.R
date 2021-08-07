##

#install.packages("tidyverse")
library(tidyverse)
library(magrittr)
library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(Cairo)
library(forcats)
library(dplyr)
library(stringr)
#install.packages("e1071")
library(e1071)
#install.packages("mlr")
library(mlr)
# install.packages("caret")
library(caret)
#install.packages("naivebayes")
library(naivebayes)

setwd("C:\\Users\\jerem\\Google Drive\\Online\\iCuse\\IST707\\Week8")

## Read in the data
## The readr package in tidyverse will be used

FedDF <- read_csv("fedPapers85.csv", skip=0, comment="#", col_names=TRUE)
## NOTE: read_csv is for comma sep
##       read_csv2 is for semi-colon sep
##       read_tsv is for tab sep

(head(FedDF, n=15))
## type dbl means double which is a long decimal number
(head(FedDF[1], n=15))

## Now - let's think about the data and our goals.
## We can see from looking at the first 15 rows and a few columns
## that this data is labeled. 
## Column 1 is the label!
## Column 2 is the name of file - this *not* the label ;)
## Columns 3 - ... are all words that appear and their
## normalized value.

## Our goal is to train a ML method to predict the disputed
## author values.

## This means that we need TWO datasets - the first is our test
## set, which is JUST the dispt rows.

## The other is the training set, which is all other rows EXCEPT
## the dispt

## Let's take our FedDF can use it to create these test and train
## sets....

#####  CREATE TEST SET (just dispt) and TRAIN SET (all others) ####
Fed_TEST <- filter(FedDF, author=="dispt")
Fed_TRAIN <- filter(FedDF, author != "dispt")
## Check yourself!
(Fed_TEST)
(head(Fed_TRAIN, n=20))

## Next, notice that the name of the file is not something we will
## use, AND it will disturb any ML technique because it 
## is a label (in a sense - but not really) and it has no other
## information. 

## Remove COlumn 2 in both the TEST and TRAIN set.
(Fed_TEST[2])

Fed_TEST <- Fed_TEST[-2]
Fed_TRAIN <- Fed_TRAIN[-2]
(Fed_TEST)
(head(Fed_TRAIN, n=20))

## OK! This looks better - now we have numeric data and we have 
## labels

##  !!!  HOWEVER !!!
## In R, labels MUST be of type "factor". A factor in R is a 
## category - which is what a label is.

## Right now - the type is chr - this means character.
## But why does this matter??

## Because from R's perspective, each char name is distinct
## In other words, if you train without changing this, R will think
## that each row is unique. This will not allow you to recognize
## catergories - because you have not defined any :)

## So - we must change "author" (our label) to a factor type
## in TEST and TRAIN

## This is from the dplyr package....
## if its a char, change it to factor
str(Fed_TEST)
str(Fed_TRAIN)
Fed_TEST <- mutate_if(Fed_TEST, is.character, as.factor)
str(Fed_TEST)

Fed_TRAIN <- mutate_if(Fed_TRAIN, is.character, as.factor)
str(Fed_TRAIN)

## RIght now, there are 4 levels or cataegories. Later, we may change this...

## Next - and we should have done this first! is we must make
## sure there are no NAs
## Both of the following give a "0" confirming no NAs
(sum1 <- sum(is.na(Fed_TEST)))
(sum2 <- sum(is.na(Fed_TRAIN)))

## Now- let's check the data - NEVER ASSUME THAT DATA IS CLEAN OR READY TO USE!

str(Fed_TEST)
### Hmmmm - the above is NOT going to work as a test set - WHY??
### We forgot to remove the label!!
(Fed_TEST <- Fed_TEST[-1])

str(Fed_TRAIN)
#### Here we have a problem as well - what is it??
#### Did you notice that we have "4" factors for author??
#### This is not right!
## We should only have three - let's use table to take a closer look
(table(Fed_TRAIN$author))
## We found it!
## "HM" should NOT be there. We need to fix this.

## In addition, we have unbalanced data. 
## An idea is to remove Jay, sample Hamilton,
## and create a training set of 50% Ham and 50% Mad...

## using....library(dplyr)
## using.....library(forcats)
Fed_TRAIN$author <-Fed_TRAIN$author %>% fct_collapse(Hamilton = c("Hamilton","HM"))
## check it
(table(Fed_TRAIN$author))
## (1) Update training data to remove Jay
Fed_TRAIN <- filter(Fed_TRAIN, author != "Jay")
Fed_TRAIN <- filter(Fed_TRAIN, author != "HM")
##Fed_TRAIN$author <-Fed_TRAIN$author %>% fct_collapse(Hamilton = c("Hamilton","HM", "Jay"))
str(Fed_TRAIN)
(table(Fed_TRAIN$author))
(head(Fed_TRAIN))

## OK - where are we?
## We have created a proper test set with JUST THE dispt
## We have created a trainig set with all other labeled examples
## We removed the file name column
## We made the label a factor
## We checked to make sure there are no NAs

#######################################################
#######
####### Train a DT and check it on the test set #######
#######################################################

Fed_DT_FIT <- rpart(author~.,data=Fed_TRAIN, 	method="class")
                    ##control = rpart.control(minsplit=1))
summary(Fed_DT_FIT)
fancyRpartPlot(Fed_DT_FIT)

## To see if the model can predict the training set - test it on the training set...
Fed_DT_Train_predicted= predict(Fed_DT_FIT,Fed_TRAIN[-1], type="class")
(table(Fed_DT_Train_predicted,Fed_TRAIN$author))

## See how it does on the test data...
Fed_DT_predicted= predict(Fed_DT_FIT,Fed_TEST, type="class")
(Fed_DT_predicted)


########################################################
#######
#######  Use Naive Bayes to try to predict the Fed   ###
########################################################

## We will use the same test and train data
(Fed_TEST)
(head(Fed_TRAIN, n=15))

## WAY 1 NB
NB_Fed_classfier <- naiveBayes(author ~.,data=Fed_TRAIN)
NB_Fed_predictTrainSet <-predict(NB_Fed_classfier, Fed_TRAIN[-1])
table(NB_Fed_predictTrainSet,Fed_TRAIN$author)

## Now try to predict the test set
NB_Fed_Prediction <- predict(NB_Fed_classfier, Fed_TEST)
(table(NB_Fed_Prediction))
plot(NB_Fed_Prediction)


###########################################################
######   SVM ##############################################
###########################################################

###########polynomial with iris data small example
## Create a balanced Fed train
iris
SVM_Fed_fit_P_iris <- svm(Species~., data=iris, 
                     kernel="polynomial", cost=100, 
                     scale=FALSE)
print(SVM_Fed_fit_P_iris)

## COnfusion Matrix for training data to check model
(pred_iris <- predict(SVM_Fed_fit_P_iris, iris, type="class"))
(table(pred_iris, iris$Species))  



SVM_Fed_fit_P <- svm(author~., data=Fed_TRAIN, 
                 kernel="polynomial", cost=100, 
                 scale=FALSE)
print(SVM_Fed_fit_P)

## COnfusion Matrix for training data to check model
(pred_Fed_train <- predict(SVM_Fed_fit_P, Fed_TRAIN[-1], type="class"))
(table(pred_Fed_train, Fed_TRAIN$author))  
### NOT A GOOD MODEL! Try another kernel

######## linear
SVM_Fed_fit_L <- svm(author~., data=Fed_TRAIN, 
                     kernel="linear", cost=100, 
                     scale=FALSE)
print(SVM_Fed_fit_L)

## COnfusion Matrix for training data to check model
(pred_Fed_trainL <- predict(SVM_Fed_fit_L, Fed_TRAIN[-1], type="class"))
(table(pred_Fed_trainL, Fed_TRAIN$author))   ### GOOD! The cost needed to be high!
## Now check the test group
(pred_Fed_testL <- predict(SVM_Fed_fit_L, Fed_TEST, type="class"))

########### radial

SVM_Fed_fit_R <- svm(author~., data=Fed_TRAIN, 
                     kernel="radial", cost=100, 
                     scale=FALSE)
print(SVM_Fed_fit_R)

## COnfusion Matrix for training data to check model
(pred_Fed_trainR <- predict(SVM_Fed_fit_R, Fed_TRAIN[-1], type="class"))
(table(pred_Fed_trainR, Fed_TRAIN$author))  ##Not too bad!

##Prediction --
(pred_Fed <- predict(SVM_Fed_fit_R, Fed_TEST, type="class"))



#### Why is SVM not good?? Because our data is not balanced
## we have too many Ham examples!

#####################################################################
#############   kNN #################################################
#####################################################################

(Fed_TEST)
(head(Fed_TRAIN, n=25))
plot(Fed_TRAIN$author)


# get a guess for k
k_guess <- round(sqrt(nrow(Fed_TRAIN)))

kNN_FED_fit <- class::knn(train=Fed_TRAIN[-1], test=Fed_TRAIN[-1], 
                      cl=Fed_TRAIN$author, k = k_guess, prob=F)
print(kNN_FED_fit)
## Check the classification accuracy
(table(kNN_FED_fit, Fed_TRAIN$author))

## This model is working pretty well!

## Let's test it on the test set now

kNN_FED_fit2 <- class::knn(train=Fed_TRAIN[-1], test=Fed_TEST, 
                          cl=Fed_TRAIN$author, k = k_guess, prob=F)
print(kNN_FED_fit2)

############### Compare results of the models....
print("KNN model")
print(kNN_FED_fit2)

print("SVM Model Linear")
(pred_Fed_testL <- predict(SVM_Fed_fit_L, Fed_TEST, type="class"))

print("DT Model")
(Fed_DT_predicted= predict(Fed_DT_FIT,Fed_TEST, type="class"))

print("NB Model")
(NB_Fed_Prediction <- predict(NB_Fed_classfier, Fed_TEST))




