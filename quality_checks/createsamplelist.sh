#!/bin/bash

#Define path to fast file as variable
FASTQ_FOLDER='/data/courses/rnaseq_course/breastcancer_de/reads/'

#Iterate over fast files
for FILE in $FASTQ_FOLDER/*_*1.fastq.gz
do
PREFIX="${FILE%_*.fastq.gz}" #Remove .fastq.gz from the file name 
SAMPLE=`basename $PREFIX` #Remove path
echo -e "${SAMPLE}\t$FILE\t${FILE%?.fastq.gz}2.fastq.gz" #Prints out samples names and the path to each read per sample (removing and replacing the end of the filenames)
done
