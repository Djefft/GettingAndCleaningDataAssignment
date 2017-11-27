#Downloading the file and unzip it 
link = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(link,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}

## Read features, Train and Test and prepare the data for the merging
features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

TrainX <- read.table('./UCI HAR Dataset/train/X_train.txt')
TrainY <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
TrainSubject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

Train <-  data.frame(TrainSubject, TrainY, TrainX)
names(Train) <- c(c('subject', 'activity'), features)

TestX <- read.table('./UCI HAR Dataset/test/X_test.txt')
TestActivity <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
TestSubject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

Test <-  data.frame(TestSubject, TestActivity, TestX)
names(Test) <- c(c('subject', 'activity'), features)

#Apply rbind to merge the data all together
ConsDT <- rbind(Train, Test)

#Measuremements based on mean
Mean_Std_Sel <- grep('mean|std', features)
SubDT <- ConsDT[,c(1,2,Mean_Std_Sel + 2)]

#Descriptive activity
ACT_Label <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
ACT_Label <- as.character(ACT_Label[,2])
SubDT$activity <- ACT_Label[SubDT$activity]

#Adding labels 
NewLabel <- names(SubDT)
NewLabel <- gsub("[(][)]", "", NewLabel)
NewLabel <- gsub("^t", "Time_Domain_", NewLabel)
NewLabel <- gsub("^f", "Frequency_Domain_", NewLabel)
NewLabel <- gsub("Acc", "Accelerometer", NewLabel)
NewLabel <- gsub("Gyro", "Gyroscope", NewLabel)
NewLabel <- gsub("Mag", "Magnitude", NewLabel)
NewLabel <- gsub("-mean-", "_Mean_", NewLabel)
NewLabel <- gsub("-std-", "_Standard_Deviation_", NewLabel)
NewLabel <- gsub("-", "_", NewLabel)
names(SubDT) <- NewLabel

#Create tidy data

Final_Data <- aggregate(SubDT[,3:81], by = list(activity = SubDT$activity, subject = SubDT$subject),FUN = mean)
write.table(x = Final_Data, file = "tidy.txt", row.names = FALSE)
