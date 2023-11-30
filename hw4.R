rm(list=ls())

# Tuocheng Chen
# tchen465@wisc.edu

# Load package
require("FITSio")

# Command-Line Arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  cat("usage: Rscript hw4.R <template spectrum> <data directory>\n")
  quit(save = "no", status = 1)
}

# Set paths to template spectrum and data directory
template_spectrum <- args[1]
dirPath <- args[2]
fileList <- list.files(dirPath, full.names = TRUE)

# Read the template spectrum
baseDF <- readFrameFromFITS(template_spectrum)
colnames(baseDF)[colnames(baseDF) == "FLUX"] <- "flux"
len1 <- nrow(baseDF)

# Define functions
# Clean rows with non-zero andmask
Clean = function(df){
  avgDf <- mean(df$flux)
  df[df$and_mask != 0, "flux"] <- avgDf
  return(df)
}
# Standardization
StanFlux = function(df){
  avgDf = mean(df$flux)
  stdDf = sd(df$flux)
  df$flux <- (df$flux - avgDf)/stdDf
  return(df)
}
# Read data and create a dataframe with new columns and details
getDF = function(fileName){
  Name <- paste("",fileName,sep="")
  df <- readFrameFromFITS(Name)
  if (ncol(df)>8){
    df <- df[,1:8]
  }
  df$spectrumID <- fileName
  df$CORR <- 0
  df$distance <- 0
  df$weighted <- 0
  df$i <- 0
  return(df)
}
# Get correlation
CORR = function(df){
  cor(baseDF$flux,df$flux)
}
# Get Euclidean distance
Euc = function(df){
  dif <- baseDF$flux - df$flux
  sqrt(sum(dif*dif))
}
# Get weighted Euclidean distance
Weighted = function(df){
  dif <- baseDF$flux - df$flux
  sqrt(sum(dif*dif*max(df$ivar,1.5)))
}

# Standardize base data
baseDF <- StanFlux(baseDF)

# Create Output dataframe
Output <- data.frame(matrix(ncol = 13, nrow = 0))
colnames(Output) <- c("flux","loglam","ivar","and_mask","or_mask","wdisp",
                      "sky","model","spectrumID","CORR","distance","i","weighted")

# For loop
for (fileName in fileList) {
  # create dataframe
  temp <- getDF(fileName)
  # check if length is enough
  if (nrow(temp)<len1){break}
  # process if and-mask is none-zero
  temp <- Clean(temp)
  # for loop: cut dataframe to length
  for (j in 1:(nrow(temp)-len1+1)){
    cutdf <- temp[j:(j+len1-1),]
    # standardize
    cutdf <- StanFlux(cutdf)
    # compute correlation 
    temp$CORR[j] <- CORR(cutdf)
    # compute Euclidean
    temp$distance[j] <- Euc(cutdf)
    # add count i
    temp$i[j]<-j
    # compute weighted distance
    temp$weighted <- Weighted(cutdf)
  } 
  # remove if count = 0
  temp <- temp[temp$i!=0,]
  # add to output
  Output <- rbind(Output,temp)
}

# Remove zero and NA
Output <- Output[Output$i!=0,]
Output <- Output[!is.na(Output$CORR),]

# Sort by distance and remove duplicates
finalDF <- Output[order(Output$distance), ]
finalDF <- finalDF[!duplicated(finalDF$spectrumID), ]
finalDF <- finalDF[,c("distance","spectrumID","i")]

# Write output file
output_file_name <- paste0(dirname(dirPath), "/", basename(dirPath), ".csv")
write.csv(finalDF, output_file_name, row.names = FALSE)


