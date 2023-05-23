# Load required package
library(dplyr)

# Download and unzip data
if (!file.exists("FinalProject.zip")){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, "FinalProject.zip",method="curl")
}

unzip("FinalProject.zip")

# Read files
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c('Id', 'Type'))
features <- read.table("UCI HAR Dataset/features.txt", col.names=c('Id', 'Value'))

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = 'Subject')
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$Value)
Y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = 'Code')

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = 'Subject')
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$Value)
Y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = 'Code')

# STEP 1: Merge the training and the test sets to create one data set
X <- rbind(X_test, X_train)
Y <- rbind(Y_test, Y_train)
Subject <- rbind(subject_test, subject_train)
mergedDF <- cbind(Subject, Y, X)

# STEP 2: Extract only the measurements on the mean and standard deviation for each measurement
TidyDF <- mergedDF %>% select(Subject, Code,  matches("mean|std"))

# STEP 3: Uses descriptive activity names to name the activities in the data set
TidyDF <- merge(TidyDF, activity_labels, 
                  by.x = "Code", by.y = "Id", 
                  all.x = TRUE)
TidyDF$Code = TidyDF$Type 
TidyDF <- TidyDF %>% 
        select(-Type) %>% 
        select(Subject, Code, everything())

# STEP 4: Appropriately labels the data set with descriptive variable names

names(TidyDF)[2] = "Activity"
TidyDF <- TidyDF %>%
        rename_with(~gsub("Acc", "Accelerometer", .x), everything()) %>%
        rename_with(~gsub("Gyro", "Gyroscope", .x), everything()) %>%
        rename_with(~gsub("BodyBody", "Body", .x), everything()) %>%
        rename_with(~gsub("Mag", "Magnitude", .x), everything()) %>%
        rename_with(~gsub("^t", "Time", .x), everything()) %>%
        rename_with(~gsub("^f", "Frequency", .x), everything()) %>%
        rename_with(~gsub("tBody", "TimeBody", .x), everything()) %>%
        rename_with(~gsub("-mean\\(\\)", "Mean", .x, ignore.case = TRUE), everything()) %>%
        rename_with(~gsub("-std\\(\\)", "STD", .x, ignore.case = TRUE), everything()) %>%
        rename_with(~gsub("-freq\\(\\)", "Frequency", .x, ignore.case = TRUE), everything()) %>%
        rename_with(~gsub("angle", "Angle", .x), everything()) %>%
        rename_with(~gsub("gravity", "Gravity", .x), everything())

# STEP 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
FinalDF <- TidyDF %>%
        group_by(Subject, Activity) %>%
        summarise(across(everything(), mean)) %>%
        ungroup()

write.table(FinalDF, "FinalDF.txt", row.names = FALSE)
