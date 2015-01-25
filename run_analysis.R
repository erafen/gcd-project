# run_analysis.R
#
# This script applies the following operations on the 
# "Human Activiy Recognition Using Smartphones"
# datasets:
#
# 1. Merges the training and the test sets to create one data set
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Renames variables in the data set using more descriptive names
# 4. Creates a second, independent tidy data set with the average of each variable 
#    for each activity and each subject.

# Loading needed libraries
library("dplyr")

# --------------- Step 1: merge the training and test sets
# Read the features names
features <- read.csv(file="../project-dataset/features.txt", 
                     sep=" ", 
                     header=FALSE,
                     col.names=c("index", "name"))

# Read the training and test sets and merge them into the data frame
cols = rep(16, 561)

subjectTest <- read.table(file="../project-dataset/test/subject_test.txt", col.names=c("subject"))
subjectTrain <- read.table(file="../project-dataset/train/subject_train.txt", col.names=c("subject"))
subjects <- rbind(subjectTest, subjectTrain)

xtest <- read.fwf(file="../project-dataset/test/X_test.txt", widths=cols, col.names=features$name)
xtrain <- read.fwf(file="../project-dataset/train/X_train.txt", widths=cols, col.names=features$name)
variables <- rbind(xtest, xtrain)

ytest <- read.table(file="../project-dataset/test/y_test.txt", col.names=c("activity"))
ytrain <- read.table(file="../project-dataset/train/y_train.txt", col.names=c("activity"))
activities <- rbind(ytest, ytrain)

# --------------- Step 2: extract the measurements on mean and standard deviation

# get the indices of the columns that contain mean, standard deviation data and activity
indices <- grep("mean()|std()", names(variables))
# keep these columns only
variables <- select(variables, indices)
# add subject and activity columns
df <- cbind(subjects, cbind(variables, activities))

# --------------- Step 3: Uses descriptive activity names to name the activities in the data set
# activity codes are replaced with their label
activityLabels <- read.table(file="../project-dataset/activity_labels.txt", col.names=c("id", "label"))

# build factors and replace the activity column with it
factors <- factor(df$activity, levels = activityLabels$id, labels=activityLabels$label)
df$activity <- factors

# --------------- Step 4: Appropriately labels the data set with descriptive variable names. 
# descriptive variable names have been set during the first step of this script


# --------------- Step 5: From the data set in step 4 (merged), creates a second, independent 
#                         tidy data set with the average of each variable for each activity 
#                         and each subject.

grouped <- group_by(df, subject, activity)
averages <- summarise_each(grouped, funs(mean), 2:80)

# Final step: write the resulting table to a text file
write.table(averages, file="averages.txt", row.names=FALSE)
