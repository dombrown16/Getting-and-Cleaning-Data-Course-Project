# Download and unzip the data set.

library(RCurl)

if (!file.info('UCI HAR Dataset')$isdir) {
  dataFile <- 'https://d396qusza40orc.cloudfront.net/getdata%2
  Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  dir.create('UCI HAR Dataset')
  download.file(dataFile, 'UCI-HAR-dataset.zip', method='curl')
  unzip('./UCI-HAR-dataset.zip')
}

# 1. Merges the training and the test sets to create one data set.

x_train <- read.table('./UCI HAR Dataset/train/X_train.txt')
x_test <- read.table('./UCI HAR Dataset/test/X_test.txt')
x <- rbind(x_train, x_test)

subject_train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
subject_test <- read.table('./UCI HAR Dataset/test/subject_test.txt')
subject <- rbind(subject_train, subject_test)

y_train <- read.table('./UCI HAR Dataset/train/y_train.txt')
y_test <- read.table('./UCI HAR Dataset/test/y_test.txt')
y <- rbind(y_train, y_test)

# 2. Extracts only the measurements on the mean and standard deviation
#    for each measurement.

features <- read.table('./UCI HAR Dataset/features.txt')
mean_std <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
x_mean_std <- x[, mean_std]

# 3. Uses descriptive activity names to name the activities in the data set

names(x_mean_std) <- features[mean_std, 2]
names(x_mean_std) <- tolower(names(x_mean_std)) 
names(x_mean_std) <- gsub("\\(|\\)", "", names(x_mean_std))

activities <- read.table('./UCI HAR Dataset/activity_labels.txt')
activities[, 2] <- tolower(as.character(activities[, 2]))
activities[, 2] <- gsub("_", "", activities[, 2])

y[, 1] = activities[y[, 1], 2]
colnames(y) <- 'activity'
colnames(subject) <- 'subject'

# 4. Appropriately labels the data set with descriptive activity names.

data_set <- cbind(subject, x_mean_std, y)
str(data_set)
write.table(data_set, "merged_dataset.txt", row.names = FALSE)

# 5.Creates a second, independent tidy data set with the average of 
#   each variable for each activity and each subject. 

av_var <- aggregate(x=data_set, by=list(activities=data_set$activity, 
                                        subject=data_set$subject), FUN=mean)
av_var <- av_var[, !(colnames(av_var) %in% c("subject", "activity"))]
str(av_var)
write.table(av_var, "tidy_data_set.txt", row.names = FALSE)
