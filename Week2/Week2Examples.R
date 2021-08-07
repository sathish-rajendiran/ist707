
## IST 707 Week 2 Examples
## DrG

## For this example, any record-style
## dataset will work
## It is often easier to remove spaces or odd char from variable names
## on your dataset.

## FOr this example, I will use two datasets from Kaggle: Titanic

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
## setwd("C:\\Users\\profa\\Documents\\R\\RStudioFolder_1\\DrGExamples\\SYR\\IST707\\Week2")

setwd("C:\\Users\\jerem\\Google Drive\\Online\\iCuse\\IST707\\Week2")

TitanicTrainData <- read.csv("Titanic_Training_Data.csv", na.string=c(""))
##print it...
(head(TitanicTrainData, n=5))

## you can also access data directly if the R program and the data
## are in the same location - and in the location of your wd
## This example also shows usind read.table()
(getwd())
filename="Titanic_Testing_Data.csv"
## Note: na.string=c("") will replace empty with NA
TitanicTestData <- read.table(filename, sep=",", header=TRUE, na.string=c(""))
##print it...
(head(TitanicTestData,n=5))

##Note that read.csv is a "wrapper" around read.table. The read.csv may
## faster in some cases.

### Step 3 ---------------------------------------------------------
## Look at the structure
(str(TitanicTestData))
(str(TitanicTrainData))

## By looking at the structure, you can also see the TYPES of your 
## variables (attributes). Notice that Passenger ID is noted as int
## which is not true, as it is really qual and nominal data. This
## is true for a few others, such as Pclass, Survived,..

## In R, 
##   nominal variables are "factors"
##   ordinal variables are "ordered factors"
## There are also num (numbers) and int (integers - no decimals)

#### HOW TO CHANGE the type of an attribute in your data frame table
## In TitanicTestData, we have PassengerId. We want to change this to 
## factor. 

## Look at the before and after
(str(TitanicTestData$PassengerId))
## Now make the change
TitanicTestData$PassengerId <- factor(TitanicTestData$PassengerId)
(str(TitanicTestData))

##Change Pclass to ordered factor
TitanicTestData$Pclass=ordered(TitanicTestData$Pclass)
## Check the data types again now....
(str(TitanicTestData))

## Let's see a frequnecy table of just the Pclass
(table(TitanicTestData$Pclass))

##### Step 4 -------------------------------------------------------
##
## Dealing with data cleaning
## Missing values....
##    Using is.na(YourDataFrame) will return True or False (assuming that
##                               you replaced your blanks with NA)

(is.na(TitanicTestData))  ## rows with NA
(sum(is.na(TitanicTestData)))
(sum(is.na(TitanicTestData$Age)))
(sum(is.na(TitanicTestData$Cabin)))


## You can list all the complete rows
## Note: complete.cases(TitanicTestData)   are the rows
## you want to see. and the ,] means all columns
(TitanicTestData[complete.cases(TitanicTestData),])
(sum(complete.cases(TitanicTestData)))
(nrow(TitanicTestData))

## How many rows are complete?
cat("The Titanic Test data has a total of ", nrow(TitanicTestData), "rows.")
CompleteRows <- (nrow(TitanicTestData[complete.cases(TitanicTestData),]))
cat("The Titanic Test data has a total of ", CompleteRows, "complete rows.")
## This will give you the count of all elements that are NA (rather than rows)
(length(which(!is.na(TitanicTestData))))   ## Total number of NAs 

## Suppose you want to first look at how many missing values are in 
## each column (variable)

## Side Note
## In R, you CANNOT do something like this - this **will not** work...
## B <- "Age"
## TitanicTestData$B

## This will show us which columns have the most missing data.
## If the columns with a lot of missing data are not important
## we can remove them. This way, in the end, we lose or can fix fewer  values

for(colname in names(TitanicTestData)){
  cat("\n Looking at column...", colname, "\n")
  NAcount <- sum(is.na(TitanicTestData[colname]))
  cat("\nThe num of missing values in column ", colname, "is  ", NAcount)
}


## Here, Cabin is missing 327 values - and is not necessary for our purposes
## so it is better to remove that column rather than lose all the rows with this missing
## value. 
## Next, in this case, the Age also has a lot of missing values, but we can try to replace
## them with an estimate. We can base that estimate on many things. We can replace
## using the median or the mean. 
## Let's use the median

## *** HOWEVER *** Normally, why  - in this case with Titanic data - is replacing missing ages 
## NOT a good idea??
## We will do it so you can see how. 

## First, find the median age
## Create a function that does this...
medianWithoutNA<-function(x) {
  median(x[which(!is.na(x))])
}
(MedAge <- medianWithoutNA(TitanicTestData$Age))

