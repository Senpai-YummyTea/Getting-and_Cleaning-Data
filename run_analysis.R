#1. Install and Load some necessary packages
install.packages("data.table")
install.packages("reshape.2")
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
#2. Get the working directory and download then Unzipping the data
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")
#3. Creating a variable to store activity labels
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)
#4. Creating an another variable to load train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)
#5. Creating an another variable to load test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)
#6. Merge datasets using rbind function and putting to a new variable called TTCombined
TTCombined <- rbind(train, test)
#7.To have an specific distinction, the classLabels variable was converted to activityName.
TTCombined[["Activity"]] <- factor(TTCombined[, Activity]
                                   , levels = activityLabels[["classLabels"]]
                                   , labels = activityLabels[["activityName"]])

TTCombined[["SubjectNum"]] <- as.factor(TTCombined[, SubjectNum])
TTCombined <- reshape2::melt(data = TTCombined, id = c("SubjectNum", "Activity"))
TTCombined <- reshape2::dcast(data = TTCombined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = TTCombined, file = "tidyData.txt", quote = FALSE)