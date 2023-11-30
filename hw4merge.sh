#!/bin/bash

# Check if correct number of files are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: ./hw4merge.sh file1.csv file2.csv file3.csv file4.csv file5.csv"
    exit 1
fi

# Merge, sort, and extract the best 100 spectra
cat $1 $2 $3 $4 $5 | sort -t, -k1,1n | head -n 100 > hw4best100.csv
