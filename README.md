# Getting and Cleaning Data - Final Project

The script that prepared the tidy dataset 'tidy.txt' is found in the R file 'run_analysis.R'. An overview of what it does is as follows:

* Loads the activity labels, feature list, and test and train data files, does a little cleanup and column renaming.
* Combines all of the data into a single data table with only the variables that represent mean or standard deviation.
* Melts the dataset based on subject and activity so a new tidy dataset can be reconstructed with the means of each variable.
* Writes out the resulting dataset to 'tidy.txt'

