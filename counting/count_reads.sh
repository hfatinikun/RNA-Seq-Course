#!/bin/bash

#SBATCH --mail-type=fail
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=data/users/hfatinikun/output_%j.o
#SBATCH --error=data/users/hfatinikun/error_%j.o
#SBATCH --mail-user=heritage.fatinikun@students.unibe.ch
#SBATCH --time=13:00:00
#SBATCH --mem=4G
#SBATCH --partition=pibu_el8
#SBATCH --job-name="RNA Seq Count Reads "

#Define Variables
ANNOTATION_DIR='/data/users/hfatinikun/RNA-Seq-Course/Reference_genome/Homo_sapiens.GRCh38.113.gtf.gz'
BAM_DIR='/data/users/hfatinikun/RNA-Seq-Course/mapping/BAM_Files'
SAMPLELIST='/data/users/hfatinikun/RNA-Seq-Course/quality_checks/samplelist.txt'
COUNT_DIR='/data/users/hfatinikun/RNA-Seq-Course/counting/gene_count.txt'
APPTAINER_IMG='/containers/apptainer/subread_2.0.1--hed695b0_0.sif'

#Create the file for the result 
mkdir -p $(dirname $COUNT_DIR)

# Create a list of BAM file paths by combining the BAM directory, sample name, and the .bam extension
BAM_FILES_LIST=$(awk -v dir="$BAM_DIR" '{print dir "/" $1 ".bam"}' $SAMPLELIST)

#Use featureCounts to create a table of the read count per gene with the list of bam files
apptainer exec --bind $BAM_DIR,$(dirname $COUNT_DIR),$(dirname $ANNOTATION_DIR) $APPTAINER_IMG featureCounts -T 4 -a $ANNOTATION_DIR -o $COUNT_DIR $BAM_FILES_LIST