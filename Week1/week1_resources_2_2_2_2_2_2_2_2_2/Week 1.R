########################################
## NAME YOUR R Files
##
## This file is an introduction to R
## for SYR.
## 
## Week 1
##
## It looks at StoryTeller data
##
## Practice - 
##     1) REading in csv
##     2) Looking at the data frame
##     3) Libraries
##     4) Setting a WD
##     5) installing
##     6) check for missing values
##     7) visual EDA part 1
##     8) Look at data types (str)
##    
##     RENAME DATA FILES SO THEY HAVE NO SPECIAL CHAR
#####################################################

## DO THIS ONCE
#install.packages("ggplot2")
## DO THIS ONCE
#install.packages("tidyverse")

library(ggplot2)
library(tidyverse)

## Set your working director to the path were your code AND datafile is
setwd("C:/Users/jerem/Google Drive/Online/iCuse/IST707/Week1")


## Read in .csv data
## Reference:
## https://stat.ethz.ch/R-manual/R-devel/library/utils/html/read.table.html
## The data file and the R code must be in the SAME folder or you must use a path
## The name must be identical.
filename="datastoryteller.csv"
MyStoryData <- read.csv(filename, header = TRUE, na.strings = "NA")

## Look at the data as a data frame
(head(MyStoryData))

## See all the "dots" in the column names?
## This is not good.
## Update the column names in MyStoryData...

## Once you fix the data - read it in again and comment out the above code...
filename="datastorytellerFIXED.csv"
MyStoryData <- read.csv(filename, header = TRUE, na.strings = "NA")

## Look at the data as a data frame
(head(MyStoryData))

## Check for missing values
Total <-sum(is.na(MyStoryData))
cat("The number of missing values in StoryTeller data is ", Total )

## To clean this data, we can look through the variables and make sure that the data for each variable is in
## the proper range.
## The data shows the *number of students* in each category.
## This value cannot be negative - so 0 is the min. We do not know the max, but we
## might be suspecious of very large numbers. 

## Let's check each numerical variable to see that it is >= 

for(varname in names(MyStoryData)){
  ## Only check numeric variables
  if(sapply(MyStoryData[varname], is.numeric)){
    cat("\n", varname, " is numeric\n")
    ## Get median
    (Themedian <- sapply(MyStoryData[varname],FUN=median))
    ##print(Themedian)
    ## check/replace if the values are <=0 
    MyStoryData[varname] <- replace(MyStoryData[varname], MyStoryData[varname] < 0, Themedian)
  }
  
}

(MyStoryData)

## EXPLORE!
## For all assignments, explore your data.

## Tables are great!
(table(MyStoryData$School))

## loops - make all the tables at once
for(i in 1:ncol(MyStoryData)){
  print(table(MyStoryData[i]))
}

(colnames(MyStoryData))
(head(MyStoryData))
(MyStoryData)

## WHich variables contain information?
## Does the Section?


## Now - look at each table.
## First, "School"
## The table shows us that we have 5 schools. but only 2 of them have much data
## Why is this important?

## Look at all the other variables.
## Are there outliers or odd values?

## The structure (types) of the data
(str(MyStoryData))

## Let's use visual EDA - boxplots and great
## What does this tell us?
ggplot(stack(MyStoryData), aes(x = ind, y = values, color=ind)) +
  geom_boxplot()
## 
MyStoryData$School =="A"

JustSchoolA<-subset(MyStoryData, School == "A" )
(JustSchoolA)
(str(JustSchoolA))

## Change Section to a factor
JustSchoolA$Section<-as.factor(JustSchoolA$Section)

ggplot(JustSchoolA, aes(x = Section, y = Middling, color=Section)) +
  geom_boxplot()

## Measures - mean, median, sums

library(plyr)
## do once: install.packages("plyr")

## The following will sum all rows for each "School" and per variable in the data
## Let's save this new aggregated result as a DF
SumBySchoolDF <- ddply(MyStoryData, "School", numcolwise(sum))
(SumBySchoolDF)

## Now, I want the total number of students for A - E
## I want to sum the columns for each row
## I will start with:

(SumBySchoolDF)

SumOfStudents <- rowSums(SumBySchoolDF[,c("VeryAhead", "Middling", "Behind", 
                                          "MoreBehind","VeryBehind","Completed")])
(SumOfStudents)

TotalPerSchool <- data.frame("School" = SumBySchoolDF$School, 
                             "Total" = SumOfStudents)

(TotalPerSchool)






