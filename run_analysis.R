# Open packages
library(dplyr)
library(data.table)

# Download the zip file. You need to run this code chunk and check file names before proceeding.
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./dataset.zip")
unzip("./dataset.zip",exdir = "./dataset")
list.files("./dataset",recursive = TRUE)

# Open features file
features <- read.table("./dataset/UCI HAR Dataset/features.txt")

## Open files for test dataset
x_test <- read.table("./dataset/UCI HAR Dataset/test/X_test.txt")
# Use features as column names
names(x_test) <- features$V2
# Open subject and activity files and name them
subject_test<- read.table("./dataset/UCI HAR Dataset/test/subject_test.txt")
names(subject_test) <- "Subject"
x_test_labels <- read.table("./dataset/UCI HAR Dataset/test/Y_test.txt")
names(x_test_labels)<-"Activity"
# Make a new data frame that contains activity, subject and data.
test_df <- cbind(x_test_labels,subject_test,x_test)

## Codes for the train dataset. Exactly the same steps as the test dataset.
x_train <- read.table("./dataset/UCI HAR Dataset/train/X_train.txt")
names(x_train) <- features$V2
subject_train<- read.table("./dataset/UCI HAR Dataset/train/subject_train.txt")
names(subject_train) <- "Subject"
x_train_labels<-read.table("./dataset/UCI HAR Dataset/train/Y_train.txt")
names(x_train_labels)<-"Activity"
train_df <- cbind(x_train_labels,subject_train,x_train)

# Merge test and train datasets
merge_df <-rbind(test_df,train_df)

## Find columns that don't contain mean or std in their names
merge_keep <- grep("mean|std",colnames(merge_df),value=TRUE)
# Make a new dataframe that removes the irrelevant columns
merge_subset <- select(merge_df,Activity,Subject,merge_keep)

#Label activity names
merge_subset$Activity<- merge_subset$Activity %>%
  gsub(pattern="1",replacement="WALKING") %>%
  gsub(pattern="2",replacement="WALKING_UPSTAIRS") %>%
  gsub(pattern="3",replacement="WALKING_DOWNSTAIRS") %>%
  gsub(pattern="4",replacement="SITTING") %>%
  gsub(pattern="5",replacement="STANDING")  %>%
  gsub(pattern="6",replacement="LAYING")

# Label columns to remove abbreviations
colnames(merge_subset) <- names(merge_subset) %>%
  gsub(pattern="Acc",replacement = "_Accelerometer") %>%
  gsub(pattern="Gyro",replacement = "_Gyroscope") %>%
  gsub(pattern="Mag",replacement = "_Magnitude") %>%
  gsub(pattern="tB",replacement = "time_B") %>%
  gsub(pattern="tG",replacement = "time_G") %>%
  gsub(pattern="fB",replacement = "frequency_domain_signal_B") 

# Make a second table
tidy_data_set <- merge_subset %>%
  group_by(Subject,Activity) %>%
  summarize_all(funs(mean))
write.table(tidy_data_set,"./tidy_data_set.txt")