## You could also have done this
##(median(TitanicTestData$Age[which(!is.na(TitanicTestData$Age))]))

## Next, replace all the NAs for Age with the Median

## Create a dumby fd so you do not ruin your df
Tester <- TitanicTestData

## BEFORE
AgeNAcount <- sum(is.na(Tester["Age"]))
cat("\nThe num of missing values in column Age is  ", AgeNAcount)
## Replace with Median
Tester$Age[which(is.na(Tester$Age))] <- MedAge
## AFTER
AgeNAcount <- sum(is.na(Tester["Age"]))
cat("\nThe num of missing values in column Age is  ", AgeNAcount)

## Take a look at it!
(head(Tester, 20))

## Go ahead - now that you know it works - and place Tester into TitanicTestData
TitanicTestData <- Tester
(head(TitanicTestData, n=10))

## Next, remove the entire column called Cabin as this column is not important to our
## research and is missing too many values. 

## Again, we will do this with a dumby Tester df first
Tester <- TitanicTestData
Tester["Cabin"] <- NULL   #get rid of Cabin
(head(Tester, n=5))   ## notice that its gone

## This worked. NOw lets put Tester back into Titanic
TitanicTestData <- Tester

## Let's look again at our missing values....
for(colname in names(TitanicTestData)){
  cat("\n Looking at column...", colname, "\n")
  NAcount <- sum(is.na(TitanicTestData[colname]))
  cat("\nThe num of missing values in column ", colname, "is  ", NAcount)
}

## Now we can see that we are only missing one value in Fare.
## We should just remove this entire row. 

TitanicTestData  <- TitanicTestData[complete.cases(TitanicTestData), ]

## Let's look again at our missing values....
for(colname in names(TitanicTestData)){
  cat("\n Looking at column...", colname, "\n")
  NAcount <- sum(is.na(TitanicTestData[colname]))
  cat("\nThe num of missing values in column ", colname, "is  ", NAcount)
}

## As a side-note for my coders...this for loop gets used a lot. As such, it can be a function.

## Now we have no missing values. 
## To improve this code, we can place our for loop that counts missing values into a function - try this!

################-------------Step 5 ---------------------------------

## Descriptive Stats
cat("The mean Age is ", mean(TitanicTestData$Age))
cat("The median Age is ", median(TitanicTestData$Age))
cat("\n\n")
(freq=table(TitanicTestData$Age))  ## This is not good - why?

## Notice!! There are ages listed as .17 and .92. 
## Check the dataset so see this!
## Row 203 if opened in Excel will show an example of this issue

## This is an example of INCORRECT DATA
## By looking at the frequnecy table, we can see that
## there are only 5 rows with incorrect ages. 
## We have two choices - we can replace them with the median
## or we can remove then.

## WARNING!! Because we replaced so many ages with the med
## We must be careful about inferences or correlations
## based on Age. 

## Let's find and remove these ERRORS
Tester <- TitanicTestData
## Create an empty vector
RowsToRemove=c()
counter <- 1
for (nextrow in TitanicTestData$Age){
  counter <- counter + 1
  #cat(nextrow)
  if (nextrow < 1 ){
    #cat(nextrow)
    cat("\n Bad row value: ", nextrow, "\n")
    cat("Row number: ", counter, "\n")
    cat("ROW:")
    ##print(Tester[counter, ])
    ## Remove the row
    value <- counter
    #print(Tester[value-1,])
    RowsToRemove <- c(RowsToRemove, value-1)
    #print(Tester[counter,])
    #print(Tester[counter+1,])
    ##print(Tester[counter+2,])
   
  }
    
  
}
print(RowsToRemove)
Tester <- Tester[-RowsToRemove,]

## Check it!
(freq=table(Tester$Age))
## Now put Tester into Titanic
TitanicTestData <- Tester
(freq=table(TitanicTestData$Age))


## Ok - now we have Age values that make sense.
## The methods above are just examples of what you 
## must do to clean your data.

### --------------Step 6 ------------------------
## Visualization
(head(TitanicTestData, n= 5))
## Hist
hist(TitanicTestData$Age)
## Box
boxplot(TitanicTestData$Age)
## Recall that Scatter compares TWO variables
plot(TitanicTestData$Age, TitanicTestData$SibSp)
## Pies - use table...
pie(table(TitanicTestData$Sex))

## IQR
boxplot(TitanicTestData$Age)
(IQR_value <- IQR(TitanicTestData$Age))


##########    Step 7 ----------------------------------------
### Data Aggregation

## In these examples, we will also use Excel data rather than csv to see that 
## we can use both.
## The Excel file is called SalesData.xlsx
## We will use a library called readxl
## DIfferent versions of R may use/want
## Different libraries
## Other Excel libraries are:
## XLConnect, xlsx, etc.
## RUN THIS ONCE on the command line below...

