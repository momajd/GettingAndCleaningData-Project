## Part 1 - read data from the UCI HAR Dataset
features <- read.table("UCI HAR Dataset/features.txt", row.names = 1)
features <- features[, 1]

testData <- read.table("UCI HAR Dataset/test/X_test.txt", col.names=features)
testActivityData <- read.table("UCI HAR Dataset/test/y_test.txt", col.names="activityNum")
testSubjectData <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names="subject")
  
trainData <- read.table("UCI HAR Dataset/train/X_train.txt", col.names=features)
trainActivityData <- read.table("UCI HAR Dataset/train/y_train.txt", col.names="activityNum")
trainSubjectData <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names="subject")

# Combine the test and training data sets 
data <- rbind(testData, trainData)
activityData <- rbind(testActivityData, trainActivityData)
subjectData <- rbind(testSubjectData, trainSubjectData)

## Part 2 - Extract only the measurements on the mean and standard deviation for each measurement
meanAndStdSelection <- grepl("mean\\(\\)|std\\(\\)", features)
data <- data[, meanAndStdSelection]

## Part 3 - Use descriptive activity names (i.e. WALKING, WALKING_UPSTAIRS, etc.)
# Don't worry about subject data right now
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("activityNum", "activity"))
mergedData <- cbind(activityData, data) 
mergedData <- merge(activityLabels, mergedData, by="activityNum")

## Part 4 - Tidy variable names 
# Hard code all of the t-feature names. Then modify these for the f-features
tFeatures <- c("tBdAccXMean", 
              "tBdAccYMean",
              "tBdAccZMean",
              "tBdAccXStd", 
              "tBdAccYStd",
              "tBdAccZStd",
              "tGravAccXMean",
              "tGravAccYMean",
              "tGravAccZMean",
              "tGravAccXStd",
              "tGravAccYStd",
              "tGravAccZStd",
              "tBdAccJrkXMean", 
              "tBdAccJrkYMean", 
              "tBdAccJrkZMean",
              "tBdAccJrkXStd",
              "tBdAccJrkYStd",
              "tBdAccJrkZStd",
              "tBdGyXMean",
              "tBdGyYMean",
              "tBdGyZMean",
              "tBdGyXStd",
              "tBdGyYStd",
              "tBdGyZStd",
              "tBdGyJrkXMean",
              "tBdGyJrkYMean",
              "tBdGyJrkZMean",
              "tBdGyJrkXStd",
              "tBdGyJrkYStd",
              "tBdGyJrkZStd",
              "tBdAccMagMean",
              "tBdAccMagStd",
              "tGravAccMagMean",
              "tGravAccMagStd",
              "tBdAccJrkMagMean",
              "tBdAccJrkMagStd",
              "tBdGyMagMean",
              "tBdGyMagStd",
              "tBdGyJrkMagMean",
              "tBdGyJrkMagStd")

fFeatures <- sub("^t", "f", tFeatures)
# remove the "Gravity" and "BodyGyroJerk-XYZ" features to match features_info.txt
fFeatures <- fFeatures[!grepl("Grav", fFeatures)]
fFeatures <- fFeatures[!grepl("^fBdGyJrk[XYZ]", fFeatures)]

features <- c("activityNum", "activity", tFeatures, fFeatures)
mergedData <- setNames(mergedData, features)

## Part 5 - Average of each variable for each activity and each subject.
# Merge subject data into mergedData data table 
mergedData <- cbind(subjectData, mergedData) 

# Use data table to group by activity and subject 
library(data.table)
dt <- as.data.table(mergedData) 

tidyActivitySubject <- dt[, lapply(.SD, mean), by=list(subject, activity)]