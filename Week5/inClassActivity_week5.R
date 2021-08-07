## 
##  1) Read in Data Set from Kaggle
##
##  2) Split data into distinct Training and Testing Sets
##        a) train: even indices, test odd indices
##        b) train: all indices not ending in zero, test, indices ending in zero
##        c) train / test randomly selected with 50/50 split
##        d) train / test randomly selected with 90/10 split
##        5) train: known authers, test unknown authors *** (try split())
##
##  3) If time train decision tree.
##
##
## Adapted from ... 

##Decision Trees
## Classification
## Information Gain

## Gates

## For this example, I will use the Kaggle Titantic Test and
## Train datasets.

## Let's read these in and clean them first. 
## Recall that Decision Trees can only split nominally
## This means that any quantitative (numerical) variables
## will have to be discretized/binned or removed
## numerical ordinal data or data with too many categories
## should also be consolidated.
## GOAL
## The goal is to create decision tree from the training data
## that tries to classify a row as survive or not survive
## Then, we will use the testing data to see how well
## the Decision Tree works. 

library(tm)
#install.packages("tm")
library(stringr)
library(wordcloud)
# ONCE: install.packages("Snowball")
## NOTE Snowball is not yet available for R v 3.5.x
## So I cannot use it  - yet...
##library("Snowball")
##set working directory
## ONCE: install.packages("slam")
library(slam)
library(quanteda)
## ONCE: install.packages("quanteda")
## Note - this includes SnowballC
library(SnowballC)
library(arules)
## ONCE: install.packages("wordcloud")
library(wordcloud)
##ONCE: install.packages('proxy')
library(proxy)
library(cluster)
library(stringi)
library(proxy)
library(Matrix)
library(tidytext) # convert DTM to DF
library(plyr) ## for adply
library(ggplot2)
library(factoextra) # for fviz
library(mclust) # for Mclust EM clustering

#install.packages("slam")
library(slam)
#install.packages("tm")
library(tm)
#install.packages("factoextra")
library(factoextra)


setwd("C:\\Users\\jerem\\Google Drive\\Online\\iCuse\\IST707\\Week5")

#setwd("C:\\Users\\profa\\Documents\\R\\RStudioFolder_1\\DrGExamples\\SYR\\IST707\\Week4")
#setwd("C:\\Users\\jerem\\Google Drive\\Online\\iCuse\\IST707\\Week4")
## Next, load in the documents (the corpus)
NovelsCorpus <- Corpus(DirSource("FedPapersCorpus"))
(getTransformations())
(ndocs<-length(NovelsCorpus))

##The following will show you that you read in all the documents
(summary(NovelsCorpus))
(meta(NovelsCorpus[[1]]))
(meta(NovelsCorpus[[1]],5))

# ignore extremely rare words i.e. terms that appear in less then 1% of the documents
(minTermFreq <- ndocs * 0.0001)
# ignore overly common words i.e. terms that appear in more than 50% of the documents
(maxTermFreq <- ndocs * 1)
(MyStopwords <- c("maggie", "philip", "tom", "glegg", "deane", "stephen","tulliver"))
#stopwords))
(STOPS <-stopwords('english'))
Novels_dtm <- DocumentTermMatrix(NovelsCorpus,
                                 control = list(
                                   stopwords = TRUE, 
                                   wordLengths=c(3, 15),
                                   removePunctuation = T,
                                   removeNumbers = T,
                                   tolower=T,
                                   stemming = T,
                                   remove_separators = T,
                                   stopwords = MyStopwords,
                                   #removeWords(STOPS),
                                   #removeWords(MyStopwords),
                                   bounds = list(global = c(minTermFreq, maxTermFreq))
                                 ))


##########################################
############  ONCE THE DATA IS 
############  LOADED AND CLEANED
############  MAKE TRAIN AND TEST SETS
##########################################

## Try doing this by explcitly building an index set
## using fixed indices or random 
## Or use a built in function like split(...)

trainRatio <- .50;
set.seed(11) # Set Seed so that same sample can be reproduced in future also
sample <- sample.int(n = nrow(Novels_dtm), size = floor(trainRatio*nrow(Novels_dtm)), replace = FALSE)

train <- Novels_dtm[sample, ]
test <- Novels_dtm[-sample, ]

# train / test ratio
length(sample)/nrow(Novels_dtm)



#####################################
# investigate build train / test sets and confirm correct construction
######################################

## Have a look
#inspect(Novels_dtm)
DTM_mat <- as.matrix(train)
(DTM_mat[1:13,1:5])
#Novels_dtm <- weightTfIdf(Novels_dtm, normalize = TRUE)
#Novels_dtm <- weightTfIdf(Novels_dtm, normalize = FALSE)

## Look at word freuqncies
(WordFreq <- colSums(as.matrix(train)))

(head(WordFreq))
(length(WordFreq))
ord <- order(WordFreq)
(WordFreq[head(ord)])
(WordFreq[tail(ord)])
## Row Sums
(Row_Sum_Per_doc <- rowSums((as.matrix(train))))


## TRY:  Alter code below to learn a decision tree to 
## classify novels based on auther

###################### BUILD Decision Trees ----------------------------
#install.packages("rpart")
#install.packages('rattle')
#install.packages('rpart.plot')
#install.packages('RColorBrewer')
#install.packages("Cairo")
#install.packages("CORElearn")
library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(Cairo)

#fit <- rpart(CleanTrain$Survived ~ ., data = CleanTrain, method="class")
#summary(fit)
#predicted= predict(fit,CleanTest, type="class")
#(head(predicted,n=10))
#(head(CleanTest, n=10))
##plot(fit)
##text(fit)
#fancyRpartPlot(fit)
#submit <- data.frame(PassengerGender = CleanTest$Sex, Survived = predicted)
#(head(submit, n=10))
#write.csv(submit, file = "TitanicPredictionGender.csv", row.names = FALSE)

## Let's reduce the tree size
#fit2 <- rpart(Survived ~ Pclass + Sex + Age,
#             data=CleanTrain,
#             method="class", 
#             control=rpart.control(minsplit=2, cp=0))

#fancyRpartPlot(fit2)

## Save the Decision Tree as a jpg image
#jpeg("DecisionTree_Titanic.jpg")
#fancyRpartPlot(fit2)
#dev.off()

########################### Information Gain with Entropy ----------------------------
#library(CORElearn)

#https://cran.r-project.org/web/packages/CORElearn/CORElearn.pdf

#Method.CORElearn <- CORElearn::attrEval(CleanTrain$Survived ~ ., data=CleanTrain,  estimator = "InfGain")
#(Method.CORElearn)
#Method.CORElearn2 <- CORElearn::attrEval(CleanTrain$Survived ~ ., data=CleanTrain,  estimator = "Gini")
#(Method.CORElearn2)
#Method.CORElearn3 <- CORElearn::attrEval(CleanTrain$Survived ~ ., data=CleanTrain,  estimator = "GainRatio")
#(Method.CORElearn3)