## install.packages("readxl")

library(readxl)

salesdata <- read_xlsx("SalesData.xlsx")
(head(salesdata,n=5))
salesdata2 <- read_excel("SalesData.xlsx")
(head(salesdata2,n=5))

## Some aggregation
## NUmber of products sold each day in each region
## Note: There are 4 regions: A, B, C, D
## So on Monday, there were 100 + 50 produst sold in region A
## The variable names are:
print(names(salesdata))
(str(salesdata))
salesdata$Region <- factor(salesdata$Region)
(str(salesdata))
## The following creates a data frame of just the days of the week data
DaysDataFrame <- cbind(salesdata$Region, salesdata$Mon, salesdata$Tue, salesdata$Wed, salesdata$Thu,salesdata$Fri,salesdata$Sat,salesdata$Sun)
(DaysDataFrame)

## First, just try to sum up the Mon values by Region....
## Note: NewCat will be a variable name in my new table.
salesByRegion <- aggregate(salesdata$Mon, by=list(NewCat=salesdata$Region),FUN=sum)
(salesByRegion)

## Next, try to sum up all the Week Days by Region and create
## a new table with smart headings
saleByRegionPerDay <- aggregate(cbind(salesdata$Mon, salesdata$Tue, salesdata$Wed), by=list(MyRegions=salesdata$Region), FUN=sum)
(saleByRegionPerDay)

## OR to create column names...you can use a shorter syntax...
saleByRegionPerDay2 <- aggregate(list(Monday=salesdata$Mon, Tuesday=salesdata$Tue), by=list(MyRegions=salesdata$Region), FUN=sum)
(saleByRegionPerDay2)
View(saleByRegionPerDay2)

## Example 2: What are the avg sales for each region during the weekend (Sat and Sun)
## First - think about what you are trying to get...

## First, sum the rows for Sat and Sun together
Weekend <- rowSums(salesdata[,c("Sat", "Sun")])
(Weekend)
## Next, add on this new sum of both weekend days to the original dataframe
salesWeekend <- data.frame(salesdata,Weekend)
(salesWeekend)

## Now, aggregate - find the mean - for the weekend by region
## Notice that I can rename the columns here....
AvgWeekendSales <- aggregate(list(WeekendAverage=salesWeekend$Weekend), by=list(ByRegion=salesWeekend$Region), FUN=mean)
(AvgWeekendSales)



#################### Step 8 --------------------------------------
###
## Data Transformation
##
## (1) Discretization

## Example: Using the Titanic Test data that we cleaned above
## we will place the ages into 8 bins or classes.

ageBins <- cut(TitanicTestData$Age, breaks=c(0,10,20,30,40,50,60,70,Inf),
               labels=c("child", "teen", "twenties", "thirties", 
                        "fourties", "fifties", "sixties", "olderThan60"))
(ageBins)

## plot this
## first - what structure is this
(str(ageBins))

table(ageBins)
counts <- table(ageBins)
barplot(counts, main="Age Distribution", xlab="Age")


########### Step 9 ---------------------------
## Data Transformation Examples
##
## LOg Transformation
plot(TitanicTestData$Age,log(TitanicTestData$Age))

###########Step 10 ------------------------------
##
## Normalization 
## z scores
## Two ways:

## Here - I am using my CLEANED Titanic Testing data
## HOwever, if you do not clean and remove NAs first
## you must do so in the code below...

## scale will normalize data
## centering data is subtracting the mean
## scaling data is dividing by the std dev
(scale(TitanicTestData$Age, center=TRUE, scale=TRUE))

## Way 2 is by hand - which is important so that you 
## know what you are doing

Result3 <-(TitanicTestData$Age - mean(TitanicTestData$Age))/sd(TitanicTestData$Age)
## View the results on a plot
hist(Result3)

## Using min-max normaization is a similar idea....
Min_Max <- (TitanicTestData$Age - min(TitanicTestData$Age, 
                                      na.rm=TRUE))/(max(TitanicTestData$Age) - min(TitanicTestData$Age))

(Min_Max)
hist(Min_Max)


######### Step 11 ------------------------------
##
## Sampling
##
## Random sampling from data
## This creates a new data frame called MyRandomSample
## with rows and cols defined as....
MyRandomSample <- TitanicTestData[sample(1:nrow(TitanicTestData),100,replace=FALSE),]
(MyRandomSample)
## Here again, remember that we already cleaned the Titanic Test data

## Systematic Sampling
## Grab each 10th row, so 1, 11, 21, etc...
MySysSample <- TitanicTestData[seq(1,nrow(TitanicTestData),10), ]
(MySysSample)














