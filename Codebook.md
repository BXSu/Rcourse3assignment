---
title: "Codebook"
author: "BXSu"
date: "13/06/2020"
---

## Getting and Cleaning Data Course Project
The purpose of this project is to download and tidy data collected from wearable computing.Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

## 1. Download data, unzip file and find the names of relevant files:
This code chunk needs to be ran prior to the other chunks, as it lists all the relevant files in the directory. The following code chunk downloads the data from this link: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. The data is saved in a directory called dataset. Files in the directory are listed to enable subsequent analysis:

```{r}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./dataset.zip")
unzip("./dataset.zip",exdir = "./dataset")
list.files("./dataset",recursive = TRUE)
```


## 2. Open features file
Based on the file list, the features file is opened. It contains detailed information on the data collected (time,FFT,accelerometer,gyroscope,analysis) 
```{r}
features <- read.table("./dataset/UCI HAR Dataset/features.txt")
```

## 3.1 Make a table for test data
This chunk opens the data collected for the test group and labels each column with 'features'. It then add two columns: Activity and Subject to create a new table called test_df.

```{r}
x_test <- read.table("./dataset/UCI HAR Dataset/test/X_test.txt")
names(x_test) <- features$V2
subject_test<- read.table("./dataset/UCI HAR Dataset/test/subject_test.txt")
names(subject_test) <- "Subject"
x_test_labels <- read.table("./dataset/UCI HAR Dataset/test/Y_test.txt")
names(x_test_labels)<-"Activity"
test_df <- cbind(x_test_labels,subject_test,x_test)
```

## 3.2 Make a table for train data
This chunk opens the data collected for the train group and labels each column with 'features'. It then add two columns: Activity and Subject to create a new table called train_df.

```{r}
x_train <- read.table("./dataset/UCI HAR Dataset/train/X_train.txt")
names(x_train) <- features$V2
subject_train<- read.table("./dataset/UCI HAR Dataset/train/subject_train.txt")
names(subject_train) <- "Subject"
x_train_labels<-read.table("./dataset/UCI HAR Dataset/train/Y_train.txt")
names(x_train_labels)<-"Activity"
train_df <- cbind(x_train_labels,subject_train,x_train)
```

## 4. Merge test and train data and keep only mean and standard deviation columns
This chunk merges test and train tables and makes a new table that only contains columns containing data and mean and standard deviation.

```{r}
merge_df <-rbind(test_df,train_df)
merge_keep <- grep("mean|std",colnames(merge_df),value=TRUE)
merge_subset <- select(merge_df,Activity,Subject,merge_keep)
```

## 5. Improve labeling
This chunk first replaces the numbers in the Activity column with the corresponding activities. It then replaces the abbreviations in the column names with the full names. '_' was added to help reading the column names.
```{r}
merge_subset$Activity<- merge_subset$Activity %>%
  gsub(pattern="1",replacement="WALKING") %>%
  gsub(pattern="2",replacement="WALKING_UPSTAIRS") %>%
  gsub(pattern="3",replacement="WALKING_DOWNSTAIRS") %>%
  gsub(pattern="4",replacement="SITTING") %>%
  gsub(pattern="5",replacement="STANDING")  %>%
  gsub(pattern="6",replacement="LAYING")
```


```{r}
colnames(merge_subset) <- names(merge_subset) %>%
  gsub(pattern="Acc",replacement = "_Accelerometer") %>%
  gsub(pattern="Gyro",replacement = "_Gyroscope") %>%
  gsub(pattern="Mag",replacement = "_Magnitude") %>%
  gsub(pattern="tB",replacement = "time_B") %>%
  gsub(pattern="tG",replacement = "time_G") %>%
  gsub(pattern="fB",replacement = "frequency_domain_signal_B") 
```

## 6. Make a second table
The following code re-organizes the first table by Activity and Subject, and takes the average of each variable. The new table is named tidy_data_set.

```{r}
tidy_data_set <- merge_subset %>%
  group_by(Subject,Activity) %>%
  summarize_all(funs(mean))
write.table(tidy_data_set,"./tidy_data_set.txt",row.names = FALSE)
```



