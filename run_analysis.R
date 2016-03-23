## Assignment instructions:
##
## You should create one R script called run_analysis.R that does the following.
##
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

require(data.table)
require(dplyr)
require(tidyr)
require(Hmisc) ## for capitalizing activity labels

## clean up the environment and run the garbage collector before starting
rm(list=ls())
gc(verbose = FALSE)

## Source data should be found in the "UCI HAR Dataset" directory found within the working directory.
## the activity labels and features are also available in a file so no need to hard-code them
activity_labels <- read.table("~/UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)
activity_labels <- rename(activity_labels, activityid = V1, activity = V2)
activity_labels$activity <- capitalize(tolower(gsub('_', ' ', activity_labels$activity)))
features <- read.table("~/UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
features <- rename(features, featureid = V1, feature = V2)

## now use grep to get the variable indexes and names  from the feature list that represent mean or standard 
## deviation. Then do some cleanup on the variable names.
featuresofinterest <- features[grep("(-mean\\(\\)|-std\\(\\))",features$feature),]
featuresofinterest$feature <- gsub('-mean', '.Mean.', featuresofinterest$feature)
featuresofinterest$feature <- gsub('-std', '.Std.', featuresofinterest$feature)
featuresofinterest$feature <- gsub('[-()]', '', featuresofinterest$feature)

## Now load the 6 source files into R data tables
subject_train <- read.table("~/UCI HAR Dataset/train/subject_train.txt", header = FALSE)
x_train <- read.table("~/UCI HAR Dataset/train/x_train.txt", header = FALSE)
y_train <- read.table("~/UCI HAR Dataset/train/y_train.txt", header = FALSE)

subject_test <- read.table("~/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
x_test <- read.table("~/UCI HAR Dataset/test/x_test.txt", header = FALSE)
y_test <- read.table("~/UCI HAR Dataset/test/y_test.txt", header = FALSE)

## now combine the train and test datasets and set column names
subject_train <- rename(subject_train, subjectid = V1)
y_train <- rename(y_train, activityid = V1)
train_dataset <- cbind(subject_train, y_train, select(x_train,featuresofinterest$featureid))

subject_test <- rename(subject_test, subjectid = V1)
y_test <- rename(y_test, activityid = V1)
test_dataset <- cbind(subject_test, y_test, select(x_test,featuresofinterest$featureid))

full_dataset <- rbind(train_dataset,test_dataset)
colnames(full_dataset) <- c("subject", "activity", featuresofinterest$feature)
full_dataset$activity <- factor(full_dataset$activity, levels = activity_labels$activityid, labels = activity_labels$activity)
full_dataset$subject <- as.factor(full_dataset$subject)

## melt the data and calculate means
melted_dataset <- melt(full_dataset, id = c("subject", "activity"))
tidy_dataset <- dcast(melted_dataset, subject + activity ~ variable, mean)

## output the tidy full dataset as text and CSV for sanity checking
write.table(tidy_dataset, "tidy.txt", row.names = FALSE, quote = TRUE) ## need quote for activity and variable names with spaces

## Optional: now read the tidy text file back in to see the results
rm(list=ls())
verify <- read.table("tidy.txt", header = TRUE)
