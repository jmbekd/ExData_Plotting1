## Loads required library
if(!require("data.table")) install.packages("data.table", repos = "http://cran.r-project.org")
library(data.table)

## Creates required directories
dir <- "./data" # data directory
if (!file.exists(dir)) {dir.create(dir)} # creates a data directory in your working directory if one doesn't already exist
fig <- "./figure" # figure directory
if (!file.exists(fig)) {dir.create(fig)} # creates a figure directory in your working directory if one doesn't already exist

## Checks whether the data has been downloaded to your data directory and if not, downloads the data and unzips it
if (!("power.zip" %in% list.files(dir))) {
  fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
  download.file(fileUrl, destfile = paste0(dir, "/power.zip"), mode = "wb") # downloads data from the URL to the data directory
  unzip(paste0(dir, "/power.zip"), exdir = "data") # unzips the file(s) to the data directory
}

## Checks whether the data has been preprocessed and saved as an ".Rdata" file, if not, processes the data and saves a copy of the processed data to the data directory
if (!("processedData.Rdata" %in% list.files(dir))) {
  filename <- list.files(dir, pattern = "*.txt", full.names = TRUE)
  colClasses <- sapply(read.table(filename, sep = ";", header = TRUE, stringsAsFactors = FALSE, nrow = 200), class) # determines the class of each of the columns based 
  # on the first 200 rows of data
  dt <- data.table(read.table(filename, sep = ";", header = TRUE, stringsAsFactors = FALSE, na.strings = "?", colClasses = colClasses), key = "Date")
  dt <- dt[J(c("1/2/2007", "2/2/2007"))] # subsets the data such that it only contains data from 2007-02-01 through 2007-02-02
  dt[, DateTime := paste(Date, Time, sep = " ")] # pastes the Date and Time columns together for use with strptime
  save(dt, file = paste0(dir, "/processedData.Rdata")) # saves the processed data
} else {load(paste0(dir, "/processedData.Rdata"))}

## Creates a plot of Energy Sub Metering results for Sub_metering_1, Sub_metering_2, and Sub_metering_3 as a function of time 
## and saves it as "plot3.png" the figure directory
colNames <- names(dt)[grep(names(dt), pattern = "Sub*")] # extracts the desired column names (i.e., those starting with "Sub")
rangeyValues <- range(dt[, colNames, with = FALSE]) # determines the range of the y values in the Sub_metering columns
clrs <- c("black", "red", "blue") # specifies the desired colors

png(file = paste0(fig, "/plot4.png"), width = 480, height = 480, bg = "white")
par(mfrow=c(2,2)) # divides the plotting window into a 2 x 2 grid
## Plot 1
plot(x = strptime(dt$DateTime, format = "%d/%m/%Y %H:%M:%S"), y = dt[, Global_active_power], lty = 1, type = "l", 
     ylab = "Global Active Power", xlab = "")

## Plot 2
plot(x = strptime(dt$DateTime, format = "%d/%m/%Y %H:%M:%S"), y = dt[, Voltage], lty = 1, type = "l", 
     ylab = "Voltage", xlab = "datetime")

## Plot 3
plot(x = strptime(dt$DateTime, format = "%d/%m/%Y %H:%M:%S"), y = rep(0, length(dt$DateTime)), type = "n", 
     ylim = rangeyValues, ylab = "Energy sub metering", xlab = "")
for (i in 1:length(colNames)) {
  lines(x = strptime(dt$DateTime, format = "%d/%m/%Y %H:%M:%S"), y = dt[[colNames[i]]], lty = 1, type = "l", col = clrs[i])   
}
legend("topright", legend = colNames, lty = 1, col = clrs, bty = "n")

## Plot 4
plot(x = strptime(dt$DateTime, format = "%d/%m/%Y %H:%M:%S"), y = dt[, Global_reactive_power], lty = 1, type = "l", 
     ylab = "Global_reactive_power", xlab = "datetime")
dev.off()
