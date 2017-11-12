#R Script from Course Three Week Four Peer Assignment
#Merging training data and test data into a tidy data format

#load up the activity labels and the features

features <- fread("UCI HAR Dataset/features.txt", col.names = c("index", "featureNames"))
activityLabels <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("classLabels", "activityName"))
featuresDesired <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresDesired, featureNames]
measurements <- gsub('[()]', '', measurements)

#load up the training datasets

training <- fread("UCI HAR Dataset/train/X_train.txt")[, featuresDesired, with = FALSE]
data.table::setnames(training, colnames(training), measurements)
trainingActivities <- fread("UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
trainingSubjects <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = c("SubjectNumber"))
training <- cbind(trainingSubjects, trainingActivities, training)

#load up the test data sets

test <- fread("UCI HAR Dataset/test/X_test.txt")[, featuresDesired, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread("UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
testSubjects <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = c("SubjectNumber"))
test <- cbind(testSubjects, testActivities, test)

#merge data and add the labels to needed

combined <- rbind(training, test, 'fill' = TRUE)

#rshape the classLabels and ActivityNames to be clearer 

combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

combined[["SubjectNumber"]] <- as.factor(combined[, SubjectNumber])
combined <- reshape2::melt(data = combined, id = c("SubjectNumber", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNumber + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.csv", quote = FALSE)


