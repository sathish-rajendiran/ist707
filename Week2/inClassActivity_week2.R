
## IST 707 In-Class Activity
## Load the data storyteller file, clean data and perform EDA with Viz.
## Review Week 2 Coding Example to see code idea.
## Some Week 2 Coding Snippets are interspersed to give you a basic template. 

## For this example, any record-style
## dataset will work
## It is often easier to remove spaces or odd char from variable names
## on your dataset.


### Step 1 --------------------
##
## Make sure your data is in a location where you RStudio can access it. 


## Step 2 ---------------------
##
## Read in the data - your path may be different...

##Example: In Windows, there are two ways to access files
## You can use \\  or /
## BE SURE TO SET the working directory  setwd....here is one
## way to do this

setwd("C:\\Users\\jerem\\Google Drive\\Online\\iCuse\\IST707\\Week2")

studentData <- read.csv("data-storyteller.csv", na.string=c(""))
##print it...
(head(studentData, n=15))

## you can also access data directly if the R program and the data
## are in the same location - and in the location of your wd
## This example also shows usind read.table()
(getwd())
filename="data-storyteller.csv"
## Note: na.string=c("") will replace empty with NA
studentTestData <- read.table(filename, sep=",", header=TRUE, na.string=c(""))
##print it...
(head(studentTestData,n=5))

##Note that read.csv is a "wrapper" around read.table. The read.csv may
## faster in some cases.

### Step 3 ---------------------------------------------------------
## Look at the structure
(str(studentData))
(str(studentTestData))

## By looking at the structure, you can also see the TYPES of your 
## variables (attributes). Notice that Section is noted as int
## which is not true, as it is really qual and nominal data. This
## is true for a few others, such as Pclass, Survived,..

## In R, 
##   nominal variables are "factors"
##   ordinal variables are "ordered factors"
## There are also num (numbers) and int (integers - no decimals)

#### HOW TO CHANGE the type of an attribute in your data frame table
## In data, we have Section We want to change this to 
## what type? 

## Look at the before and after
(str(studentData$Section))
## Now make the change
#studentData$Section <- factor(studentData$Section)
#(str(studentData))

############################################################################
##  (1)
##MAKE ANY "CLEANING" CHANGES AS NEEDED. Report to class what changes were made and why.
###############################################################################
################################################################################

## Any Missing Data?

##########################################################
##  (2)
## IF ANY MISSING DATA -- MAKE NOTE AND REPORT TO CLASS
##############################################################
##############################################################

## Suppose you want to first look at how many missing values are in 
## each column (variable)


## This will show us which columns have the most missing data.
## If the columns with a lot of missing data are not important
## we can remove them. This way, in the end, we lose or can fix fewer  values

##for(colname in names(studentData)){
##  cat("\n Looking at column...", colname, "\n")
##  NAcount <- sum(is.na(studentData[colname]))
##  cat("\nThe num of missing values in column ", colname, "is  ", NAcount)
##}

########################################################
##  (3)
## PERFORM SOME BASIC EDA for student data (see titanic example below for ideas).
## MAKE SOME VIZ AND REPORT TO CLASS.
########################################################
##########################################################

## Descriptive Stats
##cat("The mean Age is ", mean(TitanicTestData$Age))
##cat("The median Age is ", median(TitanicTestData$Age))
##cat("\n\n")
##(freq=table(TitanicTestData$Age))  ## This is not good - why?


### --------------Step 6 ------------------------
## Visualization
  ##(head(TitanicTestData, n= 5))
## Hist
  ##hist(TitanicTestData$Age)
## Box
  ##boxplot(TitanicTestData$Age)
## Recall that Scatter compares TWO variables
  ##plot(TitanicTestData$Age, TitanicTestData$SibSp)
## Pies - use table...
  ##pie(table(TitanicTestData$Sex))

## IQR
  ##boxplot(TitanicTestData$Age)
  ##(IQR_value <- IQR(TitanicTestData$Age))









