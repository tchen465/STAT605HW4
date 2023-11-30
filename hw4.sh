#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: ./hw4.sh <template_spectrum> <data_directory_tgz>"
    exit 1
fi

# Assign arguments to variables for clarity
template_spectrum=$1
data_directory_tgz=$2

# Untar R installation and FITSio package
tar -xzf R413.tar.gz
tar -xzf packages_FITSio.tar.gz

# Set environment variables
export PATH=$PWD/R/bin:$PATH
export RHOME=$PWD/R
export R_LIBS=$PWD/packages

# Unpack the provided .tgz file
tar -xzf $data_directory_tgz

# Extract the directory name from the .tgz file
data_directory=${data_directory_tgz%.tgz}

# Run hw4.R script
Rscript hw4.R $template_spectrum $data_directory
