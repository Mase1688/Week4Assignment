
## This is my tidy data set script called run_analysis.R

## 1. Merges the training and the test sets to create one data set
## 2. Extracts only the measurements on the mean and std dev for each measurement
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
##    each variable for each activity and each subject.

# Load Packages and get the Data
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Load activity labels and features
activity_labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
StatisticsWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[StatisticsWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load test data sets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, StatisticsWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
test_activities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
test_subjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(test_subjects, test_activities, test)

# Load train data sets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, StatisticsWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
train_activities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
train_subjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(train_subjects, train_activities, train)

# Merge test and train data sets
combined <- rbind(test, train)

# Convert classLabels to activityName basically. More explicit. 
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "Tidy_Data_Set.txt", quote = FALSE)
