## run_analysis.R demonstrating tidying data concepts


## assumes data.table, and reshape2 are installed
library("data.table")
library("reshape2")

## download and unzip in the subfolder- data

download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
            destfile="./wearables.zip", method="curl")
 
 unzip("./wearables.zip", exdir="./data")

datadir <- "./data/UCI HAR Dataset"
datadir.train <- file.path(datadir,"train")
datadir.test <- file.path(datadir,"test")

#read train 
train.x <- read.table(file.path(datadir.train,"X_train.txt"), sep='')
train.y <- read.table(file.path(datadir.train,"y_train.txt"), sep='')
train.subject <-read.table(file.path(datadir.train,"subject_train.txt"), sep='')

#read test
test.x <- read.table(file.path(datadir.test,"X_test.txt"), sep='')
test.y <- read.table(file.path(datadir.test,"y_test.txt"), sep='')
test.subject <-read.table(file.path(datadir.test,"subject_test.txt"), sep='')

# read metadata - activity labels and features
activity_labels <- read.table(file.path(datadir,"activity_labels.txt"), sep = '')
names(activity_labels) <- c("activity_label_id","activity_label")
features    <- read.table(file.path(datadir,"features.txt"),sep='')

# train - bind all columns with features added to x columns
names(train.y) <- "activity_label_id"
names(train.subject) <- "subject"
names(train.x) <- features[,2]
train <- cbind(train.subject, train.y, train.x)

# test - bind all columns 
names(test.y) <- "activity_label_id"
names(test.subject) <- "subject"
names(test.x) <- features[,2]
test <- cbind(test.subject, test.y, test.x)

#combine both the datsets
wholeset.raw <- rbind(train,test)

#get labels 
wholeset <- merge(wholeset.raw,activity_labels,by.x="activity_label_id",by.y="activity_label_id")

# let's get the columns that are std /mean, and and just activity_label,
columns.interested <- c(2,564, grep('-mean|-std', colnames(wholeset)))

# select the set with the columns
wholeset.meanstd_obs <- wholeset[,columns.interested]

#get the mean
meltedset <- melt(wholeset.meanstd_obs, id.var = c('subject', 'activity_label'))
meltedset.mean <- dcast(meltedset , subject + activity_label ~ variable, mean)

## save
write.table(meltedset.mean, file="./data/tidy_data.txt", row.names = FALSE)

