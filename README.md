# Getting and Cleaning Data - Course Project

## Instructions

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.

Review criteria
1. The submitted data set is tidy.
2. The Github repo contains the required scripts.
3. GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
4. The README that explains the analysis files is clear and understandable.
5. The work submitted for this project is the work of the student who submitted it.

Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Project

### Part 1 - read data from the UCI HAR Dataset
```r
features <- read.table("UCI HAR Dataset/features.txt", row.names = 1)
features <- features[, 1]

testData <- read.table("UCI HAR Dataset/test/X_test.txt", col.names=features)
testActivityData <- read.table("UCI HAR Dataset/test/y_test.txt", col.names="activityNum")
testSubjectData <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names="subject")

trainData <- read.table("UCI HAR Dataset/train/X_train.txt", col.names=features)
trainActivityData <- read.table("UCI HAR Dataset/train/y_train.txt", col.names="activityNum")
trainSubjectData <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names="subject")
```

#### Combine the test and training data sets
```r
data <- rbind(testData, trainData)
activityData <- rbind(testActivityData, trainActivityData)
subjectData <- rbind(testSubjectData, trainSubjectData)
```

### Part 2 - Extract only the measurements on the mean and standard deviation for each measurement
```r
meanAndStdSelection <- grepl("mean\\(\\)|std\\(\\)", features)
data <- data[, meanAndStdSelection]
```

### Part 3 - Use descriptive activity names (i.e. WALKING, WALKING_UPSTAIRS, etc.)
#### Don't worry about subject data right now
```r
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("activityNum", "activity"))
mergedData <- cbind(activityData, data)
mergedData <- merge(activityLabels, mergedData, by="activityNum")
```

### Part 4 - Tidy variable names
#### Hard code all of the t-feature names. Then modify these for the f-features
```r
tFeatures <- c("tBdAccXMean",
              "tBdAccYMean",
              "tBdAccZMean",
              "tBdAccXStd",
              ...
              "tBdGyMagStd",
              "tBdGyJrkMagMean",
              "tBdGyJrkMagStd")

fFeatures <- sub("^t", "f", tFeatures)
```
#### remove the "Gravity" and "BodyGyroJerk-XYZ" features to match features_info.txt
```r
fFeatures <- fFeatures[!grepl("Grav", fFeatures)]
fFeatures <- fFeatures[!grepl("^fBdGyJrk[XYZ]", fFeatures)]

features <- c("activityNum", "activity", tFeatures, fFeatures)
mergedData <- setNames(mergedData, features)
```

### Part 5 - Average of each variable for each activity and each subject.
#### Merge subject data into mergedData data table
```r
mergedData <- cbind(subjectData, mergedData)

#### Use data table to group by activity and subject
library(data.table)
dt <- as.data.table(mergedData)

tidyActivitySubject <- dt[, lapply(.SD, mean), by=list(subject, activity)]
```
